From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Ethernet not working on a different SoC with same eth HW
Date: Fri, 4 Nov 2016 14:57:52 +0100
Message-ID: <20161104135752.GC3600@lunn.ch>
References: <58176355.7090200@free.fr>
 <20161031153704.GD9441@lunn.ch>
 <581767BF.4020308@free.fr>
 <20161031155334.GF9441@lunn.ch>
 <58177128.8090403@free.fr>
 <581C8691.2060306@free.fr>
 <yw1xy40zjrcw.fsf@unicorn.mansr.com>
 <581C9273.906@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mans Rullgard <mans@mansr.com>, netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Timur Tabi <timur@codeaurora.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Uwe Kleine-Konig <u.kleine-koenig@pengutronix.de>,
        Daniel Mack <zonque@gmail.com>,
        Sebastian Frias <sf84@laposte.net>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36938 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933194AbcKDN54 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 09:57:56 -0400
Content-Disposition: inline
In-Reply-To: <581C9273.906@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Considering the ethernet DT bindings:
> 
> https://www.kernel.org/doc/Documentation/devicetree/bindings/net/ethernet.txt
> 
> Specifically, phy-mode values "rgmii", "rgmii-id", "rgmii-rxid", "rgmii-txid".
> 
> Assuming that "rxid" (rx internal delay) and "rx clock delay" are
> in fact the same concept with different names, do you agree that
> it would be unexpected for "rgmii rx clock delay" to be enabled
> when a DTB specifies "rgmii" or "rgmii-txid" ?

I agree with you. But fixing it is likely to break boards which
currently have "rgmii", but actually need the delay in order to work.

	  Andrew
