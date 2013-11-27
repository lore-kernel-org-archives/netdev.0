From: Dmitry Torokhov <dtor@vmware.com>
Subject: Re: [Pv-drivers] [PATCH] net: vmxnet3: remove unnecessary pci_set_drvdata()
Date: Wed, 27 Nov 2013 10:27:03 -0800
Message-ID: <7790085.oo1KN3vePZ@dtor-d630.eng.vmware.com>
References: <001701cee982$cd4cdd30$67e69790$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Jingoo Han <jg1.han@samsung.com>,
	"'David S. Miller'" <davem@davemloft.net>,
	'Aditya Sarwade' <asarwade@vmware.com>, netdev@vger.kernel.org
To: pv-drivers@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:41007 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751648Ab3K0S1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 13:27:05 -0500
In-Reply-To: <001701cee982$cd4cdd30$67e69790$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, November 25, 2013 11:05:23 AM Jingoo Han wrote:
> The driver core clears the driver data to NULL after device_release
> or on probe failure. Thus, it is not needed to manually clear the
> device driver data to NULL.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Acked-by: Dmitry Torokhov <dtor@vmware.com>

> ---
>  drivers/net/vmxnet3/vmxnet3_drv.c |    1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c
> b/drivers/net/vmxnet3/vmxnet3_drv.c index 7e2788c..a300a18 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -3132,7 +3132,6 @@ err_alloc_queue_desc:
>  err_alloc_shared:
>  	dma_unmap_single(&adapter->pdev->dev, adapter->adapter_pa,
>  			 sizeof(struct vmxnet3_adapter), PCI_DMA_TODEVICE);
> -	pci_set_drvdata(pdev, NULL);
>  	free_netdev(netdev);
>  	return err;
>  }
