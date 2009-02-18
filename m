From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 0/2] fec: move ColdFire setup code out of FEC driver
Date: Wed, 18 Feb 2009 17:42:57 +0100
Message-ID: <20090218164257.GI2089@pengutronix.de>
References: <200902170053.n1H0r1WP002062@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gerg@uclinux.org, netdev@vger.kernel.org
To: Greg Ungerer <gerg@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52094 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753281AbZBRQnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 11:43:05 -0500
Content-Disposition: inline
In-Reply-To: <200902170053.n1H0r1WP002062@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

On Tue, Feb 17, 2009 at 10:53:01AM +1000, Greg Ungerer wrote:
> 
> Hi Sascha,
> 
> The following 2 patches move the ColdFire specific FEC setup code
> into the ColdFire CPU platform setup code.

Looks good to me, though I can't apply them. To which tree should
they apply?

> 
> There is still a little remaining legacy code that needs taking
> care of in fec.c. The flash reading MAC setup code and the MII
> link interrupts of the 5272 are still in there.

maybe the board setup code could copy the MAC Address from the
flash directly to the device. The driver will pick it up from
there.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
