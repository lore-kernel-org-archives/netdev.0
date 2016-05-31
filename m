From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/7] binding: mdio-mux: Add DT binding doc for Broadcom
 MDIO bus mutiplexer
Date: Tue, 31 May 2016 14:27:57 +0200
Message-ID: <20160531122757.GD24402@lunn.ch>
References: <1464592251-2688-1-git-send-email-pramod.kumar@broadcom.com>
 <1464592251-2688-4-git-send-email-pramod.kumar@broadcom.com>
 <20160530152426.GM6027@lunn.ch>
 <e002ac1b95d8ee4725f7315427f65fbf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-arm-kernel@lists.infradead.org
To: Pramod Kumar <pramod.kumar@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <e002ac1b95d8ee4725f7315427f65fbf@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Yes. I agree. We will logical OR MII_ADDR_C45 into the address from PHY
> drivers. Is there any standard property exist for non-ethernet-phy DRIVERS
> to decide the whether PHY node support C45 or C22?

Why do you even need this in the device tree? If the driver needs to
access a register > 31, it knows it must use C45. If it is less than
32, it can use either C22 or C45.

    Andrew
