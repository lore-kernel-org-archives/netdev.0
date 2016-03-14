From: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Subject: RE: [v6, 5/5] mmc: sdhci-of-esdhc: fix host version for
	T4240-R1.0-R2.0
Date: Mon, 14 Mar 2016 07:29:26 +0000
Message-ID: <HE1PR04MB0889CE4742B92461A925B9C4F8880@HE1PR04MB0889.eurprd04.prod.outlook.com>
References: <1457518131-11339-1-git-send-email-yangbo.lu@nxp.com>
	<1457518131-11339-6-git-send-email-yangbo.lu@nxp.com>
	<4947024.WeMycs2fID@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Zhao Qiang <qiang.zhao-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Bhupesh Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Scott Wood <scott.wood-3arQi8VN3Tc@public.gmane.org>,
	"iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Claudiu
	Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Yang-Leo Li <leoyang.li-3arQi8VN3Tc@public.gmane.org>,
	Xiaobo Xie <xiaobo.xie-3arQi8VN3Tc@public.gmane.org>,
	"linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWOunwaRDDq4rA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, "linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org"
	<linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4947024.WeMycs2fID@wuerfel>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Arnd Bergmann [mailto:arnd-r2nGTMty4D4@public.gmane.org]
> Sent: Monday, March 14, 2016 6:26 AM
> To: linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
> Cc: Yangbo Lu; devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-arm-
> kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-
> clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; iommu-cunTk1MwBs/ROKNJybVBZg@public.gmane.org
> foundation.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org; Zhao Qiang; Russell King; Bhupesh Sharma; Joerg
> Roedel; Santosh Shilimkar; Scott Wood; Rob Herring; Claudiu Manoil; Kumar
> Gala; Yang-Leo Li; Xiaobo Xie
> Subject: Re: [v6, 5/5] mmc: sdhci-of-esdhc: fix host version for T4240-
> R1.0-R2.0
> 
> On Wednesday 09 March 2016 18:08:51 Yangbo Lu wrote:
> > @@ -567,10 +580,20 @@ static void esdhc_init(struct platform_device
> *pdev, struct sdhci_host *host)
> >         struct sdhci_pltfm_host *pltfm_host;
> >         struct sdhci_esdhc *esdhc;
> >         u16 host_ver;
> > +       u32 svr;
> >
> >         pltfm_host = sdhci_priv(host);
> >         esdhc = sdhci_pltfm_priv(pltfm_host);
> >
> > +       fsl_guts_init();
> > +       svr = fsl_guts_get_svr();
> > +       if (svr) {
> > +               esdhc->soc_ver = SVR_SOC_VER(svr);
> > +               esdhc->soc_rev = SVR_REV(svr);
> > +       } else {
> > +               dev_err(&pdev->dev, "Failed to get SVR value!\n");
> > +       }
> > +
> 
> This makes the driver non-portable. Better identify the specific
> workarounds based on the compatible string for this device, or add a
> boolean DT property for the quirk.
> 
> 	Arnd

[Lu Yangbo-B47093] Hi Arnd, we did have a discussion about using DTS in v1 before.
https://patchwork.kernel.org/patch/6834221/

We don't have a separate DTS file for each revision of an SOC and if we did, we'd constantly have people using the wrong one.
In addition, the device tree is stable ABI and errata are often discovered after device tree are deployed.
See the link for details.

So we decide to read SVR from the device-config/guts MMIO block other than using DTS.
Thanks.
