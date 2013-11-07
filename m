From: Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] wcn36xx: Fix logging macro with unnecessary semicolon
Date: Thu, 7 Nov 2013 07:32:37 +0000
Message-ID: <CAFSJ42Y-3BZqj+JRNa8wdxjnm1fguD8ToH5Oj0m56yT5NexdVQ@mail.gmail.com>
References: <1383684000.4387.42.camel@joe-AO722>
	<CAFSJ42YQy96Sko8CuG9BGjHzTV7TkRp2=NVt036APxSKpPB=Ag@mail.gmail.com>
	<1383760556.7940.28.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Luis R. Rodriguez" <mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	wcn36xx <wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org,
	ath9k-devel <ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org>,
	ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1383760556.7940.28.camel@joe-AO722>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Joe,

I personally like the idea of making some kind of framework on top of
printing because all ath drivers are using the same printing approach
and combining all that code in one place will reduce amount of code in
each particular driver. As a true engineer i like when it's less code
= less work to do = less bugs:)

Suggestion is to send a patch with semicolon fix only and have a
second round of convincing ath guys to change printing code. How does
that sound?

On Wed, Nov 6, 2013 at 5:55 PM, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
> On Wed, 2013-11-06 at 07:49 +0000, Eugene Krasnikov wrote:
>> Hm... when it comes to semicolon the patch seems to be good. When it
>> comes to dynamic debugging i think we should have a separate
>> discussion about that.
>> I personally like the whole idea about dynamic debug but if you want
>> to change it i would suggest to have some kind of framework for all
>> ath drivers(or maybe all wireless drivers). Because obviously you can
>> find common code in every driver that defines it's own debug
>> functions/debug levels and so on. Why not to make a framework with
>> standard API/levels?
>
> You need to bring that up with the Atheros folk.
> I've tried.  The view seemed to be it was more
> trouble than it was worth.
>
>
>



-- 
Best regards,
Eugene
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
