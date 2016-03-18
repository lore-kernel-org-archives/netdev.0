From: Scott Wood <scott.wood@nxp.com>
Subject: Re: [v6, 2/5] soc: fsl: add GUTS driver for QorIQ platforms
Date: Fri, 18 Mar 2016 22:54:46 +0000
Message-ID: <DB5PR0401MB1928302BB0DDE8D9B47E4361918C0@DB5PR0401MB1928.eurprd04.prod.outlook.com>
References: <1457518131-11339-1-git-send-email-yangbo.lu@nxp.com>
 <1457518131-11339-3-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Rob Herring <robh+dt@kernel.org>,
	Russell King <linux@arm.linux.org.uk>,
	Jochen Friedrich <jochen@scram.de>,
	Joerg Roedel <joro@8bytes.org>,
	"Claudiu Manoil" <claudiu.manoil@freescale.com>,
	"ulf.hansson@linaro.org" <ulf.hansson@linaro.org>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	"Zhao Qiang" <qiang.zhao@freescale.com>,
	Kumar Gala <galak@codeaurora.org>,
	"Santosh Shilimkar" <ssantosh@kernel.org>,
	Yang-Leo Li <leoyang.li@nxp.com>,
	Xiaobo Xie <xiaobo.xie@nxp.com>
To: Yangbo Lu <yangbo.lu@nxp.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-clk@vger.kernel.org" <linux-clk@vger.kernel.org>,
	"linux-i2c@vger.kernel.org" <linux-i2c@vger.kernel.org>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0060.outbound.protection.outlook.com ([157.55.234.60]:64326
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751350AbcCRWyv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 18:54:51 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/09/2016 04:18 AM, Yangbo Lu wrote:
> +#ifdef CONFIG_FSL_GUTS
> +u32 fsl_guts_get_svr(void);
> +int fsl_guts_init(void);
> +#endif

Don't ifdef prototypes (when not providing a stub alternative).

-Scott
