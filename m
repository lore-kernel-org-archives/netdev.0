From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV6] ROUTE: Don't try less preferred routes for
 on-link routes.
Date: Fri, 26 May 2006 13:24:04 -0700 (PDT)
Message-ID: <20060526.132404.107682119.davem@davemloft.net>
References: <20060526.190856.33048221.yoshfuji@linux-ipv6.org>
	<Pine.SOC.4.61.0605261344340.26383@math.ut.ee>
	<20060526.200156.83522671.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mroos@linux.ee, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7140
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751435AbWEZUXz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 16:23:55 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060526.200156.83522671.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Fri, 26 May 2006 20:01:56 +0900 (JST)

> In article <Pine.SOC.4.61.0605261344340.26383@math.ut.ee> (at Fri, 26 May 2006 13:44:59 +0300 (EEST)), Meelis Roos <mroos@linux.ee> says:
> 
> > >> The unreachable route works now but LAN routing still does not work.
> > >> Locally generated ICMPv6 packets that should go to LAN interface still
> > >> go to tun6to4.
> > >
> > > Please try this.
> > 
> > This works for both unreachable and LAN routes, thanks!
> 
> Please push this to 2.6.17-final.

Applied, thank you very much.
