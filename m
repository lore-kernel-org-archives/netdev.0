From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] mlx4: fix DMA mapping leak when allocation fails
Date: Mon, 06 Feb 2012 14:42:56 -0500 (EST)
Message-ID: <20120206.144256.1171908949073473140.davem@davemloft.net>
References: <1328553590-27677-1-git-send-email-cascardo@linux.vnet.ibm.com>
	<1328553590-27677-2-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.co.il, ogerlitz@mellanox.com,
	eugenia@mellanox.co.il, alexg@mellanox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: cascardo@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328553590-27677-2-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Mon,  6 Feb 2012 16:39:50 -0200

> mlx4_en_prepare_rx_desc does not correctly clean up after it finds an
> allocation failure. It should unmap a page before calling put_page, but
> it only calls the later.
> 
> This bug would prevent a device removal using hotplug after setting the
> device MTU to 9000 and opening the network interface. After the fix, we
> still see the allocation failure with MTU 9000, but we are able to
> remove the device.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>

Applied.
