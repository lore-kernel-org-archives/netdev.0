From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH-V2 0/4] ARM: AM33XX: net: Add DT support to CPGMAC and
 MDIO driver
Date: Mon, 29 Oct 2012 09:33:29 +0100
Message-ID: <20121029083329.GD2527@netboy.at.omicron.at>
References: <1351498881-32482-1-git-send-email-hvaibhav@ti.com>
 <1351498881-32482-2-git-send-email-hvaibhav@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, paul@pwsan.com,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org
To: Vaibhav Hiremath <hvaibhav@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1351498881-32482-2-git-send-email-hvaibhav@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 29, 2012 at 01:51:17PM +0530, Vaibhav Hiremath wrote:
> This patch-series adds support for,
> 
> [1/4]: Typo mistake in CPSW driver while invoking runtime_pm api's
> 
> [2/4]: Adds parent<->child relation between CPSW & MDIO module inside cpsw
>        driver, as in case of AM33XX, the resources are shared and common
>        register bit-field is provided to control module/clock enable/disable,
>        makes it difficult to handle common resource.
> 
>        So the solution here is, to create parent<->child relation between them.
> 
> [3/4]: Add hwmod entry for MDIO module, required for MDIO driver.
> 
> [4/4]: Add DT device nodes for both CPSW and MDIO modules in am33xx.dtsi,
> 	am335x-evm.dts and am335x-bone.dts file

Many Thanks!

Acked-by: Richard Cochran <richardcochran@gmail.com>
