From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: Re: [PATCH v2 6/6] dt-bindings: net: ks8995: add bindings
 documentation for ks8995
Date: Tue, 9 Feb 2016 09:07:21 +0100
Message-ID: <56B99E39.1000207@gmail.com>
References: <1454952937-19428-1-git-send-email-helmut.buchsbaum@gmail.com>
 <1454952937-19428-7-git-send-email-helmut.buchsbaum@gmail.com>
 <56B8E205.1010807@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35500 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778AbcBIIHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 03:07:35 -0500
Received: by mail-wm0-f68.google.com with SMTP id g62so1868722wme.2
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 00:07:34 -0800 (PST)
In-Reply-To: <56B8E205.1010807@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/08/2016 07:44 PM, Sergei Shtylyov wrote:
> Hello.
>
> On 02/08/2016 08:35 PM, Helmut Buchsbaum wrote:
>
>> Signed-off-by: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
>> ---
>>   .../devicetree/bindings/net/micrel-ks8995.txt        | 20
>> ++++++++++++++++++++
>>   1 file changed, 20 insertions(+)
>>   create mode 100644
>> Documentation/devicetree/bindings/net/micrel-ks8995.txt
>>
>> diff --git a/Documentation/devicetree/bindings/net/micrel-ks8995.txt
>> b/Documentation/devicetree/bindings/net/micrel-ks8995.txt
>> new file mode 100644
>> index 0000000..7f11ca6
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/micrel-ks8995.txt
>> @@ -0,0 +1,20 @@
>> +Micrel KS8995 SPI controlled Ethernet Switch families
>> +
>> +Required properties (according to spi-bus.txt):
>> +- compatible: either "micrel,ks8995", "micrel,ksz8864" or
>> "micrel,ksz8795"
>> +
>> +Optional properties:
>> +- reset-gpios : phandle of gpio that will be used to reset chip
>> during probe
>> +
>> +Example:
>> +
>> +spi-master {
>> +    ...
>> +    ksz8795 {
>
>     ePAPR tells to name the nodes generically, according to their function.
>
>> +        compatible = "micrel,ksz8795";
>> +
>> +        reg = <0>;
>> +        spi-max-frequency = <50000000>;
>> +        reset-gpios = <&gpio0 46 1>;
>> +    };
>> +};
>
> MBR, Sergei
>
Hello Sergei,

just to avoid any misunderstandings: you refer to ePAPR, ch. 2.2.1 Node 
Names. Your definitely right, I'll correct the naming in my example!

Thanks,
Helmut
