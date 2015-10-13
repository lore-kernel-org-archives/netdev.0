From: Geliang Tang <geliangtang@163.com>
Subject: Re: [PATCH] pcnet32: fix a logic error with pci_set_dma_mask
Date: Tue, 13 Oct 2015 00:53:10 -0700
Message-ID: <20151013075310.GA3705@ubuntu>
References: <c2a42526779ca29258fa84bff51f8d94ed9fcc28.1444415947.git.geliangtang@163.com>
 <20151012.053814.1870650163021801761.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geliang Tang <geliangtang@163.com>
To: David Miller <davem@davemloft.net>, Don Fry <pcnet32@frontier.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151012.053814.1870650163021801761.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 12, 2015 at 05:38:14AM -0700, David Miller wrote:
> From: Geliang Tang <geliangtang@163.com>
> Date: Fri,  9 Oct 2015 03:45:39 -0700
> 
> > pcnet32 can't work on my machine recently. It says "architecture
> > does not support 32bit PCI busmaster DMA". There is a logic error
> > in it: pci_set_dma_mask() return 0 means return successfully.
> > 
> > Signed-off-by: Geliang Tang <geliangtang@163.com>
> 
> This driver doesn't call pci_set_dma_mask() in any of my tree(s).

This patch is against linux-next tree. It was introduced by commit
9c034d4 'pcnet32: use pci_set_dma_mask insted of pci_dma_supported'.
