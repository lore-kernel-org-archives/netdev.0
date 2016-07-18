From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next v2 12/12] net: dsa: mv88e6xxx: add support
 for DSA ageing time
Date: Mon, 18 Jul 2016 21:32:53 +0200
Message-ID: <20160718193253.GJ31103@lunn.ch>
References: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com>
 <20160718184628.13103-13-vivien.didelot@savoirfairelinux.com>
 <20160718191644.GG31103@lunn.ch>
 <87d1malpcd.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44942 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751568AbcGRTc4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 15:32:56 -0400
Content-Disposition: inline
In-Reply-To: <87d1malpcd.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Nope, the bridge ageing time is not per-port, even though switchdev ops
> are per-port by design. This is a switch-wide attribute.

So you are saying the core is doing all the reference counting, etc,
when swapping between fast and slow ageing?

     Andrew
