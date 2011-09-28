From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: about bmac/mace/macmace/mac89x0/cs89x0: Move the Macintosh (Apple)
 drivers
Date: Wed, 28 Sep 2011 09:04:39 +0200
Message-ID: <20110928070439.GV31404@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>,
	Russell Nelson <nelson@crynwr.com>, netdev@vger.kernel.org,
	davem@davemloft.net,
	Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:43708 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928Ab1I1HE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2011 03:04:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> commit 8fb6b0908176704a3ea22005e8a9fa3ebf35b5be
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Mon May 16 01:39:01 2011 -0700
>
>    bmac/mace/macmace/mac89x0/cs89x0: Move the Macintosh (Apple) drivers
>
>    Move the Apple drivers into driver/net/ethernet/apple/ and make the
>    necessary Kconfig and Makefile changes.

This commit moves drivers/net/cs89x0.[ch] to drivers/net/ethernet/apple/.

This is wrong. The cs89x0 driver is a general ISA driver and is also
used on some embedded boards. This patch should only move drivers/net/mac89x0.c
which basically is a driver for the same device but used on Macintosh.

I think it should go to drivers/net/ethernet/cirrus instead.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
