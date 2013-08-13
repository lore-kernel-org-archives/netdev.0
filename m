From: Julia Lawall <julia.lawall@lip6.fr>
Subject: question about drivers/net/ethernet/nxp/lpc_eth.c
Date: Tue, 13 Aug 2013 17:01:28 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1308131658460.2263@hadrien>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: grant.likely@linaro.org, rob.herring@calxeda.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I wonder why drivers/net/ethernet/nxp/lpc_eth.c uses dev_alloc_skb in the
function __lpc_handle_recv, rather than netdev_alloc_skb?  The difference
seems to be only that with dev_alloc_skb, the dev field of the skb is
initialized to NULL, rather than to a net_device, but this function seems
to have a net_device value available, so I wonder why it is not used?

thanks,
julia
