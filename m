From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next] r8169:add support for RTL8168EP
Date: Wed, 08 Oct 2014 15:59:24 -0400 (EDT)
Message-ID: <20141008.155924.55313801969969450.davem@davemloft.net>
References: <1412665841-7338-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: hau@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412665841-7338-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chun-Hao Lin <hau@realtek.com>
Date: Tue, 7 Oct 2014 15:10:41 +0800

> RTL8168EP is Realtek PCIe Gigabit Ethernet controller with DASH support.
> It is a successor chip of RTL8168DP.
> 
> For RTL8168EP, the read/write ocp register is via eri channel type 2, so I
> move ocp_xxx() related functions under rtl_eri_xxx. And use r8168dp_ocp_xxx()
> for RTL8168DP ocp read/write, r8168ep_ocp_xxx() for RTL8168EP ocp read/write.
> 
> The way of checking dash enable is different with RTL8168DP. I use
> r8168dp_check_dash()for RTL8168DP and r8168ep_check_dash() for RTL8168EP,
> to check if dash is enabled.
> 
> The driver_start() and driver_stop() of RTL8168EP is also different with
> RTL8168DP. I use rtl8168dp_driver_xxx() for RTL8168DP and
> rtl8168ep_driver_xxx for RTL8168EP.
> 
> Right now, RTL8168EP phy mcu did not need firmware code patch, so I did not
> add firmware code for it.
> so I did not add firmware code for it.
> 
> Signed-off-by: Chun-Hao Lin <hau@realtek.com>

I'll apply this, but if Francois has more feedback please work on it
with follow-on changes.

Thank you.
