From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/2] net: dsa: mv88e6xxx: Add 88E6176 device tree support
Date: Mon, 28 Nov 2016 00:10:09 +0100
Message-ID: <20161127231009.GA17704@lunn.ch>
References: <1480280279-9552-1-git-send-email-afaerber@suse.de>
 <1480280279-9552-2-git-send-email-afaerber@suse.de>
 <20161127212709.GD13318@lunn.ch>
 <9500470d-09c3-3ecb-994b-3d108bffc99e@suse.de>
 <20161127220846.GH13318@lunn.ch>
 <e5d45b55-a4c1-3b5e-0bdc-a5e340b072d0@suse.de>
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
Received: from vps0.lunn.ch ([178.209.37.122]:58883 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752203AbcK0XKR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 18:10:17 -0500
Content-Disposition: inline
In-Reply-To: <e5d45b55-a4c1-3b5e-0bdc-a5e340b072d0@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Try to see it from my perspective: I see that some vf610 device I don't
> have (found via `git grep marvell,mv88e6` or so) uses
> "marvell,mv88e6085". I then assume it has that device on board. How
> would I know it doesn't? Same for the other boards you mention.
> 
> Unfortunately some of your replies are slightly cryptic. Had you simply
> replied 'please just use "marvell,mv88e6085" instead', it would've been
> much more clear what you want. (Same for extending the subject instead
> of just pointing to some FAQ.)

By reading the FAQ you have learnt more than me saying put the correct
tree in the subject line. By asking you to explain why you need a
compatible string, i'm trying to make you think, look at the code and
understand it. In the future, you might think and understand the code
before posting a patch, and then we all save time.

> So are you okay with patch 1/2 documenting the compatible? Then we could
> drop 2/2 and use "marvell,mv88e6176", "marvell,mv88e6085" instead of
> just the latter. Or would you rather drop both and keep the actual chip
> a comment?

A comment only please.

Thanks
	Andrew
