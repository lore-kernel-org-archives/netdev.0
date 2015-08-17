From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/5] net: add Hisilicon Network Subsystem hnae
 framework support
Date: Mon, 17 Aug 2015 12:25:48 -0700 (PDT)
Message-ID: <20150817.122548.203456335027850542.davem@davemloft.net>
References: <1439548222-231611-1-git-send-email-liguozhu@hisilicon.com>
	<1439548222-231611-3-git-send-email-liguozhu@hisilicon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
	Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org,
	dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1439548222-231611-3-git-send-email-liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kenneth Lee <liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Date: Fri, 14 Aug 2015 18:30:19 +0800

> diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
> new file mode 100644
> index 0000000..fd09768
> --- /dev/null
> +++ b/drivers/net/ethernet/hisilicon/hns/hnae.c
 ...
> +static inline void hnae_list_add(spinlock_t *lock, struct list_head *node,
> +				 struct list_head *head)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(lock, flags);
> +	list_add_tail_rcu(node, head);
> +	spin_unlock_irqrestore(lock, flags);
> +}

Do not declare functions 'inline' in foo.c files, let the compiler decide
on it's own.

This applies to your entire patch series.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
