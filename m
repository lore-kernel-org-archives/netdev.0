From: Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] iwlwifi: convert hex_dump_to_buffer() to %*ph
Date: Tue, 4 Aug 2015 14:48:12 +0300
Message-ID: <CANUX_P3x1soE8PV9ZH4ObzgEzz9aEft6gS7mcVhbHRGy7H5mGw@mail.gmail.com>
References: <1437050535-22858-1-git-send-email-andriy.shevchenko@linux.intel.com>
	<1438685233.29746.156.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1438685233.29746.156.camel-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 4, 2015 at 1:47 PM, Andy Shevchenko
<andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wrote:
> On Thu, 2015-07-16 at 15:42 +0300, Andy Shevchenko wrote:
>> There is no need to use hex_dump_to_buffer() in the cases like this:
>>
>>       hexdump_to_buffer(buf, len, 16, 1, outbuf, outlen, false);      > /* len <= 16
>> */
>>       sprintf("%s\n", outbuf);
>>
>> since it maybe easily converted to simple:
>>
>>       sprintf("%*ph\n", len, buf);
>>
>> Note: it seems in one case the output is groupped by 2 bytes and
>> looks like a
>> typo. Thus, patch changes that to plain byte stream.
>
>
> Any comments on this, anyone?
>
> The idea is to minimize usage of hexdump_to_buffer(), i.e. not using it
> when it's an obvious overkill.
>

Sorry for the delay, since the buffer is small (less than 16 bytes, it
should be fine).
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
