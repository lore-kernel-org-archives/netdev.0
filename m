From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/6] bus: Add shared MDIO bus framework
Date: Tue, 26 Apr 2016 20:23:35 +0200
Message-ID: <20160426182335.GE30107@lunn.ch>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
 <20160426121335.GC11668@lunn.ch>
 <571FA3F6.7000903@gmail.com>
 <5167289.0a4LBoWhyX@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Pramod Kumar <pramod.kumar@broadcom.com>,
	Rob Herring <robh+dt@kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Chen-Yu Tsai <wens@csie.org>,
	Mark Rutland <mark.rutland@arm.com>,
	devicetree@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>,
	Suzuki K Poulose <suzuki.poulose@arm.com>,
	netdev@vger.kernel.org, Punit Agrawal <punit.agrawal@arm.com>,
	linux-kernel@vger.kernel.org,
	BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
	linux-arm-kernel@lists.infradead.org,
	Anup Patel <anup.patel@broadcom.com>,
	Kishon Vijay Abraham I <kishon@ti.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5167289.0a4LBoWhyX@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> A more complex problem would be having a PHY driver for a device
> that can be either an ethernet phy or some other phy.

I doubt that ever happens. You can have up to 32 different devices on
an MDIO bus. Since an Ethernet PHY and a "some other sort of PHY" are
completely different things, why would a hardware engineer place them
on the same address? It is like saying your ATA controller and VGA
controller share the same slot on the PCI bus...

   Andrew
