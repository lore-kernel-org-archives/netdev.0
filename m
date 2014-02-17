From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v5 09/10] Documentation: add Device tree bindings
 for Broadcom GENET
Date: Tue, 18 Feb 2014 02:10:58 +0300
Message-ID: <53029702.6010803@cogentembedded.com>
References: <1392336531-28875-1-git-send-email-f.fainelli@gmail.com> <1392336531-28875-10-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, devicetree@vger.kernel.org,
	cernekee@gmail.com, mark.rutland@arm.com, romieu@fr.zoreil.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:51464 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbaBQWLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 17:11:03 -0500
Received: by mail-lb0-f182.google.com with SMTP id w7so11795073lbi.13
        for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 14:11:01 -0800 (PST)
In-Reply-To: <1392336531-28875-10-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02/14/2014 03:08 AM, Florian Fainelli wrote:

> This patch adds the Device Tree bindings for the Broadcom GENET Gigabit
> Ethernet controller. A bunch of examples are provided to illustrate the
> versatile aspect of the hardare.

> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
[...]

    Too bad I didn't read this patch before and now it has been already applied.

[...]

> diff --git a/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
> new file mode 100644
> index 0000000..afd31f9
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
> @@ -0,0 +1,121 @@
> +* Broadcom BCM7xxx Ethernet Controller (GENET)
> +
> +Required properties:
> +- compatible: should contain one of "brcm,genet-v1", "brcm,genet-v2",
> +  "brcm,genet-v3", "brcm,genet-v4".
> +- reg: address and length of the register set for the device
> +- interrupts: must be two cells, the first cell is the general purpose
> +  interrupt line, while the second cell is the interrupt for the ring
> +  RX and TX queues operating in ring mode
> +- phy-mode: String, operation mode of the PHY interface. Supported values are
> +  "mii", "rgmii", "rgmii-txid", "rev-mii", "moca". Analogous to ePAPR
> +  "phy-connection-type" values
> +- address-cells: should be 1
> +- size-cells: should be 1

    The above two prop names should have # in front of them. Examples seem to 
be correct. Some words about the downstream bus wouldn't hurt too.

[...]
> +Required child nodes:
> +
> +- mdio bus node: this node should always be present regarless of the PHY
> +  configuration of the GENET instance
> +
> +MDIO bus node required properties:
> +
> +- compatible: should contain one of "brcm,genet-mdio-v1", "brcm,genet-mdio-v2"
> +  "brcm,genet-mdio-v3", "brcm,genet-mdio-v4", the version has to match the
> +  parent node compatible property (e.g: brcm,genet-v4 pairs with
> +  brcm,genet-mdio-v4)
> +- reg: address and length relative to the parent node base register address
> +- address-cells: address cell for MDIO bus addressing, should be 1
> +- size-cells: size of the cells for MDIO bus addressing, should be 0

    The above two props should have # in front of them as well. Examples seem 
to be correct.

WBR, Sergei
