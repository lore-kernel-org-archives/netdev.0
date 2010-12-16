From: Kristian Larsson <kristian@spritelink.net>
Subject: Re: pktgen IP address stepping
Date: Thu, 16 Dec 2010 19:30:04 +0100
Message-ID: <20101216183004.GC8404@spritelink.se>
References: <20101216172800.GA8404@spritelink.se>
 <1292522532.29894.33.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Mail2.SpriteLink.NET ([195.182.5.83]:59144 "EHLO
	Mail2.SpriteLink.NET" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754115Ab0LPSbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 13:31:42 -0500
Content-Disposition: inline
In-Reply-To: <1292522532.29894.33.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 10:02:12AM -0800, Joe Perches wrote:
> On Thu, 2010-12-16 at 18:28 +0100, Kristian Larsson wrote:
> > This patch adds the ability to set the step rate at which the source
> > or destination IP address is increased when src_min / src_max or
> > dst_min / dst_max is used with pktgen.
> > Usage is simple, two new parameters:
> >   src_step X
> >   dst_step X
> > where X is a positive integer (or actually an unsigned long long).
> []
> > Looking forward to any feedback and / or suggestions.
> 
> I suggest using actual ipv4 addresses (and ipv6 if you ever
> need it) as increment/mask.

Not sure I follow you, should the stepping be specified as
0.0.0.213 if I would like to increase with 213 or 0.0.255.255 if
I want to increase by a /16 at a time?

> For your current use, __u32 would work fine.

Yepp, I'll have a look at that once I get home :)
 

> trivia:
> 
> pr_<foo> calls are already prefixed with pktgen via pr_fmt,
> you don't need to add it to the format string.

Same thing here, will look over it. I think I copied most of this
from some other part of pktgen.c :)

Kind regards,
    Kristian.

-- 
Kristian Larsson                                        KLL-RIPE
+46 704 264511			                      kll@spritelink.net
