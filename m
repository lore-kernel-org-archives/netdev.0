From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] net: convert mvneta to build_skb()
Date: Mon, 15 Jul 2013 19:01:00 +0200
Message-ID: <20130715170100.GB10157@1wt.eu>
References: <20130704173552.GA23370@1wt.eu> <20130715163408.4064699f@skate> <20130715151240.GD6844@1wt.eu> <20130715172321.61e8c237@skate> <20130715153049.GE6844@1wt.eu> <20130715173523.4505e8c4@skate> <CAGVrzcYvFr8o+v=Ryc1GVA+7qTLGjxEUC3pB6t06YgTsmu0MAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev <netdev@vger.kernel.org>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:34656 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932167Ab3GORBE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jul 2013 13:01:04 -0400
Content-Disposition: inline
In-Reply-To: <CAGVrzcYvFr8o+v=Ryc1GVA+7qTLGjxEUC3pB6t06YgTsmu0MAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Mon, Jul 15, 2013 at 04:52:44PM +0100, Florian Fainelli wrote:
> > I still believe this is not the right fix, but unfortunately, I haven't
> > had the time to work on what would be the right fix. Hardware PHY
> > polling has been intentionally disabled, and the driver should work
> > without, since the PHY polling is done in software by the phylib.
> 
> You may now be able to use the PHY interrupt bit from your MAC
> interrupt handler and call phy_mac_interrupt() provided by libphy. I
> added it specifically to be able to use PHY link interrupts connected
> to the MAC.

Thanks for the tip. I'm not seeing any interrupt when I plug/unplug a
cable, so maybe we first need to set a specific bit in the interrupt
mask to enable interrupt delivery on link state change prior to this.

Regards,
Willy
