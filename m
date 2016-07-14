From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: phy: micrel: Add KSZ8041FTL fiber mode support
Date: Thu, 14 Jul 2016 16:33:26 +0200
Message-ID: <7346758.UKW3x0KYDY@wuerfel>
References: <1468506583-27299-1-git-send-email-p.zabel@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	devicetree@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Philipp Zabel <p.zabel@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:49946 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbcGNOdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 10:33:42 -0400
In-Reply-To: <1468506583-27299-1-git-send-email-p.zabel@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, July 14, 2016 4:29:43 PM CEST Philipp Zabel wrote:
> +
> + - micrel,fiber-mode: If present the PHY is configured to operate in fiber mode
> +
> +       Some PHYs, such as the KSZ8041FTL variant, support fiber mode, enabled
> +       by the FXEN boot strapping pin. It can't be determined from the PHY
> +       registers whether the PHY is in fiber mode, so this boolean device tree
> +       property can be used to describe it.
> +
> +       In fiber mode, auto-negotiation is disabled and the PHY can only work in
> +       100base-fx (full and half duplex) modes.
> 

Could the generic "phy-mode" property used for this, to avoid the need for
definingn a custom property?

	Arnd
