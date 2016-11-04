From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: Ethernet not working on a different SoC with same eth HW
Date: Fri, 04 Nov 2016 14:04:39 +0000
Message-ID: <yw1xtwbnjq88.fsf@unicorn.mansr.com>
References: <58176355.7090200@free.fr> <20161031153704.GD9441@lunn.ch>
        <581767BF.4020308@free.fr> <20161031155334.GF9441@lunn.ch>
        <58177128.8090403@free.fr> <581C8691.2060306@free.fr>
        <yw1xy40zjrcw.fsf@unicorn.mansr.com> <581C9273.906@free.fr>
        <20161104135752.GC3600@lunn.ch>
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
Received: from unicorn.mansr.com ([81.2.72.234]:43534 "EHLO unicorn.mansr.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752021AbcKDOEn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 10:04:43 -0400
In-Reply-To: <20161104135752.GC3600@lunn.ch> (Andrew Lunn's message of "Fri, 4
        Nov 2016 14:57:52 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

>> Considering the ethernet DT bindings:
>> 
>> https://www.kernel.org/doc/Documentation/devicetree/bindings/net/ethernet.txt
>> 
>> Specifically, phy-mode values "rgmii", "rgmii-id", "rgmii-rxid", "rgmii-txid".
>> 
>> Assuming that "rxid" (rx internal delay) and "rx clock delay" are
>> in fact the same concept with different names, do you agree that
>> it would be unexpected for "rgmii rx clock delay" to be enabled
>> when a DTB specifies "rgmii" or "rgmii-txid" ?
>
> I agree with you. But fixing it is likely to break boards which
> currently have "rgmii", but actually need the delay in order to work.

Does the internal delay here refer to the PHY or the MAC?  It's a
property of the MAC node after all.

-- 
Måns Rullgård
