From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/2] drivers: phy: Add Cortina CS4340 driver
Date: Tue, 23 May 2017 17:57:19 +0200
Message-ID: <20170523155719.GA21169@lunn.ch>
References: <1495554799-23060-1-git-send-email-bogdan.purcareata@nxp.com>
 <1495554799-23060-3-git-send-email-bogdan.purcareata@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Bogdan Purcareata <bogdan.purcareata@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1495554799-23060-3-git-send-email-bogdan.purcareata@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 23, 2017 at 03:53:19PM +0000, Bogdan Purcareata wrote:
> Add basic support for Cortina PHY drivers. Support only CS4340 for now.
> The phys are not fully compatible with IEEE 802.3 clause 45 registers.
> Implement proper read_status support, so that phy polling does not cause
> bus register access errors.
> 
> Signed-off-by: Bogdan Purcareata <bogdan.purcareata@nxp.com>
> ---
>  drivers/net/phy/Kconfig        |  5 +++
>  drivers/net/phy/Makefile       |  1 +
>  drivers/net/phy/mdio-cortina.c | 90 ++++++++++++++++++++++++++++++++++++++++++

This is a phy driver, not a mdio bus driver. Please use the correct
file name.

     Andrew
