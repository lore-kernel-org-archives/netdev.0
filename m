From: David Miller <davem@davemloft.net>
Subject: Re: [Patch v2 resend 1/2] net: fec: use managed DMA API functions
 to allocate BD ring
Date: Sun, 26 Jul 2015 21:52:03 -0700 (PDT)
Message-ID: <20150726.215203.263400958239850514.davem@davemloft.net>
References: <1437660380-21164-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@freescale.com, Frank.Li@freescale.com,
	netdev@vger.kernel.org, patchwork-lst@pengutronix.de
To: l.stach@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbbG0EwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 00:52:05 -0400
In-Reply-To: <1437660380-21164-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Stach <l.stach@pengutronix.de>
Date: Thu, 23 Jul 2015 16:06:19 +0200

> So it gets freed when the device is going away.
> This fixes a DMA memory leak on driver probe() fail and driver
> remove().
> 
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> ---
> v2: Fix indentation of second line to fix alignment with opening bracket.

Applied.
