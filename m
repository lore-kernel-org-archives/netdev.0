From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [v8, 1/7] Documentation: DT: update Freescale DCFG compatible
Date: Fri, 22 Apr 2016 14:11:51 +0100
Message-ID: <20160422131151.GJ10606@leverpostej>
References: <1461306464-19521-1-git-send-email-yangbo.lu@nxp.com>
 <1461306464-19521-2-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mmc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, linux-clk@vger.kernel.org,
	linux-i2c@vger.kernel.org, iommu@lists.linux-foundation.org,
	netdev@vger.kernel.org, ulf.hansson@linaro.org, scott.wood@nxp.com,
	Rob Herring <robh+dt@kernel.org>,
	Russell King <linux@arm.linux.org.uk>,
	Jochen Friedrich <jochen@scram.de>,
	Joerg Roedel <joro@8bytes.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	Zhao Qiang <qiang.zhao@freescale.com>,
	Kumar Gala <galak@codeaurora.org>,
	Santosh Shilimkar <ssantosh@kernel.org>, leoyang.li@nxp.com,
	xiaobo.xie@nxp.com
To: Yangbo Lu <yangbo.lu@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:34089 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752923AbcDVNL6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 09:11:58 -0400
Content-Disposition: inline
In-Reply-To: <1461306464-19521-2-git-send-email-yangbo.lu@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 22, 2016 at 02:27:38PM +0800, Yangbo Lu wrote:
> Update Freescale DCFG compatible with 'fsl,<chip>-dcfg' instead
> of 'fsl,ls1021a-dcfg' to include more chips.
> 
> Signed-off-by: Yangbo Lu <yangbo.lu@nxp.com>
> ---
> Changes for v8:
> 	- Added this patch
> ---
>  Documentation/devicetree/bindings/arm/fsl.txt | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/Documentation/devicetree/bindings/arm/fsl.txt b/Documentation/devicetree/bindings/arm/fsl.txt
> index 752a685..1d5f512 100644
> --- a/Documentation/devicetree/bindings/arm/fsl.txt
> +++ b/Documentation/devicetree/bindings/arm/fsl.txt
> @@ -119,7 +119,7 @@ Freescale DCFG
>  configuration and status for the device. Such as setting the secondary
>  core start address and release the secondary core from holdoff and startup.
>    Required properties:
> -  - compatible: should be "fsl,ls1021a-dcfg"
> +  - compatible: should be "fsl,<chip>-dcfg"

Please list specific values expected for <chip>, while jusy saying
<chip> may be more generic, it makes it practically impossible to search
for the correct binding given a compatible string, and it's vague as to
exaclty what <chip> should be.

Thanks,
Mark.



>    - reg : should contain base address and length of DCFG memory-mapped registers
>  
>  Example:
> -- 
> 2.1.0.27.g96db324
> 
> --
> To unsubscribe from this list: send the line "unsubscribe devicetree" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
