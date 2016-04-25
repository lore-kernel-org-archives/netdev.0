From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 0/6] Add Shared MDIO framework for iProc based SoCs
Date: Mon, 25 Apr 2016 17:20:38 +0200
Message-ID: <20160425152038.GJ6575@lunn.ch>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	BCM Kernel Feedback <bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Suzuki K Poulose <suzuki.poulose-5wv7dgnIgG8@public.gmane.org>,
	Punit Agrawal <punit.agrawal-5wv7dgnIgG8@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pramod Kumar <pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1461230323-27891-1-git-send-email-pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 21, 2016 at 02:48:37PM +0530, Pramod Kumar wrote:
> Broadcom iProc based SoCs uses MDIO bus for programming PHYs belonging to
> different I/O subsystem like USB, SATA, PCIe, ETHERNET etc. Every subsystem
> is referred as "Master" When a master is selected, all PHYs belonging to
> this subsystem get active on the MDIO bus and responds to MDIO transaction.
> In this way one MDIO controller is shared among all masters hence named as
> "Shared MDIO controller".
> 
> We have two important entities in "Shared MDIO Bus" framework:
> 1) shared_mdio_master and
> 2) shared_mdio_driver.
> 
> The shared MDIO controller driver is registered as platform driver and it
> creates shared_mdio_master instances and adds them to "Shared MDIO Bus"
> framework.

Hi Pramod

What i'm missing is an explanation why the existing MDIO bus framework
cannot be used. I recently made it more generic so that you can hang
any type of device off it, not just PHYs.

    Thanks
	Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
