From: huangdaode <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Subject: Re: [PATCH v2 net-next] net: hisilicon: fix binding document of mdio
Date: Wed, 18 Nov 2015 09:42:08 +0800
Message-ID: <564BD770.1080205@hisilicon.com>
References: <1447666704-200773-1-git-send-email-huangdaode@hisilicon.com> <6897029.2fyR9qGpEn@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	<mark.rutland-5wv7dgnIgG8@public.gmane.org>, <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	<galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, <liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	<Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<kenneth-lee-2012-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org>, <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	<lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <6897029.2fyR9qGpEn@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2015/11/16 17:38, Arnd Bergmann wrote:
> On Monday 16 November 2015 17:38:24 huangdaode wrote:
>> This patch explains the occasion of "hisilcon,mdio" and
>> "hisilicon,hns-mdio" according to Arnd's comments.
>> and reformat it according to comments from Rob<robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>.
>>
>> chang log:
>>
>> v2:
>>    1) reformat the style.
>>    2) make it more clearity.
>>
>> v1:
>>    initial version.
>>
>> Signed-off-by: huangdaode <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
>> ---
> The new version looks ok, but your changelog above is formatted
> incorrectly. Please put only the contents you want in the git history
> above the '---' line and your Signed-off-by, but put the parts that
> refer to previous versions of the submission below the ---.

Got it.
thanks Arnd.

Daode

>>   Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt | 7 ++++++-
>>   1 file changed, 6 insertions(+), 1 deletion(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt
>> index 9c23fdf..4942d20 100644
>> --- a/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt
>> +++ b/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt
>> @@ -1,7 +1,12 @@
>>   Hisilicon MDIO bus controller
>>   
>>   Properties:
>> -- compatible: "hisilicon,mdio","hisilicon,hns-mdio".
>> +- compatible: can be one of:
>> +	"hisilicon,hns-mdio"
>> +	"hisilicon,mdio"
>> +  "hisilicon,hns-mdio" is recommendly to be used for hip05 and later SOCs,
>> +  while "hisilicon,mdio" is optional for backwards compatibility, only
>> +  support for hip04 Soc.
>>   - reg: The base address of the MDIO bus controller register bank.
>>   - #address-cells: Must be <1>.
>>   - #size-cells: Must be <0>.  MDIO addresses have no size component.
>>
>
> .
>


-- 
Best Regards
Daode Huang


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
