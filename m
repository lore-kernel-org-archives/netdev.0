From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Wed, 11 Mar 2009 11:35:08 +0100
Message-ID: <20090311103508.GA425@pengutronix.de>
References: <1236738549-16703-1-git-send-email-yanok@emcraft.com> <20090310211841.388619ca@nehalam> <20090311084430.GU425@pengutronix.de> <20090311.014957.117115597.davem@davemloft.net> <20090311090938.E7BF7832E8B8@gemini.denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	yanok@emcraft.com, linux-arm-kernel@lists.arm.linux.org.uk,
	netdev@vger.kernel.org, dzu@denx.de
To: Wolfgang Denk <wd@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56419 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752676AbZCKKfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 06:35:15 -0400
Content-Disposition: inline
In-Reply-To: <20090311090938.E7BF7832E8B8@gemini.denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wolfgang,

On Wed, Mar 11, 2009 at 10:09:38AM +0100, Wolfgang Denk wrote:
> Dear David,
> 
> on Wed, Mar 11, 2009 at 01:49:57AM -0700, David Miller wrote:
> > From: Sascha Hauer <s.hauer@pengutronix.de>
> > Date: Wed, 11 Mar 2009 09:44:30 +0100
> > 
> > > On Tue, Mar 10, 2009 at 09:18:41PM -0700, Stephen Hemminger wrote:
> > > > Do you still need this? Only works with one board, configuration via
> > > > module parameters is discouraged.  Same effect can be done by setting
> > > > mac address with regular tools.
> > > 
> > > Except for root over nfs. Ok, the answer to this is usually 'use
> > > initrd', but this is still a pita on embedded systems.
> > 
> > Please remove this code.  If we let you do it, we have to let everyone
> > else do it too, and that's something we don't want to do.
> > 
> > There are other ways you can handle this, for example have your board
> > firmware properly program the MAC address into the card at power-on,
> > and then have the driver here look in the MAC address registers to see
> > if a valid ethernet address has been left there.
> 
> How do you then handle situations where this is impossible? Say, when
> the firmware cannot write to those registers for example because  the
> ethernet  controller is not even powered on (to reduce power consump-
> tion), but will get powered on only in Linux  when  the  driver  gets
> loaded (i. e. on demand only, not always)?

I never had this situation, but I guess in this case I have a working
userspace and can use ifconfig to set the MAC address.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
