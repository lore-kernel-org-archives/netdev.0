From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH v5 10/11] Documentation: dtb: xgene: Add MDIO node
Date: Thu, 21 Jul 2016 10:57:59 -0700
Message-ID: <CAKh23F=jT=rjU_e9Xu82Jna5ntPR5zdt3VGEyXR4_w+6aQ6Cyg@mail.gmail.com>
References: <1467932579-14320-1-git-send-email-isubramanian@apm.com>
 <1467932579-14320-11-git-send-email-isubramanian@apm.com> <20160713131010.GA15972@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, patches <patches@apm.com>,
	Matthias Brugger <matthias.bgg@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King - ARM Linux <linux@armlinux.org.uk>
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f45.google.com ([209.85.213.45]:33452 "EHLO
	mail-vk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753540AbcGUR6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 13:58:01 -0400
Received: by mail-vk0-f45.google.com with SMTP id x130so124594799vkc.0
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 10:58:01 -0700 (PDT)
In-Reply-To: <20160713131010.GA15972@rob-hp-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 13, 2016 at 6:10 AM, Rob Herring <robh@kernel.org> wrote:
> On Thu, Jul 07, 2016 at 04:02:58PM -0700, Iyappan Subramanian wrote:
>> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
>> Tested-by: Fushen Chen <fchen@apm.com>
>> Tested-by: Toan Le <toanle@apm.com>
>> Tested-by: Matthias Brugger <mbrugger@suse.com>
>> ---
>>  .../devicetree/bindings/net/apm-xgene-mdio.txt     | 37 ++++++++++++++++++++++
>>  1 file changed, 37 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/net/apm-xgene-mdio.txt
>>
>> diff --git a/Documentation/devicetree/bindings/net/apm-xgene-mdio.txt b/Documentation/devicetree/bindings/net/apm-xgene-mdio.txt
>> new file mode 100644
>> index 0000000..0247e70
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/apm-xgene-mdio.txt
>> @@ -0,0 +1,37 @@
>> +APM X-Gene SoC MDIO node
>> +
>> +MDIO node is defined to describe on-chip MDIO controller.
>> +
>> +Required properties:
>> +     - compatible: Must be "apm,xgene-mdio-rgmii"
>> +     - #address-cells: Must be <1>.
>> +     - #size-cells: Must be <0>.
>> +     - reg: Address and length of the register set
>> +     - clocks: Reference to the clock entry
>> +
>> +For the phys on the mdio bus, there must be a node with the following fields:
>> +     - compatible: PHY identifier.  Please refer ./phy.txt for the format.
>> +     - reg: The ID number for the phy.
>> +
>> +Example:
>> +
>> +     mdio: mdio@0x17020000 {
>
> Drop the '0x'

Thanks for the review.  Corrected and posted v6.

>
> With that,
>
> Acked-by: Rob Herring <robh@kernel.org>
>
>> +             compatible = "apm,xgene-mdio-rgmii";
>> +             #address-cells = <1>;
>> +             #size-cells = <0>;
>> +             reg = <0x0 0x17020000 0x0 0xd100>;
>> +             clocks = <&menetclk 0>;
>> +     };
>> +
>> +     /* Board-specific peripheral configurations */
>> +     &mdio {
>> +             menetphy: phy@3 {
>> +                     reg = <0x3>;
>> +             };
>> +             sgenet0phy: phy@4 {
>> +                     reg = <0x4>;
>> +             };
>> +             sgenet1phy: phy@5 {
>> +                     reg = <0x5>;
>> +             };
>> +     };
>> --
>> 1.9.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe devicetree" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
