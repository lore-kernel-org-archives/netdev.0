From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/2] net: dsa: mv88e6xxx: Add 88E6176 device tree support
Date: Sun, 27 Nov 2016 23:08:46 +0100
Message-ID: <20161127220846.GH13318@lunn.ch>
References: <1480280279-9552-1-git-send-email-afaerber@suse.de>
 <1480280279-9552-2-git-send-email-afaerber@suse.de>
 <20161127212709.GD13318@lunn.ch>
 <9500470d-09c3-3ecb-994b-3d108bffc99e@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <uwe@kleine-koenig.org>,
        Michal Hrusecki <Michal.Hrusecky@nic.cz>,
        Tomas Hlavacek <tomas.hlavacek@nic.cz>,
        Bed??icha Ko??atu <bedrich.kosata@nic.cz>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        linux-kernel@vger.kernel.org
To: Andreas =?iso-8859-1?Q?F=E4rber?= <afaerber@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58822 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752203AbcK0WJA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 17:09:00 -0500
Content-Disposition: inline
In-Reply-To: <9500470d-09c3-3ecb-994b-3d108bffc99e@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > This driver already supports nearly 30 different Marvell switch
> > models. Please document why the marvell,mv88e6176 is special and why
> > it needs its own compatible string when the others don't.
> 
> I don't understand.

Think about what i said. Why does the 6176 need its own compatible
string, when the two 6352s and the 6165 on the zii-devel-b don't have
one? And the DIR 665 has a 6171, which does not have a compatible
string of its own. The clearfog actually has a 6176, and it seems to
work fine without a compatible string.

> You as driver author should know that the .data pointer is vital to your
> driver

Exactly, so if i ask why is it needed, maybe you should stop and think
for a while.

> you even recently accepted another model that conflicted with
> my patch.

And think about that also, and you will find the 6390 family, who's
first device is 6190, is not compatible with the 6085, and so needs a
different compatible string.

	  Andrew
