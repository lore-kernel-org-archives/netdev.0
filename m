From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: genphy_read_status() vs. 1000bT Pause capability
Date: Tue, 28 Mar 2017 12:31:05 +0100
Message-ID: <20170328113104.GY7909@n2100.armlinux.org.uk>
References: <1490662190.3177.91.camel@kernel.crashing.org>
 <20170328010940.GG25549@lunn.ch>
 <1490668137.3177.98.camel@kernel.crashing.org>
 <1490669734.3177.100.camel@au1.ibm.com>
 <20170328041405.045FEB206B@b01ledav03.gho.pok.ibm.com>
 <1490678238.3177.102.camel@kernel.crashing.org>
 <20170328094252.GV7909@n2100.armlinux.org.uk>
 <1490699484.3177.120.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:54518 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932192AbdC1LhW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 07:37:22 -0400
Content-Disposition: inline
In-Reply-To: <1490699484.3177.120.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 10:11:24PM +1100, Benjamin Herrenschmidt wrote:
> On Tue, 2017-03-28 at 10:42 +0100, Russell King - ARM Linux wrote:
> > The 1000X definitions are for 1000BaseX (fiber), not for 1000BaseT
> > (copper).
> > 
> > I have a working setup here with gigabit pause.  The pause bits come
> > from bits 11 and 10, just like for older copper PHYs.  Your link
> > parter is indicating that it has no pause capability.  That means
> > you can't use pause.
> 
> Interesting. I tried and it worked :-) Could be something funny in
> the config of our switches.

It could be that the switch supports pause frames, but it's not
advertised because there's some corner cases that it doesn't work.  I
know that SolidRun have run into switches that corrupt ethernet frames
when pause is used.  (I don't know off hand which they are, but I could
ask the question.)

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
