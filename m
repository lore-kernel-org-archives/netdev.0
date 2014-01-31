From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC PATCH] net: wireless: move regulatory timeout work to power
 efficient workqueue
Date: Fri, 31 Jan 2014 04:35:31 -0500
Message-ID: <20140131093531.GA25559@mtj.dyndns.org>
References: <1391123310-6425-1-git-send-email-zoran.markovic@linaro.org>
 <1391160084.4141.1.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zoran Markovic <zoran.markovic-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Shaibal Dutta <shaibal.dutta-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1391160084.4141.1.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

On Fri, Jan 31, 2014 at 10:21:24AM +0100, Johannes Berg wrote:
> I'm not sure if this is part of a larger patchset actually adding that
> "system_power_efficient_wq", but maybe it'd be better to expose a
> function as an API rather than the wq struct?
> 
> Something like
> 
> scheduled_delayed_work_pwr_efficient(...)?

While there are some benefits to using dedicated functions for
specific workqueues, I don't think it brings enough benefits to
justify adding dedicated API and am unlikely to add new ones.

Thanks.

-- 
tejun
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
