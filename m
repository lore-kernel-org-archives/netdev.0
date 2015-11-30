From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH V5 net-next 1/5] net:hns: Add support of Hip06 SoC to
 the Hislicon Network Subsystem
Date: Mon, 30 Nov 2015 14:50:57 -0500 (EST)
Message-ID: <20151130.145057.216796732457000987.davem@davemloft.net>
References: <1448522050-5576-1-git-send-email-salil.mehta@huawei.com>
	<1448522050-5576-2-git-send-email-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org,
	galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
	arnd-r2nGTMty4D4@public.gmane.org, liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, kenneth-lee-2012-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org,
	mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org,
	lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1448522050-5576-2-git-send-email-salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Date: Thu, 26 Nov 2015 07:14:06 +0000

> -#define ENABLE		(0x1)
> -#define DISABLE		(0x0)
> +#define ENABLE		0x1
> +#define DISABLE		0x0

Defining such common macros names for such incredibly simple boolean values
is asking for trouble, in particular it can possibly collide with other
defines in the global namespace.

Use "true", "false", and the "bool" type, because that is exactly how you
are using these values.

Thanks.


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
