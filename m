From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/10] can: at91: bugfixes and improvements
Date: Sun, 24 Oct 2010 14:48:33 -0700 (PDT)
Message-ID: <20101024.144833.189709619.davem@davemloft.net>
References: <1287658882-26914-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57094
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758304Ab0JXVsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 17:48:10 -0400
In-Reply-To: <1287658882-26914-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Thu, 21 Oct 2010 13:01:12 +0200

> this series of patches fixes three bugs (CAN_CTRLMODE_3_SAMPLES,
> extended frames, use-after-free), a compiler warning (uninit'ed variable) and
> a section mismatch. Further it add the implementation of the
> do_get_berr_counter callback, the bittiming setting is now done in chip_start.
> As requested by Russell King the driver uses __raw_readl instead of readl.
> 
> The last two patches do some cleanups, they convert dev_<level> printing
> to netdev_<level> and add the KBUILD_MODNAME to the bit timing constant
> to identify the driver.

All applied, thanks.
