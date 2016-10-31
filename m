From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Ethernet not working on a different SoC with same eth HW
Date: Mon, 31 Oct 2016 16:37:04 +0100
Message-ID: <20161031153704.GD9441@lunn.ch>
References: <58176355.7090200@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Mans Rullgard <mans@mansr.com>,
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
Received: from vps0.lunn.ch ([178.209.37.122]:58782 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S944266AbcJaPhJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 11:37:09 -0400
Content-Disposition: inline
In-Reply-To: <58176355.7090200@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The regnum=5,4,1,1,a,9 logs keep repeating, endlessly.
> Is that expected?

Yes, that is expected, if you are not using interrupts. The phylib
state machine polls the state of the PHY once per second to see if
there has been a link up/down.

      Andrew
