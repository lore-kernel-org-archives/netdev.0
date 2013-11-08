From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [PATCH] wcn36xx: Fix logging macro with unnecessary semicolon
Date: Fri, 8 Nov 2013 09:06:19 +0200
Message-ID: <87bo1vcqz8.fsf@kamboji.qca.qualcomm.com>
References: <1383684000.4387.42.camel@joe-AO722>
	<CAFSJ42YQy96Sko8CuG9BGjHzTV7TkRp2=NVt036APxSKpPB=Ag@mail.gmail.com>
	<1383760556.7940.28.camel@joe-AO722>
	<CAFSJ42Y-3BZqj+JRNa8wdxjnm1fguD8ToH5Oj0m56yT5NexdVQ@mail.gmail.com>
	<1383853221.9263.14.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Luis R. Rodriguez" <rodrigue-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	wcn36xx <wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>,
	ath9k-devel <ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org>,
	<ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <wil6210-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1383853221.9263.14.camel@joe-AO722> (Joe Perches's message of
	"Thu, 7 Nov 2013 11:40:21 -0800")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> writes:

>> have a
>> second round of convincing ath guys to change printing code. How does
>> that sound?
>
> Luis?  Kalle?  Other Qualcomm/Atheros folk?

I didn't quite get what you are asking from me. But for me most
important is that the current debugging facilities from user's point of
view don't change. I don't care if the code is in ath10k.ko or ath.ko,
we are talking about ~100 lines of code anyway.

> One of the nominal benefits of separating the ath_<level>
> macros by subsystem was perf/tracing.

Nominal?

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
