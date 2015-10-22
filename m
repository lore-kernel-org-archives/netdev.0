From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: mv88e6060: Fix false positive lockdep splat
Date: Thu, 22 Oct 2015 14:06:07 +0200
Message-ID: <20151022120607.GD1985@lunn.ch>
References: <5627B149.6030109@baylibre.com>
 <20151021161416.GG17207@lunn.ch>
 <56289967.6010909@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org,
	sergei.shtylyov@cogentembedded.com
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35795 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750978AbbJVMGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2015 08:06:22 -0400
Content-Disposition: inline
In-Reply-To: <56289967.6010909@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Well, mdio-mux also calls switch_fn inside the mdio_lock, clean refactoring
> would introduce a separate lock and call the nested variants.
> Is that ok ? Can someone test mdio-mux if I make the change ?

Hi Neil

I would not touch mdio-mux. As you said, it does more than lock, read,
unlock. It is not something sufficiently generic to place into shared
code.

	Andrew
