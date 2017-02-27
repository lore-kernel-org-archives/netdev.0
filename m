From: Peter Senna Tschudin <peter.senna@collabora.com>
Subject: Re: [PATCH v3 19/20] PCI: Remove PCI pool macro functions
Date: Mon, 27 Feb 2017 12:20:24 +0100
Message-ID: <20170227112024.GJ26544@collabora.com>
References: <20170226192425.13098-1-romain.perier@collabora.com>
 <20170226192425.13098-20-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Felipe Balbi <balbi@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Romain Perier <romain.perier@collabora.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170226192425.13098-20-romain.perier@collabora.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 26, 2017 at 08:24:24PM +0100, Romain Perier wrote:
> Now that all the drivers use dma pool API, we can remove the macro
> functions for PCI pool.
> 
Reviewed-by: Peter Senna Tschudin <peter.senna@collabora.com>
> Signed-off-by: Romain Perier <romain.perier@collabora.com>
> ---
>  include/linux/pci.h | 9 ---------
>  1 file changed, 9 deletions(-)
> 
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index 282ed32..d206ba4 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -1281,15 +1281,6 @@ int pci_set_vga_state(struct pci_dev *pdev, bool decode,
>  #include <linux/pci-dma.h>
>  #include <linux/dmapool.h>
>  
> -#define	pci_pool dma_pool
> -#define pci_pool_create(name, pdev, size, align, allocation) \
> -		dma_pool_create(name, &pdev->dev, size, align, allocation)
> -#define	pci_pool_destroy(pool) dma_pool_destroy(pool)
> -#define	pci_pool_alloc(pool, flags, handle) dma_pool_alloc(pool, flags, handle)
> -#define	pci_pool_zalloc(pool, flags, handle) \
> -		dma_pool_zalloc(pool, flags, handle)
> -#define	pci_pool_free(pool, vaddr, addr) dma_pool_free(pool, vaddr, addr)
> -
>  struct msix_entry {
>  	u32	vector;	/* kernel uses to write allocated vector */
>  	u16	entry;	/* driver uses to specify entry, OS writes */
> -- 
> 2.9.3
> 
