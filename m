From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 1/6] net: dsa: Use delayed work instead of timer+work
 for polling
Date: Thu, 29 Oct 2015 16:28:02 +0100
Message-ID: <20151029152802.GX2307@lunn.ch>
References: <56321DA1.4060304@baylibre.com>
 <20151029135156.GQ2307@lunn.ch>
 <563228C3.6010501@baylibre.com>
 <20151029144012.GT2307@lunn.ch>
 <20151029145234.GB21131@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Armstrong <narmstrong@baylibre.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151029145234.GB21131@ketchup.mtl.sfl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Is 6060 supported by the 6352 family? It doesn't share any mv88e6xxx
> code...

It is a totally separate driver. Nothing shared at all..  It is an old
device, and only does 10/100. It could be it is just too different to
support via mv88e6xxx.

   Andrew
