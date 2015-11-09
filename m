From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] mvneta: add FIXED_PHY dependency
Date: Mon, 09 Nov 2015 18:12:02 +0100
Message-ID: <4827390.CWKT8ytt79@wuerfel>
References: <4225885.EYXTHjRPmX@wuerfel> <6910088.dNmooXDTJR@wuerfel> <20151109170834.GE8644@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stas Sergeev <stsp@users.sourceforge.net>,
	"David S. Miller" <davem@davemloft.net>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151109170834.GE8644@n2100.arm.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 09 November 2015 17:08:34 Russell King - ARM Linux wrote:
> They are "optional" because when you're using a DSA switch, you don't
> specify a PHY (because, there isn't one).  For example, this is what
> I'm using with an Armada 388 board with a Marvell DSA switch.  The
> DSA does not appear as a PHY, and no node in the DSA stanza can be
> referenced for a phy entry in the ethernet device's stanza.
> 
>                         eth1: ethernet@30000 {
>                                 compatible = "marvell,armada-370-neta";
>                                 reg = <0x30000 0x4000>;
>                                 interrupts-extended = <&mpic 10>;
>                                 clocks = <&gateclk 3>;
>                                 managed = "in-band-status";
>                                 phy-mode = "sgmii";
>                                 status = "okay";
>                         };
> 
> 

Ok, then it would be nice to change the binding to reflect that,
and also document the "managed" property there.

	Arnd
