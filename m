From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Refactor nested mdiobus read/write functions
Date: Fri, 23 Oct 2015 06:00:57 -0700 (PDT)
Message-ID: <20151023.060057.1037546088147637288.davem@davemloft.net>
References: <5628A059.1020402@baylibre.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	fabf@skynet.be, pavel.nakonechny@skitlab.ru, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nbd@openwrt.org, sergei.shtylyov@cogentembedded.com
To: narmstrong@baylibre.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34746 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206AbbJWMo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 08:44:29 -0400
In-Reply-To: <5628A059.1020402@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Armstrong <narmstrong@baylibre.com>
Date: Thu, 22 Oct 2015 10:37:45 +0200

> In order to avoid locked signal false positive for nested mdiobus
> read/write calls, nested code was introduced in mv88e6xxx and
> mdio-mux.
> But mv88e6060 also needs such nested mdiobus read/write calls.
> For sake of refactoring, introduce nested variants of mdiobus read/write
> and make them used by mv88e6xxx and mv88e6060.
> In a next patch, mdio-mux should also use these variant calls.

Series applied, thanks.
