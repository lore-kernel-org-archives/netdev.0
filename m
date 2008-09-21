From: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware restart.
Date: Mon, 22 Sep 2008 03:44:03 +0400
Message-ID: <20080921234403.GA17946@2ka.mipt.ru>
References: <20080921182835.GA11473@2ka.mipt.ru> <20080921113513.16677c4e@infradead.org> <20080921190050.GA20484@2ka.mipt.ru> <1222024444.3023.53.camel@johannes.berg> <20080921193809.GA8735@2ka.mipt.ru> <20080921124332.67ddc13a@infradead.org> <20080921202057.GB25052@2ka.mipt.ru> <20080921132753.5689b564@infradead.org> <20080921205706.GA24545@2ka.mipt.ru> <20080921233819.32714483@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080921233819.32714483-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 21, 2008 at 11:38:19PM +0100, Alan Cox (alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org) wrote:
> > > still more complex than needed; a WARN_ON_ONCE() will be enough.
> > 
> > That allows to dump whatever number of warnings you want. The more we
> > have, the louder will be customers scream.
> 
> But if Intel don't care then you can scream all you like 8)

That's what happens :)

> A WARN_ON_ONCE is sufficient to capture an idea of how many people it is
> effecting and maybe to figure out what the trigger is from their reports,
> at that point there is some chance to get it fixed (especially if its
> remotely triggerable ;))

Well, redhat, suse and ubuntu bugzillas happend to be not enough. Why do
you believe a single warning at a new place will be? or couple of tens
or whatever else? If it cares, it cares. If it does not...

I attracted vendor's attention, vendor told me to fix it myself and to
create a patch to fill an entry in another 'bugzilla', so that vendor
could get results and probably decide to walk down from the cloud and
fix it.

So, if they do not care, I do not care about their care. That's the
deal. I will try to find a workaround, even if it is a real crap,
fortunately other users will not strike this bug too frequently.

-- 
	Evgeniy Polyakov
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
