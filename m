From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: genphy_read_status() vs. 1000bT Pause capability
Date: Tue, 28 Mar 2017 22:11:24 +1100
Message-ID: <1490699484.3177.120.camel@kernel.crashing.org>
References: <1490662190.3177.91.camel@kernel.crashing.org>
         <20170328010940.GG25549@lunn.ch>
         <1490668137.3177.98.camel@kernel.crashing.org>
         <1490669734.3177.100.camel@au1.ibm.com>
         <20170328041405.045FEB206B@b01ledav03.gho.pok.ibm.com>
         <1490678238.3177.102.camel@kernel.crashing.org>
         <20170328094252.GV7909@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:38201 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755092AbdC1LL4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 07:11:56 -0400
In-Reply-To: <20170328094252.GV7909@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-03-28 at 10:42 +0100, Russell King - ARM Linux wrote:
> The 1000X definitions are for 1000BaseX (fiber), not for 1000BaseT
> (copper).
> 
> I have a working setup here with gigabit pause.  The pause bits come
> from bits 11 and 10, just like for older copper PHYs.  Your link
> parter is indicating that it has no pause capability.  That means
> you can't use pause.

Interesting. I tried and it worked :-) Could be something funny in
the config of our switches.

Thanks for the explanation.

Cheers,
Ben.
