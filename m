From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Wed, 11 Mar 2009 09:57:21 +0100
Message-ID: <20090311085721.GV425@pengutronix.de>
References: <1236738549-16703-1-git-send-email-yanok@emcraft.com> <20090310211841.388619ca@nehalam> <20090311084430.GU425@pengutronix.de> <20090311.014957.117115597.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33977 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947AbZCKI52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 04:57:28 -0400
Content-Disposition: inline
In-Reply-To: <20090311.014957.117115597.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2009 at 01:49:57AM -0700, David Miller wrote:
> From: Sascha Hauer <s.hauer@pengutronix.de>
> Date: Wed, 11 Mar 2009 09:44:30 +0100
> 
> > On Tue, Mar 10, 2009 at 09:18:41PM -0700, Stephen Hemminger wrote:
> > > Do you still need this? Only works with one board, configuration via
> > > module parameters is discouraged.  Same effect can be done by setting
> > > mac address with regular tools.
> > 
> > Except for root over nfs. Ok, the answer to this is usually 'use
> > initrd', but this is still a pita on embedded systems.
> 
> Please remove this code.  If we let you do it, we have to let everyone
> else do it too, and that's something we don't want to do.
> 
> There are other ways you can handle this, for example have your board
> firmware properly program the MAC address into the card at power-on,
> and then have the driver here look in the MAC address registers to see
> if a valid ethernet address has been left there.

Cool, that's how I do it on many boards I have, but I always had the
feeling I was flying under the radar with it.

Sascha


-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
