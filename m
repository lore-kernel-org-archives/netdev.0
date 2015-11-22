From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH 02/13] net: mvneta: enable IP checksum with jumbo frames
 for Armada 38x on Port0
Date: Sun, 22 Nov 2015 22:55:03 +0100
Message-ID: <CAPv3WKfW+V+dohsqcM7OLm3EBTqM9v-_96=Bkfu-BKoJV7Ss=g@mail.gmail.com>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
	<4040597.3hXVb3XDMS@wuerfel>
	<CAPv3WKdOVf4kXHfrawgybggHggAEJ9wJh=8gyp_mEhWp2i=YFw@mail.gmail.com>
	<5578695.0ahxvoVWDX@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Simon Guinot <simon.guinot@sequanux.org>,
	linux-kernel@vger.kernel.org, Evan Wang <xswang@marvell.com>,
	nadavh@marvell.com, nitroshift@yahoo.com,
	Lior Amsalem <alior@marvell.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Grzegorz Jaszczyk <jaz@semihalf.com>,
	=?UTF-8?Q?Gregory_Cl=C3=A9ment?=
	<gregory.clement@free-electrons.com>,
	Tomasz Nowicki <tn@semihalf.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Yair Mahalalel <myair@marvell.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <5578695.0ahxvoVWDX@wuerfel>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd,

>
> If the feature set depends on the port number, we should think about
> the way it gets handled again, as this is probably better not described
> as something that depends (just) on the SoC, but on the way it gets
> integrated. Maybe we can introduce an additional property for the
> checksums on jumbo frames and use that if present but fall back to
> identifying by compatible string otherwise.
>

I think adding a property, taking also compatible strings will be the
best solution.

Best regards,
Marcin
