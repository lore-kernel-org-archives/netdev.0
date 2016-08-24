From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/3 v2] net: smsc911x: augment device tree bindings
Date: Wed, 24 Aug 2016 17:55:41 +0200
Message-ID: <11789209.AN7vYDaEbx@wuerfel>
References: <1472043582-7653-1-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Steve Glendinning <steve.glendinning@smsc.com>,
        Guenter Roeck <linux@roeck-us.net>,
        Jeremy Linton <jeremy.linton@arm.com>,
        Kamlakant Patel <kamlakant.patel@broadcom.com>,
        Pavel Fedin <p.fedin@samsung.com>, devicetree@vger.kernel.org
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.134]:59441 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754353AbcHXP4o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 11:56:44 -0400
In-Reply-To: <1472043582-7653-1-git-send-email-linus.walleij@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, August 24, 2016 2:59:40 PM CEST Linus Walleij wrote:
> +- interrupts : Should contain the SMSC LAN
> +  interrupt line as cell 0, cell 1 is an OPTIONAL PME (power
> +  management event) interrupt that is able to wake up the host
> +  system with a 50ms pulse on network activity
> +  For generic bindings for interrupt controller parents, refer to
> +  interrupt-controller/interrupts.txt

I think you should (slightly) reword this to avoid using the
term "cell", which refers to a 32-bit word in the property,
not the interrupt specifier that is often made up of two or
three cells.

Maybe something like

- interrupts: one or two interrupt specifiers:
	- The first interrupt is the SMSC LAN interrupt line.
	- The second interrupt (if present) is the power management
	  event ...

	Arnd
