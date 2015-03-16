From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [v2] net/fsl: modify xgmac_mdio for little endian
 SoCs
Date: Mon, 16 Mar 2015 16:28:09 -0400 (EDT)
Message-ID: <20150316.162809.1507330201701233389.davem@davemloft.net>
References: <1426503389-23228-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37658 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933204AbbCPU2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 16:28:12 -0400
In-Reply-To: <1426503389-23228-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Mon, 16 Mar 2015 18:56:29 +0800

> From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> MDIO controller on little endian Socs, e.g. ls2085a is similar to the
> controller on big endian Socs, but the MDIO access is little endian,
> we use I/O accessor function to handle endianness, so the driver can
> run on little endian Socs. A property "little-endian" is used
> in DTS to indicate the MDIO is little endian, if driver probes the
> property, driver will access MDIO in little endian, otherwise, driver
> works in big endian by default.
> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
> ---
> changes for v2:
> 1. use "little-endian" which is documented in
> Documentation/devicetree/bindings/regmap/regmap.txt
> 2. splitted bug fix into another patch.

Also applied to net-next
