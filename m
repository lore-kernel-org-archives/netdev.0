From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 3/3] net: stmmac: add gmac autonego set for ethtool
 support
Date: Thu, 10 Jan 2013 15:57:59 -0800 (PST)
Message-ID: <20130110.155759.127269416182567301.davem@davemloft.net>
References: <000601cdedf8$5d39bdf0$17ad39d0$@samsung.com>
	<20130110.000208.2040524620441942742.davem@davemloft.net>
	<003d01cdef8d$d25b2bf0$771183d0$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	peppe.cavallaro@st.com, jeffrey.t.kirsher@intel.com,
	kgene.kim@samsung.com
To: bh74.an@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <003d01cdef8d$d25b2bf0$771183d0$@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Byungho An <bh74.an@samsung.com>
Date: Thu, 10 Jan 2013 15:54:24 -0800

> @@ -348,6 +349,10 @@ stmmac_set_pauseparam(struct net_device *netdev,
>  
>  	if (phy->autoneg) {
>  		if (netif_running(netdev))
> +			if((interface == PHY_INTERFACE_MODE_SGMII) ||
> +			   (interface == PHY_INTERFACE_MODE_TBI) ||
> +			   (interface == PHY_INTERFACE_MODE_RTBI)) 
> +				priv->hw->mac->set_autoneg(priv->ioaddr);

This is still not properly formatted.

You also didn't submit this properly.  Never use email thread replies
to submit new versions of patches.

Always use fresh, new, mailing list postings to submit new versions
of patches.

Also, when one patch has to change in a series, you must reubmit
the entire set of patches even if some of them have no changes
at all.  I do not see patch #2 here at all.
