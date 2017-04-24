From: Arun Parameswaran <arun.parameswaran-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 1/2] net: dsa: b53: Add compatible strings for the
 Cygnus-family BCM11360.
Date: Mon, 24 Apr 2017 16:15:20 -0700
Message-ID: <1361654c-e4eb-e0a0-3397-b43235b5ff60@broadcom.com>
References: <20170424215022.30382-1-eric@anholt.net>
 <20170424215022.30382-2-eric@anholt.net>
 <ee265657-8175-b6c7-a0dc-cec216cd9ede@broadcom.com>
 <173c8ff2-6a31-5460-9a3f-8d8ac445a336@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Ray Jui <rjui-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Scott Branden <sbranden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Jon Mason <jonmason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <173c8ff2-6a31-5460-9a3f-8d8ac445a336-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 17-04-24 04:07 PM, Florian Fainelli wrote:
> On 04/24/2017 04:03 PM, Arun Parameswaran wrote:
>> Hi Eric
>>
>> A comment on the Device ID.
>>
>>
>> On 17-04-24 02:50 PM, Eric Anholt wrote:
>>> Cygnus is a small family of SoCs, of which we currently have
>>> devicetree for BCM11360 and BCM58300.  The 11360's B53 is mostly the
>>> same as 58xx, just requiring a tiny bit of setup that was previously
>>> missing.
>>>
>>> Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
>>> ---
>>>  Documentation/devicetree/bindings/net/dsa/b53.txt | 3 +++
>>>  drivers/net/dsa/b53/b53_srab.c                    | 2 ++
>>>  2 files changed, 5 insertions(+)
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/dsa/b53.txt b/Documentation/devicetree/bindings/net/dsa/b53.txt
>>> index d6c6e41648d4..49c93d3c0839 100644
>>> --- a/Documentation/devicetree/bindings/net/dsa/b53.txt
>>> +++ b/Documentation/devicetree/bindings/net/dsa/b53.txt
>>> @@ -29,6 +29,9 @@ Required properties:
>>>        "brcm,bcm58625-srab"
>>>        "brcm,bcm88312-srab" and the mandatory "brcm,nsp-srab string
>>>  
>>> +  For the BCM11360 SoC, must be:
>>> +      "brcm,bcm11360-srab" and the mandatory "brcm,cygnus-srab string
>>> +
>>>    For the BCM63xx/33xx SoCs with an integrated switch, must be one of:
>>>        "brcm,bcm3384-switch"
>>>        "brcm,bcm6328-switch"
>>> diff --git a/drivers/net/dsa/b53/b53_srab.c b/drivers/net/dsa/b53/b53_srab.c
>>> index 8a62b6a69703..c37ffd1b6833 100644
>>> --- a/drivers/net/dsa/b53/b53_srab.c
>>> +++ b/drivers/net/dsa/b53/b53_srab.c
>>> @@ -364,6 +364,7 @@ static const struct of_device_id b53_srab_of_match[] = {
>>>  	{ .compatible = "brcm,bcm53018-srab" },
>>>  	{ .compatible = "brcm,bcm53019-srab" },
>>>  	{ .compatible = "brcm,bcm5301x-srab" },
>>> +	{ .compatible = "brcm,bcm11360-srab", .data = (void *)BCM58XX_DEVICE_ID },
>>>  	{ .compatible = "brcm,bcm58522-srab", .data = (void *)BCM58XX_DEVICE_ID },
>>>  	{ .compatible = "brcm,bcm58525-srab", .data = (void *)BCM58XX_DEVICE_ID },
>>>  	{ .compatible = "brcm,bcm58535-srab", .data = (void *)BCM58XX_DEVICE_ID },
>>> @@ -371,6 +372,7 @@ static const struct of_device_id b53_srab_of_match[] = {
>>>  	{ .compatible = "brcm,bcm58623-srab", .data = (void *)BCM58XX_DEVICE_ID },
>>>  	{ .compatible = "brcm,bcm58625-srab", .data = (void *)BCM58XX_DEVICE_ID },
>>>  	{ .compatible = "brcm,bcm88312-srab", .data = (void *)BCM58XX_DEVICE_ID },
>>> +	{ .compatible = "brcm,cygnus-srab", .data = (void *)BCM58XX_DEVICE_ID },
>> The device ID should be 0xd300. This is the actual value read from the switch regs.
>> This also requires an entry in the 'b53_switch_chips' structure in b53_common.c.
> These are not real ID numbers, these are values that indicate the
> generation of the switch being embedded into the SoC. Within
> b53_common.c we don't have to differentiate a Starfighter 2 embedded in
> BCM11360, NSP, or 7445 or 7278, which is why using 58XX_DEVICE_ID should
> be good enough.
Ok. Thanks.

I was under the impression, that these id's could be used in the b53_switch_detect()
API to auto detect the switch. In that API, the switch ID is read from the
Management page register.

>>>  	{ .compatible = "brcm,nsp-srab", .data = (void *)BCM58XX_DEVICE_ID },
>>>  	{ /* sentinel */ },
>>>  };
>> Other wise this patch set looks good.
>>
>> I was testing a similar change (except for the above, which doesn't
>> affect the functionality) to get the switch working and it works.
>>
>> Thanks
>> Arun
>>
>

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
