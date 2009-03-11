From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Wed, 11 Mar 2009 21:33:16 +0000
Message-ID: <20090311213316.GF18096@n2100.arm.linux.org.uk>
References: <1236738549-16703-1-git-send-email-yanok@emcraft.com> <20090310211841.388619ca@nehalam> <20090311084430.GU425@pengutronix.de> <20090311.014957.117115597.davem@davemloft.net> <49B82566.3070909@weinigel.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, s.hauer@pengutronix.de,
	shemminger@vyatta.com, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: Christer Weinigel <christer@weinigel.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:60021 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873AbZCKVds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 17:33:48 -0400
Content-Disposition: inline
In-Reply-To: <49B82566.3070909@weinigel.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2009 at 09:56:06PM +0100, Christer Weinigel wrote:
> Actually, I wish we had a generic way of doing that, so that could set 
> the mac address of any ethernet interface from the kernel command in a 
> nice and supported way.

You're not the first to suggest that; that's precisely what I've
suggested in the past (though I probably couldn't find the postings if
I tried now.)  I've seen it all, from people trying to invent ATAGs to
pass ethernet addresses to the kernel, driver specific command lines,
and hard coded ethernet addresses in drivers.

I'm sure David would give full and proper consideration to a clean patch
adding such support in a generic way (even if the resulting answer is
still a 'no'.)
