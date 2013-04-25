From: Lucas Stach <l.stach@pengutronix.de>
Subject: Re: [PATCH 0/3] URGENT for 3.9: net: fec: revert NAPI introduction
Date: Thu, 25 Apr 2013 14:44:14 +0200
Message-ID: <1366893854.4139.17.camel@weser.hi.pengutronix.de>
References: <1366382164-10968-1-git-send-email-l.stach@pengutronix.de>
	 <20130419.133825.1727571575417364801.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Frank.Li@freescale.com,
	shawn.guo@linaro.org, festevam@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48048 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756759Ab3DYMpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 08:45:23 -0400
In-Reply-To: <20130419.133825.1727571575417364801.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Am Freitag, den 19.04.2013, 13:38 -0400 schrieb David Miller:
> From: Lucas Stach <l.stach@pengutronix.de>
> Date: Fri, 19 Apr 2013 16:36:01 +0200
> 
> > As it's way too late in the cycle to try and fix this up just revert the
> > relevant patches for now.
> 
> I disagree, fix this properly, the revert is more intrusive.

In the last days I've tried to fix the failures I'm seeing with adding
back the locks and disabling NAPI while restarting the controller. Both
approaches are neither minimally intrusive, nor do they fix all the
failures. I suspect there is a subtler error in some of the changed ring
buffer handling code also, but I wasn't able to track this down further
to a specific single-line change.

The only way to reliably fix all the failures I'm seeing is really
reverting the changes, as done with this series. So David please
consider taking the reverts, even while they are a bit intrusive, they
are the only way to get a 3.9 release out of the door with a working FEC
driver.

Regards,
Lucas
-- 
Pengutronix e.K.                           | Lucas Stach                 |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-5076 |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
