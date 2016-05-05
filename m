From: Qiang Zhao <qiang.zhao@nxp.com>
Subject: RE: [v9, 6/7] MAINTAINERS: add entry for Freescale SoC driver
Date: Thu, 5 May 2016 02:31:27 +0000
Message-ID: <AM3PR04MB1185B5352C395FE8951CA5A5917C0@AM3PR04MB1185.eurprd04.prod.outlook.com>
References: <1462332274-13744-1-git-send-email-yangbo.lu@nxp.com>
 <1462332274-13744-7-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
 "ulf.hansson@linaro.org" <ulf.hansson@linaro.org>,
 Russell King <linux@arm.linux.org.uk>, Yangbo Lu <yangbo.lu@nxp.com>,
 Bhupesh Sharma <bhupesh.sharma@freescale.com>, Joerg Roedel <joro@8bytes.org>,
 Santosh
 Shilimkar <ssantosh@kernel.org>, Jochen Friedrich <jochen@scram.de>,
 Yang-Leo Li <leoyang.li@nxp.com>, Scott Wood <oss@buserror.net>,
 Rob Herring <robh+dt@kernel.org>,
 Claudiu Manoil <claudiu.manoil@freescale.com>,
 Kumar Gala <galak@codeaurora.org>, Xiaobo Xie <xiaobo.xie@nxp.com>
To: Yangbo Lu <yangbo.lu@nxp.com>, "linux-mmc@vger.kernel.org"
 <linux-mmc@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org"
 <linuxppc-dev@lists.ozlabs.org>, "devicetree@vger.kernel.org"
 <devicetree@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, "linux-clk@vger.kernel.org"
 <linux-clk@vger.kernel.org>, "linux-i2c@vger.kernel.org"
 <linux-i2c@vger.kernel.org>, "iommu@lists.linux-foundation.org"
 <iommu@lists.linux-foundation.org>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1462332274-13744-7-git-send-email-yangbo.lu@nxp.com>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-05-04 at 11:24 +0800, Yangbo Lu wrote:
> -----Original Message-----
> From: Yangbo Lu [mailto:yangbo.lu@nxp.com]
> Sent: Wednesday, May 04, 2016 11:25 AM
> To: linux-mmc@vger.kernel.org; linuxppc-dev@lists.ozlabs.org;
> devicetree@vger.kernel.org; linux-arm-kernel@lists.infradead.org; linux-
> kernel@vger.kernel.org; linux-clk@vger.kernel.org; linux-i2c@vger.kernel.org;
> iommu@lists.linux-foundation.org; netdev@vger.kernel.org
> Cc: ulf.hansson@linaro.org; Scott Wood <oss@buserror.net>; Mark Rutland
> <mark.rutland@arm.com>; Rob Herring <robh+dt@kernel.org>; Russell King
> <linux@arm.linux.org.uk>; Jochen Friedrich <jochen@scram.de>; Joerg Roedel
> <joro@8bytes.org>; Claudiu Manoil <claudiu.manoil@freescale.com>; Bhupesh
> Sharma <bhupesh.sharma@freescale.com>; Qiang Zhao
> <qiang.zhao@nxp.com>; Kumar Gala <galak@codeaurora.org>; Santosh
> Shilimkar <ssantosh@kernel.org>; Yang-Leo Li <leoyang.li@nxp.com>; Xiaobo
> Xie <xiaobo.xie@nxp.com>; Yangbo Lu <yangbo.lu@nxp.com>
> Subject: [v9, 6/7] MAINTAINERS: add entry for Freescale SoC driver
> 
> Add maintainer entry for Freescale SoC driver including the QE library and the
> GUTS driver now. Also add maintainer for QE library.
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
> --
> 2.1.0.27.g96db324

I am ok!

-Zhao Qiang
