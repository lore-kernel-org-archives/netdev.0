From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH 1/7] net: wireless: wcn36xx: add wcn3620 chip type definition
Date: Fri, 23 Jan 2015 17:39:40 +0200
Message-ID: <87twzhld4z.fsf@kamboji.qca.qualcomm.com>
References: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
	<20150118051043.31866.53087.stgit@114-36-241-182.dynamic.hinet.net>
	<878uh06ulp.fsf@kamboji.qca.qualcomm.com>
	<CAAfg0W4cns51+B_imf1jGWOmA0S8jqNFR+6epRxv8qqTgvBAgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	wcn36xx <wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Green <andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAAfg0W4cns51+B_imf1jGWOmA0S8jqNFR+6epRxv8qqTgvBAgg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Andy Green's message of "Mon, 19 Jan 2015 08:24:41 +0800")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Andy Green <andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> writes:

> On 18 January 2015 at 22:17, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:
>> Andy Green <andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> writes:
n>>
>>> Convert the list of chip types to an enum, add the default
>>> UNKNOWN type and a type for WCN3620 chip
>>>
>>> Signed-off-by: Andy Green <andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
>>
>> Please just use "wcn36xx: ", you should drop "net: wireless: " entirely.
>
> OK.
>
> Can you help me understand what you'd like to see happen with the chip
> variant detection stuff?

I haven't looked at wcn36xx for a long time so I'm not really the right
person to answer. I'm more like a desk jockey now ;)

> There's a comment sent to one list only saying it might be preferable
> to keep the old detection code as the default.  But there are no
> in-tree users of wcn36xx (mainly due to PIL not being in mainline, I
> guess).
>
> The old test's equivalence that AC == 3680 seems kind of weak to me
> and establishing the type must be passed in from platform code
> reflects the situation that there's no public way to detect the chip
> type from Qualcomm.  In the second not-for-upstream series I use that
> to pass it in from DT, which is how it'd be normally used.

Please remember that the DT bindings document has to be acked by the
device-tree maintainers.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
