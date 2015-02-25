From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx
 switches
Date: Wed, 25 Feb 2015 15:03:56 +0100
Message-ID: <20150225140356.GB17992@lunn.ch>
References: <1424799727-30946-1-git-send-email-zajec5@gmail.com>
 <20150224223039.GC1332@gospo.home.greyhouse.net>
 <CACna6rwBUqebNpf9XC21+LxZtR7xLn6wM-KWuxHR=E0KT6MSdQ@mail.gmail.com>
 <54ED017E.6000902@gmail.com>
 <20150225001534.GB15633@lunn.ch>
 <54ED19AB.7020003@gmail.com>
 <CACna6rzMcVd7SJ6NTBrrWtXe1ZTgxF5tgVb08eaPxxwTxWU1cg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>
To: Rafa?? Mi??ecki <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49095 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751848AbbBYOHA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 09:07:00 -0500
Content-Disposition: inline
In-Reply-To: <CACna6rzMcVd7SJ6NTBrrWtXe1ZTgxF5tgVb08eaPxxwTxWU1cg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> DSA doesn't allow me to use switch (hardware) VLANs. I would need to
> handle all forwarding in CPU. The most powerful Broadcom MIPS SoC -
> BCM4706 - can handle about 130 Mb/s. Less powerful - BCM4718A1 - only
> about 50 Mb/s.
> This is way too bad for performance when there is a 1 Gb/s switch and
> too bad for CPU usage.
 
Hi Rafa??

Take a step back. Don't assume VLANs is the only way to do this. Look
at what Florian is doing with Starfighter and Gunter is doing with
Marvell chips. Recent patches allow the hardware to do the switching
between ports with these devices. See if you can use a similar scheme
with your chip.

What we don't want is X chip families and Y different ways to
configure the features. Ideal we want X chip families, and one way to
configure them all.

	  Andrew
