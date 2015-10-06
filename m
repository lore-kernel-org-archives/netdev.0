From: Don Fry <pcnet32@frontier.com>
Subject: Re: [PATCH 01/15] pcnet32: use pci_set_dma_mask insted of
 pci_dma_supported
Date: Mon, 05 Oct 2015 20:57:54 -0700
Message-ID: <1444103874.5667.7.camel@Lunix2.home>
References: <1443885579-7094-1-git-send-email-hch@lst.de>
	 <1443885579-7094-2-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Oliver Neukum <oneukum@suse.com>,
	linux-net-drivers@solarflare.com, dri-devel@lists.freedesktop.org,
	linux-media@vger.kernel.org, netdev@vger.kernel.org,
	linux-parisc@vger.kernel.org, linux-serial@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <1443885579-7094-2-git-send-email-hch@lst.de>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-10-03 at 17:19 +0200, Christoph Hellwig wrote:
> This ensures the dma mask that is supported by the driver is recorded
> in the device structure.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/net/ethernet/amd/pcnet32.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 

Acked-by: Don Fry <pcnet32@frontier.com>

> diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
> index bc8b04f..e2afabf 100644
> --- a/drivers/net/ethernet/amd/pcnet32.c
> +++ b/drivers/net/ethernet/amd/pcnet32.c
> @@ -1500,7 +1500,7 @@ pcnet32_probe_pci(struct pci_dev *pdev, const struct pci_device_id *ent)
>  		return -ENODEV;
>  	}
>  
> -	if (!pci_dma_supported(pdev, PCNET32_DMA_MASK)) {
> +	if (!pci_set_dma_mask(pdev, PCNET32_DMA_MASK)) {
>  		if (pcnet32_debug & NETIF_MSG_PROBE)
>  			pr_err("architecture does not support 32bit PCI busmaster DMA\n");
>  		return -ENODEV;
