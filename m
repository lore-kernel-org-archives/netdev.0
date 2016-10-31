From: Mason <slash.tmp@free.fr>
Subject: Re: Ethernet not working on a different SoC with same eth HW
Date: Mon, 31 Oct 2016 17:28:24 +0100
Message-ID: <58177128.8090403@free.fr>
References: <58176355.7090200@free.fr> <20161031153704.GD9441@lunn.ch>
 <581767BF.4020308@free.fr> <20161031155334.GF9441@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Mans Rullgard <mans@mansr.com>,
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
Received: from smtp5-g21.free.fr ([212.27.42.5]:21413 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1762201AbcJaQ2w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 12:28:52 -0400
In-Reply-To: <20161031155334.GF9441@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/10/2016 16:53, Andrew Lunn wrote:

>> I'll add a log for the request_irq call.
> 
> And take a look at /proc/interrupts

You're right, there does seem to be something wrong with the interrupts.

# cat /proc/interrupts 
           CPU0       
 20:      26285     GIC-0  29 Edge      twd
IPI0:          0  CPU wakeup interrupts
IPI1:          0  Timer broadcast interrupts
IPI2:          0  Rescheduling interrupts
IPI3:          0  Function call interrupts
IPI4:          0  CPU stop interrupts
IPI5:          0  IRQ work interrupts
IPI6:          0  completion interrupts
Err:          0

None of the expected platform interrupts (eth, phy, uart) are registered.

Thanks for pushing in a promising direction.

Regards.
