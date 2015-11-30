From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: fsl: Don't use NO_IRQ to check return value
 of irq_of_parse_and_map()
Date: Mon, 30 Nov 2015 15:20:07 -0500 (EST)
Message-ID: <20151130.152007.1841592572513563445.davem@davemloft.net>
References: <1448539186-5756-1-git-send-email-broonie@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: claudiu.manoil@freescale.com, Shaohui.Xie@freescale.com,
	netdev@vger.kernel.org
To: broonie@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33481 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691AbbK3UUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 15:20:09 -0500
In-Reply-To: <1448539186-5756-1-git-send-email-broonie@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@kernel.org>
Date: Thu, 26 Nov 2015 11:59:45 +0000

> This driver can be built on arm64 but relies on NO_IRQ to check the return
> value of irq_of_parse_and_map() which fails to build on arm64 because the
> architecture does not provide a NO_IRQ. Fix this to correctly check the
> return value of irq_of_parse_and_map().
> 
> Even on ARM systems where the driver was previously used the check was
> broken since on ARM NO_IRQ is -1 but irq_of_parse_and_map() returns 0 on
> error.
> 
> Signed-off-by: Mark Brown <broonie@kernel.org>

Applied.
