From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 2/3] dt-binding: net: sfp binding documentation
Date: Wed, 30 Aug 2017 15:13:27 +0300
Message-ID: <63b6c344-1368-8d49-cbb9-658810f454e2@cogentembedded.com>
References: <d1e64c5752ef0dd5c5b543c2d4c3ef1783318173.1504086672.git.baruch@tkos.co.il>
 <7ae5d883fd038cf518949b0aa9cbe5369e2a1851.1504086672.git.baruch@tkos.co.il>
 <89261369-d97c-a78c-5a21-a269b2c7e513@cogentembedded.com>
 <20170830111118.wy62va6sjzsxrgoo@tarshish>
 <c3e8af44-bf58-81d7-bd51-d2538dcd41d9@cogentembedded.com>
 <20170830112557.dhcl3pv7gmuzg22v@tarshish>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Russell King <rmk+kernel@arm.linux.org.uk>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:38477 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751282AbdH3MNb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 08:13:31 -0400
Received: by mail-lf0-f48.google.com with SMTP id d202so23702392lfd.5
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 05:13:30 -0700 (PDT)
In-Reply-To: <20170830112557.dhcl3pv7gmuzg22v@tarshish>
Content-Language: en-MW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/2017 02:25 PM, Baruch Siach wrote:

>>>>> Add device-tree binding documentation SFP transceivers. Support for SFP
>>>>> transceivers has been recently introduced (drivers/net/phy/sfp.c).
>>>>>
>>>>> Signed-off-by: Baruch Siach <baruch@tkos.co.il>
>>>>> ---
>>>>> v2:
>>>>>      Rename -gpio properties to -gpios
>>>>>      Rename the rate-select-gpio property to rate-select0-gpios
>>>>>      Add the rate-select1-gpios property
>>>>>      Add examples
>>>>> ---
>>>>>     Documentation/devicetree/bindings/net/sff,sfp.txt | 74 +++++++++++++++++++++++
>>>>>     1 file changed, 74 insertions(+)
>>>>>     create mode 100644 Documentation/devicetree/bindings/net/sff,sfp.txt
>>>>>
>>>>> diff --git a/Documentation/devicetree/bindings/net/sff,sfp.txt b/Documentation/devicetree/bindings/net/sff,sfp.txt
>>>>> new file mode 100644
>>>>> index 000000000000..1d9c786d6287
>>>>> --- /dev/null
>>>>> +++ b/Documentation/devicetree/bindings/net/sff,sfp.txt
>>>>> @@ -0,0 +1,74 @@
>>>>> +Small Form Factor (SFF) Committee Small Form-factor Pluggable (SFP)
>>>>> +Transceiver
>>>>> +
>>>>> +Required properties:
>>>>> +
>>>>> +- compatible : must be "sff,sfp"
>>>>> +
>>>>> +Optional Properties:
>>>>> +
>>>>> +- i2c-bus : phandle of an I2C bus controller for the SFP two wire serial
>>>>> +  interface
>>>>> +
>>>>> +- moddef0-gpios : phandle of the MOD-DEF0 (AKA Mod_ABS) module presence input
>>>>> +  gpio signal
>>>>
>>>>      Your example shows there's GPIO phandle *and* specifier.
>>>
>>> Would "GPIO specifier" be enough here?
>>
>>     No, specifier is the cells following GPIO (or any other) phandle.
> 
> So this should be "GPIO phandle and specifier of ...", is that correct?

    Exactly. The length of the GPIO specifier is determined by the 
"#gpio-cells" prop of the GPIO node your phandle refers to.

> I have found very few (< 4) occurrences of this language in (lots of) '-gpios'
> property descriptions under Documentation/devicetree/bindings/.

    You better see Documentation/devicetree/bindings/gpio/gpio.txt.

> Is this a new
> requirement?

    Not at all, and it's not limited to GPIOs. Nobody reads the specs. :-)

> baruch

MBR, Sergei
