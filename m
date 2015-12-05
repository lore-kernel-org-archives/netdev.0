From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH RESEND net-next 2/3] dts: hisi: fixes no syscon error when init mdio
Date: Sat, 05 Dec 2015 23:15:07 +0100
Message-ID: <5330584.WSWh7F8G32@wuerfel>
References: <1449302218-54374-1-git-send-email-yankejian@huawei.com> <1449302218-54374-3-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: yankejian <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
	wangkefeng.wang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	haojian.zhuang-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, wangzhou1-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org,
	bintian.wang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, long.wanglong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	leo.yan-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1449302218-54374-3-git-send-email-yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 05 December 2015 15:56:57 yankejian wrote:
>                 #size-cells = <0>;
>                 compatible = "hisilicon,hns-mdio";
> -               reg = <0x0 0x803c0000 0x0 0x10000
> -                      0x0 0x80000000 0x0 0x10000>;
> +               reg = <0x0 0x803c0000 0x0 0x10000>;
> +               subctrl_vbase = <&peri_c_subctrl>;
>  
>                 soc0_phy0: ethernet-phy@0 {
>                         reg = <0x0>;

I don't see the subctrl_vbase property documented in the binding. Please
modify the binding as well.

Also, please use the normal naming conventions using '-' instead of '_'
inside of property names.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
