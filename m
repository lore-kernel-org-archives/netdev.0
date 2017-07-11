From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2] dt-bindings: net: ravb : Add support for r8a7743 SoC
Date: Tue, 11 Jul 2017 15:51:40 +0300
Message-ID: <87b6b38a-ca6b-a0d7-b777-0a4809eaf6fc@cogentembedded.com>
References: <20170710012024.j4cso2jyi6canws2@rob-hp-laptop>
 <1499700776-54504-1-git-send-email-biju.das@bp.renesas.com>
 <52eb0b92-5d25-e1f4-df54-e4fcf648c90e@cogentembedded.com>
 <20170711122100.GM4517@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Biju Das <biju.das-kTT6dE0pTRh9uiUsa/gSgQ@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Magnus Damm <magnus.damm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Chris Paterson <chris.paterson2-zM6kxYcvzFBBDgjK7y7TUQ@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170711122100.GM4517-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/11/2017 03:21 PM, Simon Horman wrote:

>>> Add a new compatible string for the RZ/G1M (R8A7743) SoC.
>>>
>>> Signed-off-by: Biju Das <biju.das-kTT6dE0pTRh9uiUsa/gSgQ@public.gmane.org>
>>> ---
>>> v1->v2
>>> * Changed the subject
>>> * re-formatted the required properties
>>>
>>> .../devicetree/bindings/net/renesas,ravb.txt       | 29 +++++++++++++---------
>>> 1 file changed, 17 insertions(+), 12 deletions(-)
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt b/Documentation/devicetree/bindings/net/renesas,ravb.txt
>>> index b519503..4717bc2 100644
>>> --- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
>>> +++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
>>> @@ -4,19 +4,24 @@ This file provides information on what the device node for the Ethernet AVB
>>> interface contains.
>>>
>>> Required properties:
>>> -- compatible: "renesas,etheravb-r8a7790" if the device is a part of R8A7790 SoC.
>>> -	      "renesas,etheravb-r8a7791" if the device is a part of R8A7791 SoC.
>>> -	      "renesas,etheravb-r8a7792" if the device is a part of R8A7792 SoC.
>>> -	      "renesas,etheravb-r8a7793" if the device is a part of R8A7793 SoC.
>>> -	      "renesas,etheravb-r8a7794" if the device is a part of R8A7794 SoC.
>>> -	      "renesas,etheravb-r8a7795" if the device is a part of R8A7795 SoC.
>>> -	      "renesas,etheravb-r8a7796" if the device is a part of R8A7796 SoC.
>>> -	      "renesas,etheravb-rcar-gen2" for generic R-Car Gen 2 compatible interface.
>>> -	      "renesas,etheravb-rcar-gen3" for generic R-Car Gen 3 compatible interface.
>>> +- compatible: Must contain one or more of the following:
>>
>>    No, it can't contain more than one SoC specific value.
>
> The text above does not say it can unless one is under the delusion
> that, f.e. an r8a7790 SoC is also an r8a7791 SoC.

    Hm, you're right. Sorry about my misunderstanding...

    The only problem I'm still seeing with the current wording is that gen2/3 
fallback
values are declared optional, while you can't get the driver to bind without 
them on
the newer SoCs. But this is probably not a new problem...

> If you would prefer an alternate wording please provide a suggestion.

    Perhaps we should emphasize that the gen2/3 fallback values are mandatory?

>>> +      - "renesas,etheravb-r8a7743" for the R8A7743 SoC.
>>> +      - "renesas,etheravb-r8a7790" for the R8A7790 SoC.
>>> +      - "renesas,etheravb-r8a7791" for the R8A7791 SoC.
>>> +      - "renesas,etheravb-r8a7792" for the R8A7792 SoC.
>>> +      - "renesas,etheravb-r8a7793" for the R8A7793 SoC.
>>> +      - "renesas,etheravb-r8a7794" for the R8A7794 SoC.
>>> +      - "renesas,etheravb-rcar-gen2" as a fallback for the above
>>> +		R-Car Gen2 and RZ/G1 devices.
[...]

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
