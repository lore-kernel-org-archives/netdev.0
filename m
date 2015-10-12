From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pcnet32: fix a logic error with pci_set_dma_mask
Date: Mon, 12 Oct 2015 05:38:14 -0700 (PDT)
Message-ID: <20151012.053814.1870650163021801761.davem@davemloft.net>
References: <c2a42526779ca29258fa84bff51f8d94ed9fcc28.1444415947.git.geliangtang@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pcnet32@frontier.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geliangtang@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c2a42526779ca29258fa84bff51f8d94ed9fcc28.1444415947.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geliang Tang <geliangtang@163.com>
Date: Fri,  9 Oct 2015 03:45:39 -0700

> pcnet32 can't work on my machine recently. It says "architecture
> does not support 32bit PCI busmaster DMA". There is a logic error
> in it: pci_set_dma_mask() return 0 means return successfully.
> 
> Signed-off-by: Geliang Tang <geliangtang@163.com>

This driver doesn't call pci_set_dma_mask() in any of my tree(s).
