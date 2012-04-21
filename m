From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 2/3] netdev/of/phy: Add MDIO bus multiplexer support.
Date: Sat, 21 Apr 2012 15:32:01 -0400 (EDT)
Message-ID: <20120421.153201.2103447307695063734.davem@davemloft.net>
References: <1334791254-15987-1-git-send-email-ddaney.cavm@gmail.com>
        <1334791254-15987-3-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@secretlab.ca, rob.herring@calxeda.com,
        devicetree-discuss@lists.ozlabs.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        afleming@gmail.com, galak@kernel.crashing.org,
        david.daney@cavium.com
To: ddaney.cavm@gmail.com
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1334791254-15987-3-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney.cavm@gmail.com>
Date: Wed, 18 Apr 2012 16:20:53 -0700

> +config MDIO_BUS_MUX
> +	tristate
> +	help
> +	  This module provides a driver framework for MDIO bus
> +	  multiplexers which connect one of several child MDIO busses
> +	  to a parent bus.  Switching between child busses is done by
> +	  device specific drivers.
> +

This driver uses OF and OF_MDIO, and therefore need dependencies upon
them.  Otherwise it can be enabled in configurations which will result
in build failures.
