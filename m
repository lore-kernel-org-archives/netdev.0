From: Scott Wood <oss@buserror.net>
Subject: Re: [v7, 0/5] Fix eSDHC host version register bug
Date: Fri, 01 Apr 2016 17:25:43 -0500
Message-ID: <1459549543.32510.28.camel@buserror.net>
References: <1459480051-3701-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ulf.hansson@linaro.org, Zhao Qiang <qiang.zhao@freescale.com>,
	Russell King <linux@arm.linux.org.uk>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	Joerg Roedel <joro@8bytes.org>,
	Santosh Shilimkar <ssantosh@kernel.org>,
	Jochen Friedrich <jochen@scram.de>, scott.wood@nxp.com,
	Rob Herring <robh+dt@kernel.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Kumar Gala <galak@codeaurora.org>, leoyang.li@nxp.com,
	xiaobo.xie@nxp.com
To: Yangbo Lu <yangbo.lu@nxp.com>, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-clk@vger.kernel.org,
	linux-i2c@vger.kernel.org, iommu@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-mmc@vger.kernel.org
Return-path: <linux-clk-owner@vger.kernel.org>
In-Reply-To: <1459480051-3701-1-git-send-email-yangbo.lu@nxp.com>
Sender: linux-clk-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-04-01 at 11:07 +0800, Yangbo Lu wrote:
> This patchset is used to fix a host version register bug in the T4240-R1.0
> -R2.0
> eSDHC controller. To get the SoC version and revision, it's needed to add
> the
> GUTS driver to access the global utilities registers.
> 
> So, the first three patches are to add the GUTS driver.
> The following two patches are to enable GUTS driver support to get SVR in
> eSDHC
> driver and fix host version for T4240.
> 
> Yangbo Lu (5):
>   ARM64: dts: ls2080a: add device configuration node
>   soc: fsl: add GUTS driver for QorIQ platforms
>   dt: move guts devicetree doc out of powerpc directory
>   powerpc/fsl: move mpc85xx.h to include/linux/fsl
>   mmc: sdhci-of-esdhc: fix host version for T4240-R1.0-R2.0

Acked-by: Scott Wood <oss@buserror.net>

-Scott

