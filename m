From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] Adjust the settings about
 USB_RX_EARLY_AGG
Date: Thu, 19 Feb 2015 15:09:09 -0500 (EST)
Message-ID: <20150219.150909.1111353454350810861.davem@davemloft.net>
References: <1394712342-15778-137-Taiwan-albertk@realtek.com>
	<1394712342-15778-141-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-141-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 12 Feb 2015 14:33:45 +0800

> v2:
> For patch #1, replace
> 
> 	u32 ocp_data;
> 	ocp_data = tp->coalesce / 8;
> 
> with
> 
> 	u32 ocp_data = tp->coalesce / 8;
> 
> And replace
> 
> 	struct net_device *dev = tp->netdev;
> 	u32 ocp_data;
> 	ocp_data = (agg_buf_sz - dev->mtu - VLAN_ETH_HLEN - VLAN_HLEN) / 4;
> 
> with
> 
> 	u32 mtu = tp->netdev->mtu;
> 	u32 ocp_data = (agg_buf_sz - mtu - VLAN_ETH_HLEN - VLAN_HLEN) / 4;
> 
> Use *switch* statement to replace the checking of *if*.
> 
> v1:
> The USB_RX_EARLY_AGG contains timeout and size. Separate them, and
> they could be set independently. Then, the ethtool could be used to
> change the timeout according to situation of the platform.

Series applied, thanks.
