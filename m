From: huangdaode <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Subject: Re: [PATCH RESEND v2 net-next] net: hisilicon: updates HNS config
 and documents
Date: Thu, 12 Nov 2015 10:11:24 +0800
Message-ID: <5643F54C.3010303@hisilicon.com>
References: <1445944594-244149-1-git-send-email-huangdaode@hisilicon.com> <56341C00.8080303@hisilicon.com> <563424EB.1060804@huawei.com> <4387413.QS6YM6BNWK@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<kenneth-lee-2012-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	<lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, <lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4387413.QS6YM6BNWK@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2015/11/3 6:05, Arnd Bergmann wrote:
> On Saturday 31 October 2015 02:18:19 Salil Mehta wrote:
>> On 10/31/2015 1:40 AM, huangdaode wrote:
>>> On 2015/10/30 22:20, Arnd Bergmann wrote:
>>>> On Tuesday 27 October 2015 19:16:34 huangdaode wrote:
>>>>>             mdio@803c0000 {
>>>>>                       #address-cells = <1>;
>>>>>                       #size-cells = <0>;
>>>>> -                   compatible = "hisilicon,mdio","hisilicon,hns-mdio";
>>>>> +                   compatible = "hisilicon,hns-mdio","hisilicon,mdio";
>>>>>                       reg = <0x0 0x803c0000 0x0 0x10000>;
>>>>>
>>>> Does "hisilicon,mdio" actually have a specific meaning? Is that just
>>>> there
>>>> for legacy reasons?
>>>>
>>>>      Arnd
>>>>
>>>> .
>>>>
>>> hi Arnd,
>>> "hisilicon,mdio" is  the gernerical configuation compatible  for the
>>> default hisilicon chip,
>>> We use generic hisilicon since our MDIO/PHY is same across flavour of
>>> SoCs.
>>>
>> Hi Arnd,
>> Yes, "hisilicon,mdio" exists for the legacy reasons to support older SoC
>> Hip04.
> I see. In that case, that compatible string should probably be mentioned
> only as 'optional' in the binding, and not used for devices other than
> hip04.
>
> 	Arnd
>
> .
>
Hi, Arnd
ok, ill send a patch to specify it, please Ack then.
thanks
Daode.

-- 
Best Regards
Daode Huang


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
