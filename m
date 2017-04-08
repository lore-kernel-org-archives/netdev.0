From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: davinci_mdio: add GPIO reset logic
Date: Sat, 08 Apr 2017 06:55:45 -0700 (PDT)
Message-ID: <20170408.065545.2057882592764132853.davem@davemloft.net>
References: <1491381237-24635-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tony@atomide.com, nsekhar@ti.com, jsarha@ti.com,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: rogerq@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1491381237-24635-1-git-send-email-rogerq@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roger Quadros <rogerq@ti.com>
Date: Wed, 5 Apr 2017 11:33:57 +0300

> Some boards [1] leave the PHYs at an invalid state
> during system power-up or reset thus causing unreliability
> issues with the PHY like not being detected by the mdio bus
> or link not functional. To work around these boards have
> a GPIO connected to the PHY's reset pin.
> 
> Implement GPIO reset handling for such cases.
> 
> [1] - am572x-idk, am571x-idk, a437x-idk.
> 
> Signed-off-by: Roger Quadros <rogerq@ti.com>
> Signed-off-by: Sekhar Nori <nsekhar@ti.com>

I have not seen a resolution in this discussion.

My understanding is that there are several cases (single MDIO bus whose
reset does a reset on all that MDIO bus's PHYs, etc.) and it's unclear
how to handle all such cases cleanly.
