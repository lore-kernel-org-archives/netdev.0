From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] mlx4: allow device removal by fixing dma unmap size
Date: Mon, 06 Feb 2012 14:42:49 -0500 (EST)
Message-ID: <20120206.144249.2096673389778792309.davem@davemloft.net>
References: <1328553590-27677-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.co.il, ogerlitz@mellanox.com,
	eugenia@mellanox.co.il, alexg@mellanox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: cascardo@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328553590-27677-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Mon,  6 Feb 2012 16:39:49 -0200

> After opening the network interface, Mellanox ConnectX device cannot be
> removed by hotplug because it has not properly unmapped all DMA memory.
> 
> It happens that mlx4_en_activate_rx_rings overrides the variable that
> keeps the size of the memory mapped.
> 
> This is fixed by passing to mlx4_en_destroy_rx_ring the same size that is
> given to mlx4_en_create_rx_ring.
> 
> After applying this patch, hot unplugging the device works after opening
> the interface.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>

Applied.
