From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v 1/2] ravb: Add support for r8a7743 SoC
Date: Mon, 10 Jul 2017 12:31:19 +0300
Message-ID: <7a631876-900e-66fb-c389-a33b9a146a8e@cogentembedded.com>
References: <1499259711-56175-1-git-send-email-biju.das@bp.renesas.com>
 <1499259711-56175-2-git-send-email-biju.das@bp.renesas.com>
 <20170710012024.j4cso2jyi6canws2@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>,
        Chris Paterson <chris.paterson2@renesas.com>,
        devicetree@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Rob Herring <robh@kernel.org>, Biju Das <biju.das@bp.renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:32778 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752655AbdGJJbc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 05:31:32 -0400
Received: by mail-lf0-f48.google.com with SMTP id z78so55371610lff.0
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 02:31:31 -0700 (PDT)
In-Reply-To: <20170710012024.j4cso2jyi6canws2@rob-hp-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 7/10/2017 4:20 AM, Rob Herring wrote:

>> Add support for Gigabit Ethernet E-MAC on r8a7743 (RZ/G1M) SoC.
>> Renesas RZ/G1M (R8A7743) SoC Ethernet AVB IP is identical to the R-Car Gen2
>> family.
> 
> For the subject: "dt-bindings: net: ..."
> 
>>
>> Signed-off-by: Biju Das <biju.das@bp.renesas.com>
>> Reviewed-by: Chris Paterson <chris.paterson2@renesas.com>
>> ---
>>   Documentation/devicetree/bindings/net/renesas,ravb.txt | 3 ++-
>>   drivers/net/ethernet/renesas/ravb_main.c               | 1 +
>>   2 files changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt b/Documentation/devicetree/bindings/net/renesas,ravb.txt
>> index b519503..bc692ab 100644
>> --- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
>> +++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
>> @@ -4,7 +4,8 @@ This file provides information on what the device node for the Ethernet AVB
>>   interface contains.
>>   
>>   Required properties:
>> -- compatible: "renesas,etheravb-r8a7790" if the device is a part of R8A7790 SoC.
>> +- compatible: "renesas,etheravb-r8a7743" if the device is a part of R8A7743 SoC.
>> +	      "renesas,etheravb-r8a7790" if the device is a part of R8A7790 SoC.
> 
> Please re-format like this:
> 
> - compatible: Must be one of:
> ...
> 
> So it's a one line change to add new compatibles.

    Note that the common gen2/3 values are at end of this list, so they'll 
need different treating if you add these words.

MBR, Sergei
