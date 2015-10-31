From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RESEND v2 net-next] net: hisilicon: updates HNS config
 and documents
Date: Sat, 31 Oct 2015 02:18:19 +0000
Message-ID: <563424EB.1060804@huawei.com>
References: <1445944594-244149-1-git-send-email-huangdaode@hisilicon.com> <4549013.K7sn8Pca5b@wuerfel> <56341C00.8080303@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	<mark.rutland-5wv7dgnIgG8@public.gmane.org>, <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	<galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	<will.deacon-5wv7dgnIgG8@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	<Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <kenneth-lee-2012-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org>,
	<xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: huangdaode <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56341C00.8080303-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On 10/31/2015 1:40 AM, huangdaode wrote:
> On 2015/10/30 22:20, Arnd Bergmann wrote:
>> On Tuesday 27 October 2015 19:16:34 huangdaode wrote:
>>>            mdio@803c0000 {
>>>                      #address-cells = <1>;
>>>                      #size-cells = <0>;
>>> -                   compatible = "hisilicon,mdio","hisilicon,hns-mdio";
>>> +                   compatible = "hisilicon,hns-mdio","hisilicon,mdio";
>>>                      reg = <0x0 0x803c0000 0x0 0x10000>;
>>>
>> Does "hisilicon,mdio" actually have a specific meaning? Is that just 
>> there
>> for legacy reasons?
>>
>>     Arnd
>>
>> .
>>
> hi Arnd,
> "hisilicon,mdio" is  the gernerical configuation compatible  for the 
> default hisilicon chip,
> We use generic hisilicon since our MDIO/PHY is same across flavour of 
> SoCs.
>
Hi Arnd,
Yes, "hisilicon,mdio" exists for the legacy reasons to support older SoC 
Hip04.

Best Regards
Salil

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
