From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH 6/7] dt-bindings: net: bgmac: add bindings documentation
 for bgmac
Date: Fri, 1 Jul 2016 10:29:36 -0400
Message-ID: <CAC3K-4pu2k8HZ3g-LxbVAFOxPayDT=hK1qgix1Pc81aTEmGQzA@mail.gmail.com>
References: <1467327554-22074-1-git-send-email-jon.mason@broadcom.com>
 <1467327554-22074-7-git-send-email-jon.mason@broadcom.com> <20160701025619.GA4906@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, Ray Jui <rjui@broadcom.com>,
	Scott Branden <sbranden@broadcom.com>,
	BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:34325 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752426AbcGAO3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:29:38 -0400
Received: by mail-io0-f175.google.com with SMTP id g13so100920255ioj.1
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:29:37 -0700 (PDT)
In-Reply-To: <20160701025619.GA4906@rob-hp-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 30, 2016 at 10:56 PM, Rob Herring <robh@kernel.org> wrote:
> On Thu, Jun 30, 2016 at 06:59:13PM -0400, Jon Mason wrote:
>> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
>> ---
>>  .../devicetree/bindings/net/brcm,bgmac-nsp.txt     | 24 ++++++++++++++++++++++
>>  1 file changed, 24 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/net/brcm,bgmac-nsp.txt
>>
>> diff --git a/Documentation/devicetree/bindings/net/brcm,bgmac-nsp.txt b/Documentation/devicetree/bindings/net/brcm,bgmac-nsp.txt
>> new file mode 100644
>> index 0000000..022946c
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/brcm,bgmac-nsp.txt
>> @@ -0,0 +1,24 @@
>> +Broadcom GMAC Ethernet Controller Device Tree Bindings
>> +-------------------------------------------------------------
>> +
>> +Required properties:
>> + - compatible:       "brcm,bgmac-nsp"
>
> Usually we do <soc>-<block> order.

Thanks, I'll make the necessary changes and push out a v2.

>
>> + - reg:              Address and length of the GMAC registers,
>> +             Address and length of the GMAC IDM registers
>> + - reg-names:        Names of the registers.  Must have both "gmac_base" and
>> +             "idm_base"
>> + - interrupts:       Interrupt number
>> +
>> +Optional properties:
>> +- mac-address:       See ethernet.txt file in the same directory
>> +
>> +Examples:
>> +
>> +gmac0: ethernet@18022000 {
>> +     compatible = "brcm,bgmac-nsp";
>> +     reg = <0x18022000 0x1000>,
>> +           <0x18110000 0x1000>;
>> +     reg-names = "gmac_base", "idm_base";
>> +     interrupts = <GIC_SPI 147 IRQ_TYPE_LEVEL_HIGH>;
>> +     status = "disabled";
>> +};
>> --
>> 1.9.1
>>
