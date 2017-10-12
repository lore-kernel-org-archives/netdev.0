From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next] selftests: rtnetlink: add a small macsec test
 case
Date: Thu, 12 Oct 2017 12:52:16 +0200
Message-ID: <20171012105216.GF26835@breakpoint.cc>
References: <20171012091122.28133-1-fw@strlen.de>
 <20171012101054.GA31183@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:45354 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756046AbdJLKwZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 06:52:25 -0400
Content-Disposition: inline
In-Reply-To: <20171012101054.GA31183@bistromath.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sabrina Dubroca <sd@queasysnail.net> wrote:
> 2017-10-12, 11:11:22 +0200, Florian Westphal wrote:
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> 
> Reviewed-by: Sabrina Dubroca <sd@queasysnail.net>

Thanks for reviewing.

> Just a small detail: the "ip macsec" commands actually use genetlink
> and not rtnetlink.

Right, but it implements rtnl link ops so it ends up
interacting with rtnetlink too...

I also added sysfs-based change of device aliases to this script,
and I'm sure I will end up adding test cases that interact with
rtnetlink via ioctl, setsockopts and so on.

rtnl_lock() is all over the place so I think it makes sense to
cover as much callsites/call paths as possible even if the entry
point is not via rtnetlink socket.
