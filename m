From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx
 switches
Date: Wed, 25 Feb 2015 01:51:06 +0100
Message-ID: <20150225005106.GB17034@lunn.ch>
References: <1424799727-30946-1-git-send-email-zajec5@gmail.com>
 <20150224215155.GA15633@lunn.ch>
 <CACna6ryiyzeGDoFwSpkOQ9MnumQxB699vEtoY=XRwaD9HE0ryA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>
To: Rafa?? Mi??ecki <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48793 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752833AbbBYAyG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 19:54:06 -0500
Content-Disposition: inline
In-Reply-To: <CACna6ryiyzeGDoFwSpkOQ9MnumQxB699vEtoY=XRwaD9HE0ryA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> That said, I'm not aware of any better place for switchdev drivers.

Reading Florian's email, it seems like this should be placed into
drivers/net/dsa, and refactored to use the DSA API.

	 Andrew
