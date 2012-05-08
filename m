From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 1/3] netdev/of/phy: New function: of_mdio_find_bus().
Date: Mon, 07 May 2012 22:58:42 -0400 (EDT)
Message-ID: <20120507.225842.692131427998127266.davem@davemloft.net>
References: <1336007799-31016-1-git-send-email-ddaney.cavm@gmail.com>
        <1336007799-31016-2-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, grant.likely@secretlab.ca,
        rob.herring@calxeda.com, devicetree-discuss@lists.ozlabs.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mips@linux-mips.org, afleming@gmail.com,
        galak@kernel.crashing.org, david.daney@cavium.com
To: ddaney.cavm@gmail.com
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1336007799-31016-2-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney.cavm@gmail.com>
Date: Wed,  2 May 2012 18:16:37 -0700

> From: David Daney <david.daney@cavium.com>
> 
> Add of_mdio_find_bus() which allows an mii_bus to be located given its
> associated the device tree node.
> 
> This is needed by the follow-on patch to add a driver for MDIO bus
> multiplexers.
> 
> The of_mdiobus_register() function is modified so that the device tree
> node is recorded in the mii_bus.  Then we can find it again by
> iterating over all mdio_bus_class devices.
> 
> Because the OF device tree has now become an integral part of the
> kernel, this can live in mdio_bus.c (which contains the needed
> mdio_bus_class structure) instead of of_mdio.c.
> 
> Signed-off-by: David Daney <david.daney@cavium.com>

Applied.
