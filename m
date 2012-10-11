From: Rob Herring <robherring2@gmail.com>
Subject: Re: [PATCH v2 1/4] net: mvneta: driver for Marvell Armada 370/XP
 network unit
Date: Thu, 11 Oct 2012 10:46:57 -0500
Message-ID: <5076E9F1.60200@gmail.com>
References: <1349969282-12676-1-git-send-email-thomas.petazzoni@free-electrons.com> <1349969282-12676-2-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>,
	Rami Rosen <rosenr@marvell.com>, netdev@vger.kernel.org,
	Maen Suleiman <maen@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:40456 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754241Ab2JKPrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 11:47:00 -0400
Received: by mail-ob0-f174.google.com with SMTP id uo13so1835913obb.19
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 08:47:00 -0700 (PDT)
In-Reply-To: <1349969282-12676-2-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/11/2012 10:27 AM, Thomas Petazzoni wrote:
> This patch contains a new network driver for the network unit of the
> ARM Marvell Armada 370 and the Armada XP. Both SoCs use the PJ4B
> processor, a Marvell-developed ARM core that implements the ARMv7
> instruction set.


> diff --git a/Documentation/devicetree/bindings/net/marvell-neta.txt b/Documentation/devicetree/bindings/net/marvell-neta.txt
> new file mode 100644
> index 0000000..a031978
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/marvell-neta.txt
> @@ -0,0 +1,24 @@
> +* Marvell Armada 370 / Armada XP Ethernet Controller (NETA)
> +
> +Required properties:
> +- compatible: should be "marvell,neta".

This should be more specific such as "marvell,armada-xp-neta".

Or use 370 instead of xp. It should be which ever chip came first.

> +- reg: address and length of the register set for the device.
> +- interrupts: interrupt for the device
> +- phy-mode: String, operation mode of the PHY interface. Supported
> +  values are "sgmii" and "rmii".
> +- phy-addr: Integer, address of the PHY.
> +- device_type: should be "network".

Drop this. device_type is not used for FDT.

> +- clock-frequency: frequency of the peripheral clock of the SoC.
> +
> +Example:
> +
> +eth@d0070000 {

Should be ethernet@...

Rob
