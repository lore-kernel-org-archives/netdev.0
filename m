From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH RESEND net-next 3/3] arm64: hip05-d02: Document devicetree bindings for Hisilicon D02 Board
Date: Sat, 05 Dec 2015 23:13:21 +0100
Message-ID: <2441219.omPQqZs8vd@wuerfel>
References: <1449302218-54374-1-git-send-email-yankejian@huawei.com> <1449302218-54374-4-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org,
	galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org,
	catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
	wangkefeng.wang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	haojian.zhuang-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, wangzhou1-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org,
	bintian.wang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, long.wanglong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	leo.yan-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: yankejian <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1449302218-54374-4-git-send-email-yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 05 December 2015 15:56:58 yankejian wrote:
> +Required properties:
> +- compatible : "hisilicon,peri-c-subctrl", "syscon";
> +- reg : Register address and size
> +
> +The HiP05 PERISUB system controller is shared by peripheral controllers in
> +HiP05 Soc to implement some basic configurations. the peripheral
> + controllers include mdio, ddr, iic, uart, timer and so on.
> +
> +Example:
> +       /* for HiP05 PCIe-SAS system */
> +       pcie_sas: system_controller@0xb0000000 {
> +               compatible = "hisilicon,pcie-sas-subctrl", "syscon";
> +               reg = <0xb0000000 0x10000>;
> +       };
> 

The compatible string in the example does not match the required properties.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
