From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: addrconf: increment ifp refcount before
 ipv6_del_addr()
Date: Tue, 31 Oct 2017 09:33:31 -0700
Message-ID: <1509467611.3828.20.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1509422017.17752.4.camel@edumazet-glaptop3.roam.corp.google.com>
         <f43e1142-e0c6-e2fa-dac8-00579747b91e@gmail.com>
         <1509428829.17752.15.camel@edumazet-glaptop3.roam.corp.google.com>
         <1af0cf58-cf26-ed98-cb76-9547f3b3eae6@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:47978 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753696AbdJaQdd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 12:33:33 -0400
Received: by mail-io0-f174.google.com with SMTP id h70so34780ioi.4
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 09:33:33 -0700 (PDT)
In-Reply-To: <1af0cf58-cf26-ed98-cb76-9547f3b3eae6@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-31 at 10:09 -0600, David Ahern wrote:

> Interestingly, I put the failure sequence into a loop and hit the above
> path closing in on 1 million times and I am not seeing a memory leak
> with our without this patch.
> 
> The above does fix the refcnt and based on other call sites for
> ipv6_del_addr is the right thing to do, so...
> 
> Acked-by: David Ahern <dsahern@gmail.com>

Thanks a lot for testing !
