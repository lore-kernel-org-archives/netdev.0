From: Anders Darander <anders.darander@datarespons.se>
Subject: Re: [PATCH] MACB: Set PHY address in kernel parameters
Date: Wed, 31 Mar 2010 10:50:25 +0200
Message-ID: <20100331085024.GG4837@datarespons.se>
References: <1270021902-6556-1-git-send-email-anders.darander@gmail.com>
 <4BB307CA.9080305@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4BB307CA.9080305@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> [100331 10:29]:
> Anders Darander wrote:
> > +	if (phy_addr >= PHY_MAX_ADDRESS)
> > +		phydev = phy_find_first(bp->mii_bus);
> > +	else
> > +		phydev = bp->mii_bus->phy_map[phy_addr];

> This looks like you need to use an unsigned to avoid negative
> indices.

Thanks for spotting this. That made me find that I'd also been inconsistent with the variable and module parameter declarations.

A new version, V2, of the patch has been sent.

Best regards,
Anders Darander
