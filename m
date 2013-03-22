From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4 v3] mv643xx_eth: use mvmdio MDIO bus driver
Date: Fri, 22 Mar 2013 10:26:26 -0400 (EDT)
Message-ID: <20130322.102626.1889236227505288422.davem@davemloft.net>
References: <1363284515-9865-1-git-send-email-florian@openwrt.org>
	<1363959568-16976-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@secretlab.ca, rob.herring@calxeda.com,
	rob@landley.net, jason@lakedaemon.net, andrew@lunn.ch,
	linux@arm.linux.org.uk, benh@kernel.crashing.org, paulus@samba.org,
	buytenh@wantstofly.org, thomas.petazzoni@free-electrons.com,
	gregkh@linuxfoundation.org, devicetree-discuss@lists.ozlabs.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363959568-16976-1-git-send-email-florian@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <florian@openwrt.org>
Date: Fri, 22 Mar 2013 14:39:24 +0100

> This patch converts the mv643xx_eth driver to use the mvmdio MDIO bus driver
> instead of rolling its own implementation. As a result, all users of this
> mv643xx_eth driver are converted to register an "orion-mdio" platform_device.
> The mvmdio driver is also updated to support an interrupt line which reports
> SMI error/completion, and to allow traditionnal platform device registration
> instead of just device tree.
> 
> David, I think it makes sense for you to merge all of this, since we do
> not want the architecture files to be desynchronized from the mv643xx_eth to
> avoid runtime breakage. The potential for merge conflicts should be very small.

Series applied to net-next, thanks Florian.
