From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: fix r8152_csum_workaround function
Date: Fri, 11 Jul 2014 14:52:33 -0700 (PDT)
Message-ID: <20140711.145233.467436750120498278.davem@davemloft.net>
References: <1394712342-15778-14-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-14-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Fri, 11 Jul 2014 16:48:27 +0800

> The transport offset of the IPv4 packet should be fixed and wouldn't
> be out of the hw limitation, so the r8152_csum_workaround() should
> be used for IPv6 packets.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied and queued up for -stable, but this patch was harder to review
than it needed to be...

> -		features &= ~(NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO);
> +		features &= ~(NETIF_F_SG | NETIF_F_IPV6_CSUM | NETIF_F_TSO6);

because you changed the order of the flags unnecessarily.
