From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: Ethernet not working on a different SoC with same eth HW
Date: Fri, 04 Nov 2016 15:05:00 +0000
Message-ID: <yw1xpombjnfn.fsf@unicorn.mansr.com>
References: <58176355.7090200@free.fr> <20161031153704.GD9441@lunn.ch>
        <581767BF.4020308@free.fr> <20161031155334.GF9441@lunn.ch>
        <58177128.8090403@free.fr> <581C8691.2060306@free.fr>
        <yw1xy40zjrcw.fsf@unicorn.mansr.com> <581C9273.906@free.fr>
        <20161104135752.GC3600@lunn.ch> <yw1xtwbnjq88.fsf@unicorn.mansr.com>
        <20161104142223.GD3600@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Mason <slash.tmp@free.fr>, netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Timur Tabi <timur@codeaurora.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Uwe Kleine-Konig <u.kleine-koenig@pengutronix.de>,
        Daniel Mack <zonque@gmail.com>,
        Sebastian Frias <sf84@laposte.net>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:43610 "EHLO unicorn.mansr.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934595AbcKDPFH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 11:05:07 -0400
In-Reply-To: <20161104142223.GD3600@lunn.ch> (Andrew Lunn's message of "Fri, 4
        Nov 2016 15:22:23 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

>> > I agree with you. But fixing it is likely to break boards which
>> > currently have "rgmii", but actually need the delay in order to work.
>> 
>> Does the internal delay here refer to the PHY or the MAC?  It's a
>> property of the MAC node after all.
>
> It is the PHY which applies the delay.

Says who?  Some MACs can do it too.

> The phy-mode property is in the MAC part of the device tree binding,
> but the delay is not the primary purpose of this property. Its primary
> purpose, RGMII, RMII, SGMII, etc, is applicable to both the MAC and
> the PHY. It probably would of been better to have the delays as a
> separate property, but that is not how it is...

The connection type is obviously the same at both ends, so it doesn't
really matter where that is specified.  The delay can be applied at
either end or not at all, and it's anything but clear what the
properties are supposed to mean.

There is also no way to specify the amount of delay required even though
many devices support more than one value.

-- 
Måns Rullgård
