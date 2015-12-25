From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 25/28] Documentation: DSA: Describe how probe of DSA
 and switches work.
Date: Fri, 25 Dec 2015 11:00:02 +0100
Message-ID: <20151225100002.GA7136@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <1450875402-20740-26-git-send-email-andrew@lunn.ch>
 <567B089C.7030108@gmail.com>
 <20151223225322.GE25485@lunn.ch>
 <567C9C16.5020005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: narmstrong@baylibre.com, vivien.didelot@savoirfairelinux.com,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49541 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751575AbbLYKAG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Dec 2015 05:00:06 -0500
Content-Disposition: inline
In-Reply-To: <567C9C16.5020005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > It sounds like you want to 'optimise' for a DSA cluster consisting of
> > a single switch, throwing away the D in DSA. Now the SF2 is a bit
> > 'odd'. Since it is embedded in the SoC, you cannot have multiple of
> > them in a cluster. So such an optimization could make sense for the
> > SF2. But can we do this without adding too more complexity?
> 
> The distributed case is the complex one, the one with a single switch
> hanging off an Ethernet MAC is the most common one and is much simpler
> to deal with.

Sure, boards with multiple switches don't happen very often, but they
do exist. If we can solve the general case, a single switch just
works. The reverse is not true. Which is why i've been doing all my
development work on a board with three switches. And in theory, i
could even partition these into two DSA clusters!

	    Andrew
