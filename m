From: Scott Wood <oss@buserror.net>
Subject: Re: [v9, 6/7] MAINTAINERS: add entry for Freescale SoC driver
Date: Wed, 04 May 2016 12:35:08 -0500
Message-ID: <1462383308.16584.43.camel@buserror.net>
References: <1462332274-13744-1-git-send-email-yangbo.lu@nxp.com>
	 <1462332274-13744-7-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ulf.hansson@linaro.org, Mark Rutland <mark.rutland@arm.com>,
	Rob Herring <robh+dt@kernel.org>,
	Russell King <linux@arm.linux.org.uk>,
	Jochen Friedrich <jochen@scram.de>,
	Joerg Roedel <joro@8bytes.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	Qiang Zhao <qiang.zhao@nxp.com>,
	Kumar Gala <galak@codeaurora.org>,
	Santosh Shilimkar <ssantosh@kernel.org>, leoyang.li@nxp.com,
	xiaobo.xie@nxp.com
To: Yangbo Lu <yangbo.lu@nxp.com>, linux-mmc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-clk@vger.kernel.org, linux-i2c@vger.kernel.org,
	iommu@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <1462332274-13744-7-git-send-email-yangbo.lu@nxp.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-05-04 at 11:24 +0800, Yangbo Lu wrote:
> Add maintainer entry for Freescale SoC driver including
> the QE library and the GUTS driver now. Also add maintainer
> for QE library.
> 
> Signed-off-by: Yangbo Lu <yangbo.lu@nxp.com>
> ---
> Changes for v8:
> 	- Added this patch
> Changes for v9:
> 	- Added linux-arm mail list
> 	- Removed GUTS driver entry
> ---
>  MAINTAINERS | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 42e65d1..ce91db7 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -4622,9 +4622,18 @@ F:	drivers/net/ethernet/freescale/fec_ptp.c
>  F:	drivers/net/ethernet/freescale/fec.h
>  F:	Documentation/devicetree/bindings/net/fsl-fec.txt
>  
> +FREESCALE SOC DRIVER
> +M:	Scott Wood <oss@buserror.net>
> +L:	linuxppc-dev@lists.ozlabs.org
> +L:	linux-arm-kernel@lists.infradead.org
> +S:	Maintained
> +F:	drivers/soc/fsl/
> +F:	include/linux/fsl/
> +
>  FREESCALE QUICC ENGINE LIBRARY
> +M:	Qiang Zhao <qiang.zhao@nxp.com>
>  L:	linuxppc-dev@lists.ozlabs.org
> -S:	Orphan
> +S:	Maintained
>  F:	drivers/soc/fsl/qe/
>  F:	include/soc/fsl/*qe*.h
>  F:	include/soc/fsl/*ucc*.h

s/DRIVER/DRIVERS/

There's more than one.

Otherwise:
Acked-by: Scott Wood <oss@buserror.net>

-Scott

> 
