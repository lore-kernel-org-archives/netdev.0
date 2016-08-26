From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] net: batch calls to flush_all_backlogs()
Date: Fri, 26 Aug 2016 22:21:04 +0200
Message-ID: <1472242864.3664803.707324577.7641976D@webmail.messagingengine.com>
References: <1472241039.14381.202.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:43994 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751014AbcHZUW2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 16:22:28 -0400
In-Reply-To: <1472241039.14381.202.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 26, 2016, at 21:50, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> After commit 145dd5f9c88f ("net: flush the softnet backlog in process
> context"), we can easily batch calls to flush_all_backlogs() for all
> devices processed in rollback_registered_many()
> 
> Tested:
> 
> Before patch, on an idle host.
> 
> modprobe dummy numdummies=10000
> perf stat -e context-switches -a rmmod dummy
> 
>  Performance counter stats for 'system wide':
> 
>          1,211,798      context-switches
> 
>        1.302137465 seconds time elapsed
> 
> After patch:
> 
> perf stat -e context-switches -a rmmod dummy
> 
>  Performance counter stats for 'system wide':
> 
>            225,523      context-switches
> 
>        0.721623566 seconds time elapsed

Cool demonstration! :}

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
