From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v5 09/10] Documentation: add Device tree bindings
 for Broadcom GENET
Date: Mon, 17 Feb 2014 14:18:47 -0800
Message-ID: <CAGVrzcZSX8sJJs_ZbY0_OL5QgE9daiT0AZQyWadA1w2AcbErVw@mail.gmail.com>
References: <1392336531-28875-1-git-send-email-f.fainelli@gmail.com>
 <1392336531-28875-10-git-send-email-f.fainelli@gmail.com> <53029702.6010803@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Kevin Cernekee <cernekee@gmail.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:38279 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754587AbaBQWT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 17:19:29 -0500
In-Reply-To: <53029702.6010803@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-17 15:10 GMT-08:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Hello.
>
>
> On 02/14/2014 03:08 AM, Florian Fainelli wrote:
>
>> This patch adds the Device Tree bindings for the Broadcom GENET Gigabit
>> Ethernet controller. A bunch of examples are provided to illustrate the
>> versatile aspect of the hardare.
>
>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>
> [...]
>
>    Too bad I didn't read this patch before and now it has been already
> applied.
>
> [...]
>
>
>> diff --git a/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
>> b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
>> new file mode 100644
>> index 0000000..afd31f9
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
>> @@ -0,0 +1,121 @@
>> +* Broadcom BCM7xxx Ethernet Controller (GENET)
>> +
>> +Required properties:
>> +- compatible: should contain one of "brcm,genet-v1", "brcm,genet-v2",
>> +  "brcm,genet-v3", "brcm,genet-v4".
>> +- reg: address and length of the register set for the device
>> +- interrupts: must be two cells, the first cell is the general purpose
>> +  interrupt line, while the second cell is the interrupt for the ring
>> +  RX and TX queues operating in ring mode
>> +- phy-mode: String, operation mode of the PHY interface. Supported values
>> are
>> +  "mii", "rgmii", "rgmii-txid", "rev-mii", "moca". Analogous to ePAPR
>> +  "phy-connection-type" values
>> +- address-cells: should be 1
>> +- size-cells: should be 1
>
>
>    The above two prop names should have # in front of them. Examples seem to
> be correct. Some words about the downstream bus wouldn't hurt too.

Absolutely, let me follow up with a patch fixing this.

>
> [...]
>
>> +Required child nodes:
>> +
>> +- mdio bus node: this node should always be present regarless of the PHY
>> +  configuration of the GENET instance
>> +
>> +MDIO bus node required properties:
>> +
>> +- compatible: should contain one of "brcm,genet-mdio-v1",
>> "brcm,genet-mdio-v2"
>> +  "brcm,genet-mdio-v3", "brcm,genet-mdio-v4", the version has to match
>> the
>> +  parent node compatible property (e.g: brcm,genet-v4 pairs with
>> +  brcm,genet-mdio-v4)
>> +- reg: address and length relative to the parent node base register
>> address
>> +- address-cells: address cell for MDIO bus addressing, should be 1
>> +- size-cells: size of the cells for MDIO bus addressing, should be 0
>
>
>    The above two props should have # in front of them as well. Examples seem
> to be correct.
>
> WBR, Sergei
>



-- 
Florian
