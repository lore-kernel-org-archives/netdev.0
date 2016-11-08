From: Mason <slash.tmp@free.fr>
Subject: Re: Ethernet not working on a different SoC with same eth HW
Date: Tue, 8 Nov 2016 16:41:23 +0100
Message-ID: <5821F223.5090508@free.fr>
References: <58176355.7090200@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Mans Rullgard <mans@mansr.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Timur Tabi <timur@codeaurora.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Uwe Kleine-Konig <u.kleine-koenig@pengutronix.de>,
        Daniel Mack <zonque@gmail.com>,
        Sebastian Frias <sf84@laposte.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:53713 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751676AbcKHPlt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Nov 2016 10:41:49 -0500
In-Reply-To: <58176355.7090200@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/10/2016 16:29, Mason wrote:

> I'm using these net drivers:
> 
>   drivers/net/ethernet/aurora/nb8800.c
>   drivers/net/phy/at803x.c
> 
> With a smp8758 board, they work great.
> I've been trying to use them on a different board:
> 
>   same eth PHY (Atheros AR8035)
>   same eth MAC (Aurora SSN8800)
>   different SoC (same base address for MAC block)
> 
> It doesn't work, and I'm not sure where to look first...

Sweet baby Jesus on a pogo stick...

After oh-so-many days making increasingly random changes,
hoping something would magically un-break, we did find a
*local* commit for an exotic platform (chip emulator) that
was causing the issue.

Regards.
