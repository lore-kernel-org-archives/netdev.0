From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8152: support VLAN
Date: Thu, 11 Sep 2014 09:29:58 -0400 (EDT)
Message-ID: <20140911.092958.40613877139856519.davem@davemloft.net>
References: <1394712342-15778-36-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-36-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 11 Sep 2014 20:16:24 +0800

> -	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CPCR);
> -	ocp_data &= ~CPCR_RX_VLAN;
> -	ocp_write_word(tp, MCU_TYPE_PLA, PLA_CPCR, ocp_data);
> +	if (tp->netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
> +		rtl_rx_vlan_en(tp, true);
> +	else
> +		rtl_rx_vlan_en(tp, false);

	rtl_rx_vlan_en(tp, tp->netdev->features & NETIF_F_HW_VLAN_CTAG_RX);
