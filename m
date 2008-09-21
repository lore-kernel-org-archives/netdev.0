From: Marcel Holtmann <holtmann-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware
	restart.
Date: Mon, 22 Sep 2008 01:27:47 +0200
Message-ID: <1222039667.6782.125.camel@californication>
References: <20080921182835.GA11473@2ka.mipt.ru>
	 <20080921113513.16677c4e@infradead.org>
	 <20080921190050.GA20484@2ka.mipt.ru>
	 <1222024444.3023.53.camel@johannes.berg>
	 <20080921193809.GA8735@2ka.mipt.ru> <20080921124332.67ddc13a@infradead.org>
	 <20080921202057.GB25052@2ka.mipt.ru>
	 <20080921132753.5689b564@infradead.org>
	 <20080921205706.GA24545@2ka.mipt.ru>
	 <20080921140203.4698a2ee@infradead.org> <20080921210554.GA2135@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080921210554.GA2135-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Evgeniy,

> > > That allows to dump whatever number of warnings you want. The more we
> > > have, the louder will be customers scream.
> > 
> > artificially increasing numbers isn't going to do that; it just shows
> > you're more interested in making a stink than in getting something
> > improved ;(
> 
> As practice shows, I'm the only one who is interested in getting
> something improved, and Intel, as we see right now, is not interested in
> it at all, since you ask me not only decrease error verbosity, but also
> do not work towards fixing the bug by trying to understand where it
> lives.

as Arjan and Alan pointed out already, WARN_ON_ONCE is enough and I
agree with them. Just to make this perfectly clear, this is with my
community hat on.

Please send a proper patch with a simple WARN_ON_ONCE and I am happy to
sign off on it.

Regards

Marcel


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
