From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: Simplify dsa_slave_phy_setup()
Date: Thu, 26 Oct 2017 09:19:17 +0200
Message-ID: <20171026071917.GB20299@lunn.ch>
References: <20171026003205.13673-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com, mnhu@prevas.dk
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:58304 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751747AbdJZHTV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 03:19:21 -0400
Content-Disposition: inline
In-Reply-To: <20171026003205.13673-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 25, 2017 at 05:32:05PM -0700, Florian Fainelli wrote:
> Remove the code that tried to identify if a PHY designated by Device
> Tree required diversion through the DSA-created MDIO bus. This was
> created mainly for the bcm_sf2.c driver back when it did not have its
> own MDIO bus driver, which it now has since 461cd1b03e32 ("net: dsa:
> bcm_sf2: Register our slave MDIO bus").
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks for the cleanup.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
