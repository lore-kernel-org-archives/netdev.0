From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: ath9k gpio request
Date: Sat, 04 Jun 2016 17:37:50 +0300
Message-ID: <87d1nxt3y9.fsf@kamboji.qca.qualcomm.com>
References: <20160530132225.4d297678@canb.auug.org.au>
	<574C4851.9090201@gmail.com>
	<87fusy3cqx.fsf_-_@kamboji.qca.qualcomm.com>
	<574D3EAA.3060102@gmail.com> <1464764036580.70506@qti.qualcomm.com>
	<574EC331.1080901@gmail.com> <574ED297.4080004@gmail.com>
	<1464854569880.79341@qti.qualcomm.com> <57501AE4.7080104@gmail.com>
	<8760tqn8fc.fsf@purkki.adurom.net>
	<1464932944074.85131@qti.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>,
	ath9k-devel <ath9k-devel-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org>,
	"linux-next\@vger.kernel.org" <linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless\@vger.kernel.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ath9k-devel\@lists.ath9k.org" <ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org>,
	"netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Miaoqing Pan <miaoqing-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
To: "Pan\, Miaoqing" <miaoqing-Rm6X0d1/PG5y9aJCnZT0Uw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1464932944074.85131-Rm6X0d1/PG5y9aJCnZT0Uw@public.gmane.org> (Miaoqing Pan's message of
	"Fri, 3 Jun 2016 05:49:06 +0000")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(Fixing top posting)

"Pan, Miaoqing" <miaoqing-Rm6X0d1/PG5y9aJCnZT0Uw@public.gmane.org> writes:

>>> --- a/drivers/net/wireless/ath/ath9k/reg.h
>>> +++ b/drivers/net/wireless/ath/ath9k/reg.h
>>> @@ -1122,8 +1122,8 @@ enum {
>>>   #define AR9300_NUM_GPIO                          16
>>>   #define AR9330_NUM_GPIO                                 16
>>>   #define AR9340_NUM_GPIO                                 23
>>> -#define AR9462_NUM_GPIO                                 10
>>> -#define AR9485_NUM_GPIO                                 12
>>> +#define AR9462_NUM_GPIO                                 14
>>> +#define AR9485_NUM_GPIO                                 11
>>>   #define AR9531_NUM_GPIO                                 18
>>>   #define AR9550_NUM_GPIO                                 24
>>>   #define AR9561_NUM_GPIO                                 23
>>> @@ -1139,8 +1139,8 @@ enum {
>>>   #define AR9300_GPIO_MASK                        0x0000F4FF
>>>   #define AR9330_GPIO_MASK                        0x0000F4FF
>>>   #define AR9340_GPIO_MASK                        0x0000000F
>>> -#define AR9462_GPIO_MASK                        0x000003FF
>>> -#define AR9485_GPIO_MASK                        0x00000FFF
>>> +#define AR9462_GPIO_MASK                        0x00003FFF
>>> +#define AR9485_GPIO_MASK                        0x000007FF
>>>   #define AR9531_GPIO_MASK                        0x0000000F
>>>   #define AR9550_GPIO_MASK                        0x0000000F
>>>   #define AR9561_GPIO_MASK                        0x0000000F
>>
>> solves the problem.
>>
>> Tested-by: Sudip Mukherjee <sudip.mukherjee-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
>
> Done, https://patchwork.kernel.org/patch/9151847/

But the patch 9151847 is different from what Sudip tested above? Why?

And if you modify something _after_ the reporter has tested the patch
clearly document what you changed and why. I do not want find hidden
changes like this, even more so when the patch is going to a 4.7-rc
release.

Sudip, could you also test patch 9151847, please? You can download the
patch from the patchwork link above.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
