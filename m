From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 3/3] net: stmmac: add gmac autonego set for ethtool
 support
Date: Thu, 10 Jan 2013 00:02:08 -0800 (PST)
Message-ID: <20130110.000208.2040524620441942742.davem@davemloft.net>
References: <000601cdedf8$5d39bdf0$17ad39d0$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	peppe.cavallaro@st.com, jeffrey.t.kirsher@intel.com,
	kgene.kim@samsung.com
To: bh74.an@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <000601cdedf8$5d39bdf0$17ad39d0$@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Byungho An <bh74.an@samsung.com>
Date: Tue, 08 Jan 2013 15:32:02 -0800

> @@ -348,6 +349,10 @@ stmmac_set_pauseparam(struct net_device *netdev,
>  
>  	if (phy->autoneg) {
>  		if (netif_running(netdev))
> +			if((interface == PHY_INTERFACE_MODE_SGMII) ||
> +				(interface == PHY_INTERFACE_MODE_TBI) ||
> +				(interface == PHY_INTERFACE_MODE_RTBI)) 
> +				priv->hw->mac->set_autoneg(priv->ioaddr);

This is improperly indented and formatted, use this style:

	if (A ||
	    B ||
	    C)
		statement();

I can tell what you're trying to do, you are just trying to use TAB
characters exclusivly to indent because you are lazy.  But that's not
the objective here.
