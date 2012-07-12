From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/16] Handle redirects just like PMTU
Date: Thu, 12 Jul 2012 10:45:33 +0200
Message-ID: <1342082733.3265.8254.camel@edumazet-glaptop>
References: <20120712.011030.1683311016960504439.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48285 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754047Ab2GLIpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 04:45:43 -0400
Received: by bkwj10 with SMTP id j10so1897772bkw.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 01:45:42 -0700 (PDT)
In-Reply-To: <20120712.011030.1683311016960504439.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-12 at 01:10 -0700, David Miller wrote:
> As described in my patch series from the other day, we need to
> rearrange redirect handling so that the local initiators of packets
> (sockets, tunnels, xfrms, etc.) that implement the protocols compute
> the route and pass this down into the ipv4/ipv6 routing code.
> 
> These changes here do so by implementing a new dst_ops->redirect
> method.
> 
> No more do we have this funny code that tries several different sets
> of routing keys to try and figure out which route the redirect should
> actually be applied to.
> 
> No more do we have the problem wherein TOS rewriting causes problems
> for us.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Wow, this looks very good.

I did a quick review and found no obvious problem.

Bye bye ip_rt_redirect(), finally ;)
