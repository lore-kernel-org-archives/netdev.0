From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: [PATCH] emac: add bamboo support
Date: Wed, 27 Jul 2005 23:59:44 -0700
Message-ID: <20050728065943.GA16041@gate.ebshome.net>
References: <20050727104247.C1114@cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, wfarnsworth@mvista.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Porter <mporter@kernel.crashing.org>
Content-Disposition: inline
In-Reply-To: <20050727104247.C1114@cox.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 27, 2005 at 10:42:47AM -0700, Matt Porter wrote:
> Adds support for the Bamboo board phys in the EMAC driver.
> Please apply.
> 
> Signed-off-by: Wade Farnsworth <wfarnsworth@mvista.com>
> Signed-off-by: Matt Porter <mporter@kernel.crashing.org>
> 

[snip]

> +#ifdef CONFIG_BAMBOO
> +static int ac104_init(struct mii_phy *phy)
> +{
> +	/*
> +	 * SW2 on the Bamboo is used for ethernet configuration and is accessed
> +	 * via the CONFIG2 register in the FPGA.  If the ANEG pin is set,
> +	 * overwrite the supported features with the settings in SW2.
> +	 */

I wonder, how this SW2 works. Is it just a way to tell software not to 
use autoneg and force some settings, or it disables autoneg on hw 
level (I'm kinda doubt that)?

If this is just some board specific configuration option which doesn't 
affect this PHY directly, let's drop this stuff completely and always 
use autoneg, if user wants to force something - he should ethtool.

-- 
Eugene
