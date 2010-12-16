From: Joe Perches <joe@perches.com>
Subject: Re: pktgen IP address stepping
Date: Thu, 16 Dec 2010 11:18:52 -0800
Message-ID: <1292527132.29894.52.camel@Joe-Laptop>
References: <20101216172800.GA8404@spritelink.se>
	 <1292522532.29894.33.camel@Joe-Laptop>
	 <20101216183004.GC8404@spritelink.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Kristian Larsson <kristian@spritelink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2719 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754184Ab0LPTSy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Dec 2010 14:18:54 -0500
In-Reply-To: <20101216183004.GC8404@spritelink.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-12-16 at 19:30 +0100, Kristian Larsson wrote:
> > I suggest using actual ipv4 addresses (and ipv6 if you ever
> > need it) as increment/mask.
> Not sure I follow you, should the stepping be specified as
> 0.0.0.213 if I would like to increase with 213 or 0.0.255.255 if
> I want to increase by a /16 at a time?

More like:

Initial IPv4 address:	0.0.0.1
Step:			0.1.0.0
Mask:			127.0.0.1

addr = (addr + step) & mask;

Cycles through all /16's below 128



