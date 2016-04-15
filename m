From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: Re: [PATCH] net: phy: Ensure the state machine is called when phy is
 UP
Date: Sat, 16 Apr 2016 00:17:11 +0200
Message-ID: <20160415221711.GG25196@piout.net>
References: <1460750172-7796-1-git-send-email-alexandre.belloni@free-electrons.com>
 <57114AA4.5080803@gmail.com>
 <20160415205613.GE25196@piout.net>
 <20160415220508.GC26665@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:43276 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752397AbcDOWRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 18:17:14 -0400
Content-Disposition: inline
In-Reply-To: <20160415220508.GC26665@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/04/2016 at 00:05:08 +0200, Andrew Lunn wrote :
> > Trace without my patch:
> > libphy: MACB_mii_bus: probed
> > macb f8020000.ethernet eth0: Cadence GEM rev 0x00020120 at 0xf8020000 irq 27 (fc:c2:3d:0c:6e:05)
> > Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: attached PHY driver [Micrel KSZ8081 or KSZ8091] (mii_bus:phy_addr=f8020000.etherne:01, irq=171)
> > Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: PHY state change READY -> READY
> > [...]
> > Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: PHY state change READY -> READY
> 
> Are there some state changes before this? How is it getting to state
> READY? It would expect it to start in DOWN, from when the phy device
> was created in phy_device_create().
> 

No other changes. I forgot to mention that this is when booting with a
cable plugged in. Unplugging and replugging the cable makes the link
detection work fine even without the patch.

-- 
Alexandre Belloni, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
