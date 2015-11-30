From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: fsl: Fix error checking for platform_get_irq()
Date: Mon, 30 Nov 2015 15:20:13 -0500 (EST)
Message-ID: <20151130.152013.2015081413365508776.davem@davemloft.net>
References: <1448539186-5756-1-git-send-email-broonie@kernel.org>
	<1448539186-5756-2-git-send-email-broonie@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: claudiu.manoil@freescale.com, Shaohui.Xie@freescale.com,
	netdev@vger.kernel.org
To: broonie@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33489 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754478AbbK3UUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 15:20:15 -0500
In-Reply-To: <1448539186-5756-2-git-send-email-broonie@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@kernel.org>
Date: Thu, 26 Nov 2015 11:59:46 +0000

> The gianfar driver has recently been enabled on arm64 but fails to build
> since it check the return value of platform_get_irq() against NO_IRQ. Fix
> this by instead checking for a negative error code.
> 
> Even on ARM where this code was previously being built this check was
> incorrect since platform_get_irq() returns a negative error code which
> may not be exactly the (unsigned int)(-1) that NO_IRQ is defined to be.
> 
> Signed-off-by: Mark Brown <broonie@kernel.org>

Applied.
