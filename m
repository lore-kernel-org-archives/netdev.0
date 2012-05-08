From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 2/3] netdev/of/phy: Add MDIO bus multiplexer support.
Date: Mon, 07 May 2012 22:58:53 -0400 (EDT)
Message-ID: <20120507.225853.1863347275703801019.davem@davemloft.net>
References: <1336007799-31016-1-git-send-email-ddaney.cavm@gmail.com>
        <1336007799-31016-3-git-send-email-ddaney.cavm@gmail.com>
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
In-Reply-To: <1336007799-31016-3-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney.cavm@gmail.com>
Date: Wed,  2 May 2012 18:16:38 -0700

> From: David Daney <david.daney@cavium.com>
> 
> This patch adds a somewhat generic framework for MDIO bus
> multiplexers.  It is modeled on the I2C multiplexer.
> 
> The multiplexer is needed if there are multiple PHYs with the same
> address connected to the same MDIO bus adepter, or if there is
> insufficient electrical drive capability for all the connected PHY
> devices.
> 
> Conceptually it could look something like this:
 ...
> This framework configures the bus topology from device tree data.  The
> mechanics of switching the multiplexer is left to device specific
> drivers.
> 
> The follow-on patch contains a multiplexer driven by GPIO lines.
> 
> Signed-off-by: David Daney <david.daney@cavium.com>

Applied.
