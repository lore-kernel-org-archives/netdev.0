From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next v2 12/12] net: dsa: mv88e6xxx: add support
 for DSA ageing time
Date: Mon, 18 Jul 2016 23:26:24 +0200
Message-ID: <20160718212624.GU31103@lunn.ch>
References: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com>
 <20160718184628.13103-13-vivien.didelot@savoirfairelinux.com>
 <20160718191644.GG31103@lunn.ch>
 <87d1malpcd.fsf@ketchup.mtl.sfl>
 <20160718193253.GJ31103@lunn.ch>
 <87eg6q3efp.fsf@ketchup.mtl.sfl>
 <20160718201334.GS31103@lunn.ch>
 <87k2gibrz0.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45046 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751603AbcGRV03 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 17:26:29 -0400
Content-Disposition: inline
In-Reply-To: <87k2gibrz0.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> OK. I think caching per-port (and thus per-bridge) ageing time would do
> the trick and keep DSA drivers simple. What about the following patch?

Hi Vivien

This looks good. I would suggest you do some testing with a printk,
and force some topology changes, just to make sure it works how we
think it works.

	Andrew
