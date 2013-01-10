From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Fix phy_init for Marvell network eth driver
Date: Thu, 10 Jan 2013 13:24:41 +0100
Message-ID: <20130110122441.GQ3392@lunn.ch>
References: <1357819234-27752-1-git-send-email-konszert@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, zertsekel@gmail.com, andrew@lunn.ch,
	benavi@marvell.com, linux-arm-kernel@lists.infradead.org,
	alior@marvell.com
To: Kosta Zertsekel <konszert@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from londo.lunn.ch ([80.238.139.98]:42404 "EHLO londo.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752281Ab3AJMYs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 07:24:48 -0500
Content-Disposition: inline
In-Reply-To: <1357819234-27752-1-git-send-email-konszert@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 10, 2013 at 02:00:32PM +0200, Kosta Zertsekel wrote:
> Hi all,
> resubmitting the patch for Marvell mv643xx driver (patch 1/2) adding the below explanation (thanks to Florian F.):
> The D-Link DNS323_REV_C1 board has a specific PHY device fixup using the flag MARVELL_PHY_M1118_DNS323_LEDS which is set by the architecture code in arch/arm/mach-orion5x/dns323-setup.c. This flag is unfortunately lost during the call to phy_attach() in mv643xx_eth and therefore, the underlying Marvell PHY driver cannot make use of this flag to fixup the PHY device LEDs. This patch ensures the phy->dev_flags value is passed to the phy_attach() function such that the PHY device driver can
> actually use it.
> 
> Also submitting new patch 2/2 using the same (or at least very close in meaning) explanation.
> 

Hi Kosta

This comment is supposed to be in the header of the patch. 

Since this comment is about a bug for the D-Link DNS323_REV_C1, the
fix to DSA should be in a separate patch, again with a comment about
the patch, why its needed, what if fixes etc.

I suggest you take a look at Documentation/SubmittingPatches

Thanks
	Andrew
