From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 0/7] Add MDIO bus multiplexer support for iProc SoCs
Date: Fri, 10 Jun 2016 23:27:08 -0700 (PDT)
Message-ID: <20160610.232708.520435980652214195.davem@davemloft.net>
References: <1465536831-13023-1-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	catalin.marinas@arm.com, will.deacon@arm.com, kishon@ti.com,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: pramod.kumar@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465536831-13023-1-git-send-email-pramod.kumar@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pramod Kumar <pramod.kumar@broadcom.com>
Date: Fri, 10 Jun 2016 11:03:44 +0530

> Broadcom iProc based SoCs use a MDIO bus multiplexer where child buses
> could be internal as well external to SoCs. These buses could supports
> MDIO transaction compatible to C-22/C-45.
> 
> Broadcom MDIO bus multiplexer is an integrated multiplexer where child bus
> selection and mdio transaction logic lies inside multiplexer itself.
> To accommodate this multiplexer in existing mux framework below changes
> were required-
> 
> 1. Passed MDIO parent bus via mdio_mux_init to MDIO mux framework.
> 
> This patch set includes MDIO bus multiplexer driver along with above
> framework change. It includes one external bus node having Ethernet PHY
> attached and two internal bus node holding PCIe PHYs.
 ...

Series applied, thanks.
