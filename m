From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 net-next] mdio_bus: Issue GPIO RESET to PHYs.
Date: Fri, 21 Apr 2017 03:12:54 +0200
Message-ID: <20170421011254.GA705@lunn.ch>
References: <1491381237-24635-1-git-send-email-rogerq@ti.com>
 <64d6494d-41d2-0faf-a434-057f796637fe@ti.com>
 <daa29a99-0a17-d316-57eb-3e6162938d8d@ti.com>
 <f372db02-a919-55b4-9200-20726cd13482@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
        tony@atomide.com, nsekhar@ti.com, jsarha@ti.com,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37022 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S948374AbdDUBNE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 21:13:04 -0400
Content-Disposition: inline
In-Reply-To: <f372db02-a919-55b4-9200-20726cd13482@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 05:11:53PM +0300, Roger Quadros wrote:
> Some boards [1] leave the PHYs at an invalid state
> during system power-up or reset thus causing unreliability
> issues with the PHY which manifests as PHY not being detected
> or link not functional. To fix this, these PHYs need to be RESET
> via a GPIO connected to the PHY's RESET pin.
> 
> Some boards have a single GPIO controlling the PHY RESET pin of all
> PHYs on the bus whereas some others have separate GPIOs controlling
> individual PHY RESETs.
> 
> In both cases, the RESET de-assertion cannot be done in the PHY driver
> as the PHY will not probe till its reset is de-asserted.
> So do the RESET de-assertion in the MDIO bus driver.
> 
> [1] - am572x-idk, am571x-idk, a437x-idk
> 
> Signed-off-by: Roger Quadros <rogerq@ti.com>

Hi Roger

Thanks for doing a generic solutions and the MDIO DT documentation.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
