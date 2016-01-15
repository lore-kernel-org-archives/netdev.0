From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [patch v3 net-next 1/2] dts: hisi: fixes no syscon fault when
 init mdio
Date: Thu, 14 Jan 2016 20:17:18 -0600
Message-ID: <20160115021718.GA24459@rob-hp-laptop>
References: <1452668999-443-1-git-send-email-yankejian@huawei.com>
 <1452668999-443-2-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
	f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	haojian.zhuang-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, wangzhou1-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org,
	bintian.wang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, long.wanglong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	leo.yan-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Kejian Yan <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1452668999-443-2-git-send-email-yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 13, 2016 at 03:09:58PM +0800, Kejian Yan wrote:
> When linux start up, we get the log below:
> "Hi-HNS_MDIO 803c0000.mdio: no syscon hisilicon,peri-c-subctrl
> mdio_bus mdio@803c0000: mdio sys ctl reg has not maped"
> 
> The source code about the subctrl is dealt syscon, but dts doesn't.
> It cause such fault, so this patch adds the syscon info on dts files to
> fixes it.
> 
> Signed-off-by: Kejian Yan <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
> change log:
> v3:
>  1) uses capital letter at the beginning of sentences
>  2) updates the right device node name
> 
> v2:
>  1) updates the related documented in the binding as well
>  2) uses the normal naming conventions using '-' instead of '_'
> 
> v1:
>  first submit
> 
> v2 patch link: https://lkml.org/lkml/2015/12/7/80
> v1 patch link: https://lkml.org/lkml/2015/11/28/3
> ---
>  .../devicetree/bindings/arm/hisilicon/hisilicon.txt      | 16 ++++++++++++++++
>  arch/arm64/boot/dts/hisilicon/hip05.dtsi                 |  5 +++++
>  arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi             |  4 ++--
>  3 files changed, 23 insertions(+), 2 deletions(-)

Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
