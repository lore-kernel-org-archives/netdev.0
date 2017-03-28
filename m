From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: genphy_read_status() vs. 1000bT Pause capability
Date: Wed, 29 Mar 2017 07:32:34 +1100
Message-ID: <1490733154.3177.130.camel@kernel.crashing.org>
References: <1490662190.3177.91.camel@kernel.crashing.org>
         <20170328010940.GG25549@lunn.ch>
         <1490668137.3177.98.camel@kernel.crashing.org>
         <1490669734.3177.100.camel@au1.ibm.com>
         <20170328041405.045FEB206B@b01ledav03.gho.pok.ibm.com>
         <1490678238.3177.102.camel@kernel.crashing.org>
         <20170328094252.GV7909@n2100.armlinux.org.uk>
         <1490699484.3177.120.camel@kernel.crashing.org>
         <20170328113104.GY7909@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51508 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751882AbdC1UdM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 16:33:12 -0400
In-Reply-To: <20170328113104.GY7909@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-03-28 at 12:31 +0100, Russell King - ARM Linux wrote:
> > Interesting. I tried and it worked :-) Could be something funny in
> > the config of our switches.
> 
> It could be that the switch supports pause frames, but it's not
> advertised because there's some corner cases that it doesn't work.  I
> know that SolidRun have run into switches that corrupt ethernet frames
> when pause is used.  (I don't know off hand which they are, but I could
> ask the question.)

I think this is Cisco gear, I'll check with our lab guy today. In the
meantime I'll test my driver back to back with some other machines, I
should find something that does pause eventually :-)

It's handy when you have a gigabit MAC on a 400Mhz ARM9 to be able to
throttle the peer despite all the other problems with Pause :-)

Cheers,
Ben.
