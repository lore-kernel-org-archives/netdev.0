From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: Re: [PATCH v4 01/16] vmxnet3: Move PCI Id to pci_ids.h
Date: Wed, 14 Sep 2016 14:08:55 +0300
Message-ID: <20160914110854.GA15800@yuval-lap.uk.oracle.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <1473655766-31628-2-git-send-email-aditr@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        pv-drivers@vmware.com, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, jhansen@vmware.com, asarwade@vmware.com,
        georgezhang@vmware.com, bryantan@vmware.com
To: Adit Ranadive <aditr@vmware.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1473655766-31628-2-git-send-email-aditr@vmware.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please update vmxnet3_drv.c accordingly.

Yuval

On Sun, Sep 11, 2016 at 09:49:11PM -0700, Adit Ranadive wrote:
> The VMXNet3 PCI Id will be shared with our paravirtual RDMA driver.
> Moved it to the shared location in pci_ids.h.
> 
> Suggested-by: Leon Romanovsky <leon@kernel.org>
> Signed-off-by: Adit Ranadive <aditr@vmware.com>
> ---
> ---
>  drivers/net/vmxnet3/vmxnet3_int.h | 3 +--
>  include/linux/pci_ids.h           | 1 +
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
> index 74fc030..2bd6bf8 100644
> --- a/drivers/net/vmxnet3/vmxnet3_int.h
> +++ b/drivers/net/vmxnet3/vmxnet3_int.h
> @@ -119,9 +119,8 @@ enum {
>  };
>  
>  /*
> - * PCI vendor and device IDs.
> + * Maximum devices supported.
>   */
> -#define PCI_DEVICE_ID_VMWARE_VMXNET3    0x07B0
>  #define MAX_ETHERNET_CARDS		10
>  #define MAX_PCI_PASSTHRU_DEVICE		6
>  
> diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
> index c58752f..98bb455 100644
> --- a/include/linux/pci_ids.h
> +++ b/include/linux/pci_ids.h
> @@ -2251,6 +2251,7 @@
>  #define PCI_DEVICE_ID_RASTEL_2PORT	0x2000
>  
>  #define PCI_VENDOR_ID_VMWARE		0x15ad
> +#define PCI_DEVICE_ID_VMWARE_VMXNET3	0x07b0
>  
>  #define PCI_VENDOR_ID_ZOLTRIX		0x15b0
>  #define PCI_DEVICE_ID_ZOLTRIX_2BD0	0x2bd0
> -- 
> 2.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
