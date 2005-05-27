From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 2.6.12-rc5] tg3: add bcm5752 entry to pci.ids
Date: Fri, 27 May 2005 19:53:35 +0100
Message-ID: <20050527185334.GA7417@infradead.org>
References: <04132005193844.8410@laptop> <04132005193844.8474@laptop> <20050421165956.55bdcb14.davem@davemloft.net> <20050527184750.GB11592@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, jgarzik@pobox.com, mchan@broadcom.com
Content-Disposition: inline
In-Reply-To: <20050527184750.GB11592@tuxdriver.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, May 27, 2005 at 02:47:52PM -0400, John W. Linville wrote:
> Update pci.ids for BCM5752
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
> 
>  drivers/pci/pci.ids |    1 +
>  1 files changed, 1 insertion(+)
> 
> --- tg3-pci/drivers/pci/pci.ids.orig	2005-05-27 14:41:25.243607911 -0400
> +++ tg3-pci/drivers/pci/pci.ids	2005-05-27 14:43:45.553326412 -0400
> @@ -7173,6 +7173,7 @@
>  	080f  Sentry5 DDR/SDR RAM Controller
>  	0811  Sentry5 External Interface Core
>  	0816  BCM3302 Sentry5 MIPS32 CPU
> +	1600  NetXtreme BCM5752 Gigabit Ethernet PCI Express

I don't think you should mention "PCI Express" here.  That can trivially
befound it looking at the configuration header.
