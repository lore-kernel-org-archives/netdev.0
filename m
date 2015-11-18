From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH V2 net-next 1/5] net:hns: Add support of Hip06 SoC to
 the Hislicon Network Subsystem
Date: Wed, 18 Nov 2015 13:52:50 -0500 (EST)
Message-ID: <20151118.135250.2066223916643044258.davem@davemloft.net>
References: <1447786347-147518-1-git-send-email-salil.mehta@huawei.com>
	<1447786347-147518-2-git-send-email-salil.mehta@huawei.com>
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
In-Reply-To: <1447786347-147518-2-git-send-email-salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Salil <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Date: Wed, 18 Nov 2015 02:52:23 +0800

> @@ -387,19 +409,23 @@ static void hns_rcb_ring_get_cfg(struct hnae_queue *q, int ring_type)
>  	struct rcb_common_cb *rcb_common;
>  	struct ring_pair_cb *ring_pair_cb;
>  	u32 buf_size;
> -	u16 desc_num;
> -	int irq_idx;
> +	u16 desc_num, mdnum_ppkt;
> +	int irq_idx, is_ver1;

Please use "bool" and true/false for boolean conditions like is_ver1.

Please audit your entire submission for this problem.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
