From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] net/phy: Improvements to Cavium Thunder MDIO
 code.
Date: Mon, 14 Mar 2016 15:27:51 -0400 (EDT)
Message-ID: <20160314.152751.2108458769066613871.davem@davemloft.net>
References: <1457718791-6505-1-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	f.fainelli@gmail.com, rric@kernel.org, sgoutham@cavium.com,
	galak@codeaurora.org, ijc+devicetree@hellion.org.uk,
	mark.rutland@arm.com, pawel.moll@arm.com, robh+dt@kernel.org,
	linux-kernel@vger.kernel.org, rchintakuntla@cavium.com,
	david.daney@cavium.com
To: ddaney.cavm@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457718791-6505-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney.cavm@gmail.com>
Date: Fri, 11 Mar 2016 09:53:08 -0800

> Changes from v1:
> 
>  - In 1/3 Add back check for non-OF objects in bgx_init_of_phy().  It
>    is probably not necessary, but better safe than sorry...
> 
> The firmware on many Cavium Thunder systems configures the MDIO bus
> hardware to be probed as a PCI device.  In order to use the MDIO bus
> drivers in this configuration, we must add PCI probing to the driver.
> 
> There are two parts to this set of three patches:
> 
>  1) Cleanup the PHY probing code in thunder_bgx.c to handle the case
>     where there is no PHY attached to a port, as well as being more
>     robust in the face of driver loading order by use of
>     -EPROBE_DEFER.
> 
>  2) Split mdio-octeon.c into two drivers, one with platform probing,
>  and the other with PCI probing.  Common code is shared between the
>  two.
> 
> Tested on several different Thunder and OCTEON systems, also compile
> tested on x86_64.

Series applied, thanks David.
