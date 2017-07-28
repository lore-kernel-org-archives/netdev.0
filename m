From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/4] net: dsa: lan9303: Renamed indirect phy
 access functions
Date: Fri, 28 Jul 2017 17:22:01 +0200
Message-ID: <20170728152201.GG2132@lunn.ch>
References: <20170728151157.28983-1-privat@egil-hjelmeland.no>
 <20170728151157.28983-4-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@pengutronix.de
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170728151157.28983-4-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2017 at 05:11:56PM +0200, Egil Hjelmeland wrote:
> Preparing for the following fix of MDIO phy access:
> 
> Renamed functions that access PHY 1 and 2 indirectly through PMI
> registers.
> 
>  lan9303_port_phy_reg_wait_for_completion() to
>  lan9303_indirect_phy_wait_for_completion()
> 
>  lan9303_port_phy_reg_read() to
>  lan9303_indirect_phy_read()
> 
>  lan9303_port_phy_reg_write() to
>  lan9303_indirect_phy_write()
> 
> Also changed "val" parameter of lan9303_indirect_phy_write() to u16,
> for clarity.
> 
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
