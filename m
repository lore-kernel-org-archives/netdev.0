From: Mason <slash.tmp@free.fr>
Subject: Re: Ethernet not working on a different SoC with same eth HW
Date: Fri, 4 Nov 2016 15:13:45 +0100
Message-ID: <581C9799.3040101@free.fr>
References: <58176355.7090200@free.fr> <20161031153704.GD9441@lunn.ch>
 <581767BF.4020308@free.fr> <20161031155334.GF9441@lunn.ch>
 <58177128.8090403@free.fr> <581C8691.2060306@free.fr>
 <yw1xy40zjrcw.fsf@unicorn.mansr.com> <581C9273.906@free.fr>
 <20161104135752.GC3600@lunn.ch> <yw1xtwbnjq88.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Timur Tabi <timur@codeaurora.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Uwe Kleine-Konig <u.kleine-koenig@pengutronix.de>,
        Daniel Mack <zonque@gmail.com>,
        Sebastian Frias <sf84@laposte.net>
To: Mans Rullgard <mans@mansr.com>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:55265 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753185AbcKDOOO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 10:14:14 -0400
In-Reply-To: <yw1xtwbnjq88.fsf@unicorn.mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2016 15:04, Måns Rullgård wrote:

> Andrew Lunn <andrew@lunn.ch> writes:
> 
>>> Considering the ethernet DT bindings:
>>>
>>> https://www.kernel.org/doc/Documentation/devicetree/bindings/net/ethernet.txt
>>>
>>> Specifically, phy-mode values "rgmii", "rgmii-id", "rgmii-rxid", "rgmii-txid".
>>>
>>> Assuming that "rxid" (rx internal delay) and "rx clock delay" are
>>> in fact the same concept with different names, do you agree that
>>> it would be unexpected for "rgmii rx clock delay" to be enabled
>>> when a DTB specifies "rgmii" or "rgmii-txid" ?
>>
>> I agree with you. But fixing it is likely to break boards which
>> currently have "rgmii", but actually need the delay in order to work.
> 
> Does the internal delay here refer to the PHY or the MAC?  It's a
> property of the MAC node after all.

Isn't there a one-to-one correspondence between MAC and PHY?

Can a MAC be connected to multiple PHYs?
Can a PHY be connected to multiple MACs?

If it is a one-to-one correspondence, then whether the
property is specified in the MAC or PHY node is just a
matter of presentation, IMHO.

Regards.
