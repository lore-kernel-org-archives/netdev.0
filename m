From: Don Fry <pcnet32@frontier.com>
Subject: Re: [PATCH] pcnet32: fix a logic error with pci_set_dma_mask
Date: Wed, 21 Oct 2015 21:01:26 -0700
Message-ID: <1445486486.5667.33.camel@Lunix2.home>
References: <c2a42526779ca29258fa84bff51f8d94ed9fcc28.1444415947.git.geliangtang@163.com>
	 <20151012.053814.1870650163021801761.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: geliangtang@163.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151012.053814.1870650163021801761.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-10-12 at 05:38 -0700, David Miller wrote:
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
I failed.  My system with pcnet32 boards was down with a dead power
supply and a visual review was not good enough.  I missed that
pci_dma_supported returns 1 on success and pci_set_dma_mask returns 0 on
success.  The original patch needs to have the ! removed as Geliang Tang
points out.

Acked-by:  Don Fry <pcnet32@frontier.com>
