From: Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>
Subject: Re: [PATCH] net: fix NOHZ: local_softirq_pending 08
Date: Thu, 01 Oct 2009 17:24:13 +0300
Message-ID: <87bpkrqjjm.fsf@purkki.valot.fi>
References: <1254324077.3959.7.camel@johannes.local>
	<4AC3A0F1.3060306@hartkopp.net>
	<20090930.163333.234658158.davem@davemloft.net>
	<200910011604.42916.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200910011604.42916.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org> (Michael Buesch's message of "Thu\, 1 Oct 2009 16\:04\:40 +0200")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org> writes:

> On Thursday 01 October 2009 01:33:33 David Miller wrote:
>
>> I'm not applying this until all of these details are sorted out 
>
> John, please apply my fix to wireless-testing to get rid of the
> regression. You can revert it later, if there's a better fix
> available.

I agree, please take Michael's patch. It's trivial to change mac80211
part whenever there's better support available.

But I don't think this is a regression because I see the bug also with
2.6.28, most probably it has been in mac80211 forever. But it's still
a bug which needs to be fixed.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
