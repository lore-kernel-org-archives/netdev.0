From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net neighbour,decnet: Ensure to align device
 private data on preferred alignment.
Date: Mon, 11 Feb 2013 00:23:05 -0500 (EST)
Message-ID: <20130211.002305.116088533226868074.davem@davemloft.net>
References: <511680CB.9010502@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <511680CB.9010502@linux-ipv6.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Sun, 10 Feb 2013 02:00:59 +0900

> To allow both of protocol-specific data and device-specific data
> attached with neighbour entry, and to eliminate size calculation
> cost when allocating entry, sizeof protocol-speicic data must be
> multiple of NEIGH_PRIV_ALIGN.  On 64bit archs,
> sizeof(struct dn_neigh) is multiple of NEIGH_PRIV_ALIGN, but on
> 32bit archs, it was not.
> 
> Introduce NEIGH_ENTRY_SPACE() macro to ensure that protocol-specific
> entry-size meets our requirement.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
