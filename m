From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: stmmac: Use the right logging function in
 stmmac_mdio_register
Date: Fri, 11 Aug 2017 14:39:11 -0700 (PDT)
Message-ID: <20170811.143911.1295975110250079627.davem@davemloft.net>
References: <20170810145605.27048-1-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com, andrew@lunn.ch,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: romain.perier@collabora.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170810145605.27048-1-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Romain Perier <romain.perier@collabora.com>
Date: Thu, 10 Aug 2017 16:56:05 +0200

> Currently, the function stmmac_mdio_register() is only used by
> stmmac_dvr_probe() from stmmac_main.c, in order to register the MDIO bus
> and probe information about the PHY. As this function is called before
> calling register_netdev(), all messages logged from stmmac_mdio_register
> are prefixed by "(unnamed net_device)". The goal of netdev_info or
> netdev_err is to dump useful infos about a net_device, when this data
> structure is partially initialized, there is no point for using these
> functions.
> 
> This commit fixes the issue by replacing all netdev_*() by the
> corresponding dev_*() function for logging. The last netdev_info is
> replaced by phy_attached_info(), as a valid phydev can be used at this
> point.
> 
> Signed-off-by: Romain Perier <romain.perier@collabora.com>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Applied, thanks.
