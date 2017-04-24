From: Scott Branden <scott.branden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 1/2] net: dsa: b53: Add compatible strings for the
 Cygnus-family BCM11360.
Date: Mon, 24 Apr 2017 16:57:45 -0700
Message-ID: <8054ec9e-73d0-af1a-bb9a-fcdac782dc9c@broadcom.com>
References: <20170424215022.30382-1-eric@anholt.net>
 <20170424215022.30382-2-eric@anholt.net>
 <a2f4f0c9-feea-291b-dae5-f4ed10f9c547@broadcom.com>
 <8760hte4zw.fsf@eliezer.anholt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Ray Jui <rjui-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Scott Branden <sbranden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Jon Mason <jonmason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8760hte4zw.fsf-omZaPlIz5HhaEpDpdNBo/KxOck334EZe@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 17-04-24 04:54 PM, Eric Anholt wrote:
> Scott Branden <scott.branden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> writes:
>
>> Minor comment in line
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
>> place in alphabetical order in the doc?
>
> Moved it above BCM5310x now.  I hope that's what you meant.
>
Yes, sorry for not being more clear.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
