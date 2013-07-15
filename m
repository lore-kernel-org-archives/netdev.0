From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: convert mvneta to build_skb()
Date: Mon, 15 Jul 2013 21:44:14 +0200
Message-ID: <20130715214414.1f885ba8@skate>
References: <20130704173552.GA23370@1wt.eu>
	<20130715163408.4064699f@skate>
	<20130715151240.GD6844@1wt.eu>
	<20130715172321.61e8c237@skate>
	<20130715153049.GE6844@1wt.eu>
	<20130715173523.4505e8c4@skate>
	<CAGVrzcYvFr8o+v=Ryc1GVA+7qTLGjxEUC3pB6t06YgTsmu0MAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, netdev <netdev@vger.kernel.org>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:59671 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755697Ab3GOToT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jul 2013 15:44:19 -0400
In-Reply-To: <CAGVrzcYvFr8o+v=Ryc1GVA+7qTLGjxEUC3pB6t06YgTsmu0MAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Florian Fainelli,

On Mon, 15 Jul 2013 16:52:44 +0100, Florian Fainelli wrote:

> > I still believe this is not the right fix, but unfortunately, I haven't
> > had the time to work on what would be the right fix. Hardware PHY
> > polling has been intentionally disabled, and the driver should work
> > without, since the PHY polling is done in software by the phylib.
> 
> You may now be able to use the PHY interrupt bit from your MAC
> interrupt handler and call phy_mac_interrupt() provided by libphy. I
> added it specifically to be able to use PHY link interrupts connected
> to the MAC.

Right, but the MAC feature in question makes the MAC directly talks to
the PHY to configure it, completely bypassing the entire libphy logic.
I am not sure how to handle this together with libphy.

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
