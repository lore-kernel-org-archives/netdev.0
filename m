From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] Doc: Micrel-ksz90x1.txt: Document deprecated MAC OF properties
Date: Wed, 09 Dec 2015 13:46:08 -0800
Message-ID: <C503A8D0-5FBB-4324-8C9D-3469C897999E@gmail.com>
References: <1449686343-14925-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:34891 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555AbbLIVqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 16:46:15 -0500
Received: by obc18 with SMTP id 18so44605463obc.2
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 13:46:14 -0800 (PST)
In-Reply-To: <1449686343-14925-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On December 9, 2015 10:39:03 AM PST, Andrew Lunn <andrew@lunn.ch> wrote:
>Phy properties are expected to be found in the PHY OF node. However
>this Micrel driver also allows them to be placed into the MAC OF node.
>This is deprecated. Document it as such, and remove the example using
>the deprecated method to prevent people copying it into new device
>tree files.
>
>Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

>---
>.../devicetree/bindings/net/micrel-ksz90x1.txt          | 17
>++++-------------
> 1 file changed, 4 insertions(+), 13 deletions(-)
>
>diff --git a/Documentation/devicetree/bindings/net/micrel-ksz90x1.txt
>b/Documentation/devicetree/bindings/net/micrel-ksz90x1.txt
>index 692076fda0e5..f9c32adab5c6 100644
>--- a/Documentation/devicetree/bindings/net/micrel-ksz90x1.txt
>+++ b/Documentation/devicetree/bindings/net/micrel-ksz90x1.txt
>@@ -1,8 +1,9 @@
> Micrel KSZ9021/KSZ9031 Gigabit Ethernet PHY
> 
>-Some boards require special tuning values, particularly when it comes
>to
>-clock delays. You can specify clock delay values by adding
>-micrel-specific properties to an Ethernet OF device node.
>+Some boards require special tuning values, particularly when it comes
>+to clock delays. You can specify clock delay values in the PHY OF
>+device node. Deprecated, but still supported, these properties can
>+also be added to an Ethernet OF device node.
> 
> Note that these settings are applied after any phy-specific fixup from
> phy_fixup_list (see phy_init_hw() from drivers/net/phy/phy_device.c),
>@@ -57,16 +58,6 @@ KSZ9031:
> 
> Examples:
> 
>-	/* Attach to an Ethernet device with autodetected PHY */
>-	&enet {
>-		rxc-skew-ps = <3000>;
>-		rxdv-skew-ps = <0>;
>-		txc-skew-ps = <3000>;
>-		txen-skew-ps = <0>;
>-		status = "okay";
>-	};
>-
>-	/* Attach to an explicitly-specified PHY */
> 	mdio {
> 		phy0: ethernet-phy@0 {
> 			rxc-skew-ps = <3000>;


-- 
Sent from my Android device with K-9 Mail. Please excuse my brevity.
