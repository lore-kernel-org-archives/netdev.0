From: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Subject: Re: [PATCH 01/13 v4] usb/net: rndis: inline the cpu_to_le32()
 macro
Date: Sun, 06 May 2012 21:23:19 +0300
Message-ID: <20120506212319.17772n6l4f66lpc0@www.81.fi>
References: <1335896538-13281-1-git-send-email-linus.walleij@linaro.org>
 <20120502182938.15804ij32yd8jsis@www.81.fi>
 <CACRpkdY0t2UvU9vX4kPxV+BPOaerOWw4UKzTe_RjLOpYr2akDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=ISO-8859-1;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>,
	Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
	Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
To: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACRpkdY0t2UvU9vX4kPxV+BPOaerOWw4UKzTe_RjLOpYr2akDg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Quoting Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>:

> On Wed, May 2, 2012 at 5:29 PM, Jussi Kivilinna
> <jussi.kivilinna-E01nCVcF24I@public.gmane.org> wrote:
>
>> Quoting Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>:
>>
>>> The header file <linux/usb/rndis_host.h> used a number of #defines
>>> that included the cpu_to_le32() macro to assure the result will be
>>> in LE endianness. Inlining this into the code instead of using it
>>> in the code definitions yields consolidation opportunities later
>>> on as you will see in the following patches. The individual
>>> drivers also used local defines - all are switched over to the
>>> pattern of doing the conversion at the call sites instead.
>>>
>>
>> After this patch, endianness checks with sparse output:
> (...)
>> Patch fixing this attached.
>
> Thanks! Folded this into patch 1 and added your Signed-off-by.
>
>> Patch-set to clean-up ugliness caused by this patch at:
>> http://koti.mbnet.fi/axh/kernel/rndis_wlan/
>
> This seems like a good middle-ground as compared to the
> other suggestion to force all defines to be cpu_to_le32().
>
> Do you want me to rebase this on top of my series (there was
> a number of conflicts later in the series) and carry it as part
> of this patch set?

Please, do.

>
> Yours,
> Linus Walleij
>
>



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
