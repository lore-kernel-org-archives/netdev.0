From: Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>
Subject: Re: mac80211: NOHZ: local_softirq_pending 08
Date: Fri, 11 Sep 2009 19:07:20 +0300
Message-ID: <873a6t31on.fsf@litku.valot.fi>
References: <200909111648.50902.mb@bu3sch.de> <877hw534wd.fsf@litku.valot.fi>
	<200909111707.23971.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200909111707.23971.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org> (Michael Buesch's message of "Fri\, 11 Sep 2009 17\:07\:23 +0200")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org> writes:

>> > mac80211 (or some other part of the networking stack) triggers this
>> > warning in the NOHZ code: NOHZ: local_softirq_pending 08
>> >
>> > 08 seems to be NET_RX_SOFTIRQ.
>> >
>> > It happens, because my test driver b43 handles all RX and TX-status
>> > callbacks in process context. I guess some part of the networking
>> > stack expects RX to be in tasklet and/or softirq context.
>> >
>> > We also have a report of this warning in wl1251, so it's probably not
>> > a b43 problem.
>> 
>> Yes, I see this with wl1251. It uses workqueues everywhere.
>> 
>
> This patch seems to fix it.

Yes, it does. Thanks.

> Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

Tested-by: Kalle Valo <kalle.valo-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
