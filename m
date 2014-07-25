From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/6] net/macb: add HW features to macb driver
Date: Thu, 24 Jul 2014 23:40:26 -0700 (PDT)
Message-ID: <20140724.234026.1408822707562402333.davem@davemloft.net>
References: <cover.1406192657.git.cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, soren.brinkmann@xilinx.com,
	linux-kernel@vger.kernel.org
To: cyrille.pitchen@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1406192657.git.cyrille.pitchen@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Date: Thu, 24 Jul 2014 13:50:57 +0200

> this series of patches adds new hardware features to macb driver. These
> features can be enabled/disabled at runtime using ethtool. Depending on
> hardware and design configuration, some are enabled by default whereas other
> are disabled.
> 
> For instance, checksum offload features are enabled by default for gem designed
> for packet buffer mode but disabled for fifo mode design or for old macb.
> 
> Besides, the scatter-gather feature is enabled and tested on macb but disabled
> on sama5d3x gem. When testing this feature on sama5d3x gem, TX lockups occured
> frequently.
> 
> Also, the RX checksum offload feature is enabled at GEM level only when both
> IFF_PROMISC bit is clear in dev->flags and NETIF_F_RXCSUM bit is set in
> dev->features.
> 
> These patches were made for net-next.git repository.

Series applied, thanks.
