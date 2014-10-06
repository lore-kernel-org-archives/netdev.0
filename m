From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/phy/Kconfig: Let MDIO_BCM_UNIMAC depend on
 HAS_IOMEM
Date: Mon, 06 Oct 2014 00:46:46 -0400 (EDT)
Message-ID: <20141006.004646.685997864382345892.davem@davemloft.net>
References: <542FC3D9.4080607@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, richard@nod.at
To: gang.chen.5i5j@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57805 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855AbaJFEqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 00:46:48 -0400
In-Reply-To: <542FC3D9.4080607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Gang <gang.chen.5i5j@gmail.com>
Date: Sat, 04 Oct 2014 17:54:33 +0800

> MDIO_BCM_UNIMAC needs HAS_IOMEM, so depend on it, the related error (
> with allmodconfig under um):
> 
>     MODPOST 1205 modules
>   ERROR: "devm_ioremap" [drivers/net/phy/mdio-bcm-unimac.ko] undefined!
> 
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>

Applied, thanks.
