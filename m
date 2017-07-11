From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] dt-bindings: net: ravb : Add support for r8a7743 SoC
Date: Tue, 11 Jul 2017 15:55:57 +0300
Message-ID: <afe04380-840a-c282-2f53-40d891e6400a@cogentembedded.com>
References: <20170710012024.j4cso2jyi6canws2@rob-hp-laptop>
 <1499700776-54504-1-git-send-email-biju.das@bp.renesas.com>
 <52eb0b92-5d25-e1f4-df54-e4fcf648c90e@cogentembedded.com>
 <TY1PR06MB07023342440946F384B7C80EB7AE0@TY1PR06MB0702.apcprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-renesas-soc@vger.kernel.org"
        <linux-renesas-soc@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chris Paterson <Chris.Paterson2@renesas.com>,
        Biju Das <biju.das@bp.renesas.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <TY1PR06MB07023342440946F384B7C80EB7AE0@TY1PR06MB0702.apcprd06.prod.outlook.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/11/2017 03:20 PM, Chris Paterson wrote:

>>> Add a new compatible string for the RZ/G1M (R8A7743) SoC.
>>>
>>> Signed-off-by: Biju Das <biju.das@bp.renesas.com>
>>> ---
>>> v1->v2
>>> * Changed the subject
>>> * re-formatted the required properties
>>>
>>>  .../devicetree/bindings/net/renesas,ravb.txt       | 29 +++++++++++++------
>> ---
>>>  1 file changed, 17 insertions(+), 12 deletions(-)
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt
>>> b/Documentation/devicetree/bindings/net/renesas,ravb.txt
>>> index b519503..4717bc2 100644
>>> --- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
>>> +++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
>>> @@ -4,19 +4,24 @@ This file provides information on what the device
>>> node for the Ethernet AVB  interface contains.
>>>
>>>  Required properties:
>>> -- compatible: "renesas,etheravb-r8a7790" if the device is a part of R8A7790
>> SoC.
>>> -	      "renesas,etheravb-r8a7791" if the device is a part of R8A7791 SoC.
>>> -	      "renesas,etheravb-r8a7792" if the device is a part of R8A7792 SoC.
>>> -	      "renesas,etheravb-r8a7793" if the device is a part of R8A7793 SoC.
>>> -	      "renesas,etheravb-r8a7794" if the device is a part of R8A7794 SoC.
>>> -	      "renesas,etheravb-r8a7795" if the device is a part of R8A7795 SoC.
>>> -	      "renesas,etheravb-r8a7796" if the device is a part of R8A7796 SoC.
>>> -	      "renesas,etheravb-rcar-gen2" for generic R-Car Gen 2 compatible
>> interface.
>>> -	      "renesas,etheravb-rcar-gen3" for generic R-Car Gen 3 compatible
>> interface.
>>> +- compatible: Must contain one or more of the following:
>>
>>     No, it can't contain more than one SoC specific value.
>
> Surely it can contain both "renesas,etheravb-r8a7743" and "renesas,etheravb-rcar-gen2" for example?
>
> As indeed dictated by the instruction further down:

    Yes. Sorry, I should have been more attentive.

>>> +	When compatible with the generic version, nodes must list the
>>> +	SoC-specific version corresponding to the platform first followed by
>>> +	the generic version.

> Kind regards, Chris

MBR, Sergei
