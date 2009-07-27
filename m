From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: shrink net_device by #ifdef-ing protocol-specific
 members
Date: Mon, 27 Jul 2009 09:23:01 -0700
Message-ID: <1248711781.10463.108.camel@Joe-Laptop.home>
References: <4A6DC314.2010303@ixiacom.com>
	 <20090727.082644.265102452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lgrijincu@ixiacom.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:3343 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254AbZG0QXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 12:23:05 -0400
In-Reply-To: <20090727.082644.265102452.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-07-27 at 08:26 -0700, David Miller wrote:
> From: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
> Date: Mon, 27 Jul 2009 18:09:08 +0300
> > Some members of net_device are used only by some protocols.
> > If those protocols are not compiled (as modules or linked in) they
> > should not take up space in the structure.
> This benefits, at best, %0.000000001 of users of the Linux kernel,
> because every distribution is going to turn on every single option.

I think the cost of maintaining this is small and the
percentage of users that benefit underestimated.

It does help handsets a trivial amount, which are unlikely
to ever enable decnet or econet.

> If you want to shrink structures, find ways to eliminate or
> shrink structure members in all cases.

Good advice.


