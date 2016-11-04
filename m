From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Ethernet not working on a different SoC with same eth HW
Date: Fri, 4 Nov 2016 16:17:44 +0100
Message-ID: <20161104151744.GG3600@lunn.ch>
References: <581767BF.4020308@free.fr>
 <20161031155334.GF9441@lunn.ch>
 <58177128.8090403@free.fr>
 <581C8691.2060306@free.fr>
 <yw1xy40zjrcw.fsf@unicorn.mansr.com>
 <581C9273.906@free.fr>
 <20161104135752.GC3600@lunn.ch>
 <yw1xtwbnjq88.fsf@unicorn.mansr.com>
 <20161104142223.GD3600@lunn.ch>
 <yw1xpombjnfn.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
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
Received: from vps0.lunn.ch ([178.209.37.122]:37031 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934358AbcKDPRs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 11:17:48 -0400
Content-Disposition: inline
In-Reply-To: <yw1xpombjnfn.fsf@unicorn.mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 04, 2016 at 03:05:00PM +0000, Måns Rullgård wrote:
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> >> > I agree with you. But fixing it is likely to break boards which
> >> > currently have "rgmii", but actually need the delay in order to work.
> >> 
> >> Does the internal delay here refer to the PHY or the MAC?  It's a
> >> property of the MAC node after all.
> >
> > It is the PHY which applies the delay.
> 
> Says who?

The source code.

>  Some MACs can do it too.

I'm sure they can. But look at the code. Nearly none do, and those
that do are potentially broken.
 
> There is also no way to specify the amount of delay required even though
> many devices support more than one value.

Those PHYs that which support variable delays add there own device
tree properties. See for example Micrel KSZ9021/KSZ9031 Gigabit Ethernet PHY

     Andrew
