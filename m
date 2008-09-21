From: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware restart.
Date: Mon, 22 Sep 2008 00:26:56 +0400
Message-ID: <20080921202656.GC25052@2ka.mipt.ru>
References: <20080921172316.GA6306@2ka.mipt.ru> <20080921110422.1d010b96@infradead.org> <20080921182835.GA11473@2ka.mipt.ru> <20080921113513.16677c4e@infradead.org> <20080921190050.GA20484@2ka.mipt.ru> <1222024444.3023.53.camel@johannes.berg> <20080921193809.GA8735@2ka.mipt.ru> <20080921200518.GK7736@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080921200518.GK7736@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 22, 2008 at 12:05:18AM +0400, Cyrill Gorcunov (gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
> Since it's that serious maybe we should change
> 
> 		IPW_DEBUG_INFO("%s: Fatal error value: 0x%08X\n",
> 			       priv->net_dev->name, priv->fatal_error);
> 
> to printk(KERN_WARN)? And here is why - as I see now we can't say what
> exactly is wrong - Evgeniy said he has a suspicious about firmware so
> this WARNS will be collected by Arjan thru kerneloops and we could not
> ask users to change debug level and repost problem - oops will have it
> by default - and if it really firmware problem - firmware engineers could
> find this _additional_ info usefull and resolve it (probably).

The only reason for this change is to make a mark at the kerneloops.
I.e. users know, there is a bug. Developers know, there is a bug.
Everyone knows that there is a bug, but until it is at the special place
we look to each other just like there is no bug.

Here are dumps for example:
http://www.intellinuxwireless.org/bugzilla/show_bug.cgi?id=245

Bug existed even with 1.2 firmware and .11 kernel.
Intel, that's a great marketing slogan: stability everywhere!

-- 
	Evgeniy Polyakov
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
