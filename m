From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: properly scale window in
 tcp_v[46]_reqsk_send_ack()
Date: Tue, 23 Aug 2016 16:56:36 -0700 (PDT)
Message-ID: <20160823.165636.1233532130471213223.davem@davemloft.net>
References: <1471890670.14381.10.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com,
        edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55892 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754429AbcHWX5T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 19:57:19 -0400
In-Reply-To: <1471890670.14381.10.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 22 Aug 2016 11:31:10 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When sending an ack in SYN_RECV state, we must scale the offered
> window if wscale option was negotiated and accepted.
> 
> Tested:
>  Following packetdrill test demonstrates the issue :
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
