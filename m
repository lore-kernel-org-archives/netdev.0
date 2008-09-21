From: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware restart.
Date: Mon, 22 Sep 2008 00:57:06 +0400
Message-ID: <20080921205706.GA24545@2ka.mipt.ru>
References: <20080921172316.GA6306@2ka.mipt.ru> <20080921110422.1d010b96@infradead.org> <20080921182835.GA11473@2ka.mipt.ru> <20080921113513.16677c4e@infradead.org> <20080921190050.GA20484@2ka.mipt.ru> <1222024444.3023.53.camel@johannes.berg> <20080921193809.GA8735@2ka.mipt.ru> <20080921124332.67ddc13a@infradead.org> <20080921202057.GB25052@2ka.mipt.ru> <20080921132753.5689b564@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080921132753.5689b564-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 21, 2008 at 01:27:53PM -0700, Arjan van de Ven (arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org) wrote:
> > Well, I actually wanted to have a bug there because of it, but now I
> > think that annoying repeated warning is enough to bring attention to
> > the problem by putting bug information into some magic special place
> > called kerneloops collection.
> 
> are you more interested in bringing attention than finding something
> that makes the driver work ? I sort of am getting that impression and
> I'd be disappointed if that is the case.
 
I do think that it can not be fixed without serious intervention of the
Intel (hardware) folks, since bug exists more than 4 years in two
firmwares and lots of very different driver versions and was reproduced
even on 2.4 kernel.

I will experiment with reloading issues as Alan suggested and to
add/remove more surgery into initialization process to be allowed to
'workaround' the issue, since it looks noone else will.

But that's definitely not a fix and in my personal workaround's 10
degrees shit'o'meter this lies around 12.
 
> > Consider for inclusing for the upcoming kernel to get wider
> > notifications. Yes, it is not a bugfix, I know.
> 
> still more complex than needed; a WARN_ON_ONCE() will be enough.

That allows to dump whatever number of warnings you want. The more we
have, the louder will be customers scream.

-- 
	Evgeniy Polyakov
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
