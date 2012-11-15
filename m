From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V5 0/7] ARM: AM33XX: net: Add DT support to CPSW and
 MDIO driver
Date: Wed, 14 Nov 2012 22:09:31 -0500 (EST)
Message-ID: <20121114.220931.785168143706732441.davem@davemloft.net>
References: <1352920080-6179-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	b-cousson@ti.com, paul@pwsan.com
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38820 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933136Ab2KODJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 22:09:33 -0500
In-Reply-To: <1352920080-6179-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Thu, 15 Nov 2012 00:37:53 +0530

> This patch-series adds support for,
> 
> [1/7]: Typo mistake in CPSW driver while invoking runtime_pm api's
> 
> [2/7]: Adds parent<->child relation between CPSW & MDIO module inside cpsw
>        driver, as in case of AM33XX, the resources are shared and common
>        register bit-field is provided to control module/clock enable/disable,
>        makes it difficult to handle common resource.
> 
>        So the solution here is, to create parent<->child relation between them.
> 
> [3/7]: cpsw: simplify the setup of the register pointers
> 
> [4/7]: cpsw: Kernel warn fix during suspend
> 
> [5/7]: Add hwmod entry for MDIO module, required for MDIO driver.
> 
> [6/7]: Enable CPSW support to omap2plus_defconfig
> 
> [7/7]: Add DT device nodes for both CPSW and MDIO modules in am33xx.dtsi,
>        am335x-evm.dts and am335x-bone.dts file
> 
> This patch series has been created on top of net-next/master and tested
> on BeagleBone platform for NFS boot and basic ping test cases.

All applied, thanks.
