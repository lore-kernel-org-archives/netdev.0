From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/6] bus: Add shared MDIO bus framework
Date: Tue, 26 Apr 2016 19:45:05 +0200
Message-ID: <20160426174505.GD11668@lunn.ch>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
 <1461230323-27891-2-git-send-email-pramod.kumar@broadcom.com>
 <20160425205650.GA31129@lunn.ch>
 <666dffb41a922b0c8638f2f002a2de08@mail.gmail.com>
 <20160426121335.GC11668@lunn.ch>
 <571FA3F6.7000903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pramod Kumar <pramod.kumar@broadcom.com>,
	Mark Rutland <mark.rutland@arm.com>,
	devicetree@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Pawel Moll <pawel.moll@arm.com>,
	Suzuki K Poulose <suzuki.poulose@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Punit Agrawal <punit.agrawal@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	linux-kernel@vger.kernel.org,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Chen-Yu Tsai <wens@csie.org>, Rob Herring <robh+dt@kernel.org>,
	BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Anup Patel <anup.patel@broadcom.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <571FA3F6.7000903@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I am not clear on how common a shared MDIO bus is on other SoCs, but the
> other Broadcom SoCs I am familiar with have dedicated MDIO buses
> instances per type of PHY (PCIe, BUSB, Ethernet), thus making the split
> a ton easier.

I don't actually see this shared bus being an issue, once the mux it
implemented. With the mux, you see N MDIO busses, each acting like a
normal MDIO bus. I've used the GPIO variety and had no issues:

http://marc.info/?l=linux-arm-kernel&m=145910090401796&w=2

	Andrew
