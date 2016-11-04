From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Ethernet not working on a different SoC with same eth HW
Date: Fri, 4 Nov 2016 15:22:23 +0100
Message-ID: <20161104142223.GD3600@lunn.ch>
References: <58176355.7090200@free.fr>
 <20161031153704.GD9441@lunn.ch>
 <581767BF.4020308@free.fr>
 <20161031155334.GF9441@lunn.ch>
 <58177128.8090403@free.fr>
 <581C8691.2060306@free.fr>
 <yw1xy40zjrcw.fsf@unicorn.mansr.com>
 <581C9273.906@free.fr>
 <20161104135752.GC3600@lunn.ch>
 <yw1xtwbnjq88.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mason <slash.tmp@free.fr>, netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Timur Tabi <timur@codeaurora.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Uwe Kleine-Konig <u.kleine-koenig@pengutronix.de>,
        Daniel Mack <zonque@gmail.com>,
        Sebastian Frias <sf84@laposte.net>
To: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36974 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934520AbcKDOW0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 10:22:26 -0400
Content-Disposition: inline
In-Reply-To: <yw1xtwbnjq88.fsf@unicorn.mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I agree with you. But fixing it is likely to break boards which
> > currently have "rgmii", but actually need the delay in order to work.
> 
> Does the internal delay here refer to the PHY or the MAC?  It's a
> property of the MAC node after all.

It is the PHY which applies the delay.

The phy-mode property is in the MAC part of the device tree binding,
but the delay is not the primary purpose of this property. Its primary
purpose, RGMII, RMII, SGMII, etc, is applicable to both the MAC and
the PHY. It probably would of been better to have the delays as a
separate property, but that is not how it is...

	 Andrew
