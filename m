From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Wed, 11 Mar 2009 01:49:57 -0700 (PDT)
Message-ID: <20090311.014957.117115597.davem@davemloft.net>
References: <1236738549-16703-1-git-send-email-yanok@emcraft.com>
	<20090310211841.388619ca@nehalam>
	<20090311084430.GU425@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: s.hauer@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36559
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751803AbZCKIuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 04:50:12 -0400
In-Reply-To: <20090311084430.GU425@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hauer <s.hauer@pengutronix.de>
Date: Wed, 11 Mar 2009 09:44:30 +0100

> On Tue, Mar 10, 2009 at 09:18:41PM -0700, Stephen Hemminger wrote:
> > Do you still need this? Only works with one board, configuration via
> > module parameters is discouraged.  Same effect can be done by setting
> > mac address with regular tools.
> 
> Except for root over nfs. Ok, the answer to this is usually 'use
> initrd', but this is still a pita on embedded systems.

Please remove this code.  If we let you do it, we have to let everyone
else do it too, and that's something we don't want to do.

There are other ways you can handle this, for example have your board
firmware properly program the MAC address into the card at power-on,
and then have the driver here look in the MAC address registers to see
if a valid ethernet address has been left there.
