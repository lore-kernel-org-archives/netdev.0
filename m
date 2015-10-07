From: Abylay Ospan <aospan@netup.ru>
Subject: Re: [PATCH 08/15] netup_unidvb: use pci_set_dma_mask insted of pci_dma_supported
Date: Wed, 7 Oct 2015 11:03:13 +0300
Message-ID: <CAK3bHNXJp70C3DC8OPsKHmiTeLu-J70VKSfKwDgUd5F=uorEWw@mail.gmail.com>
References: <1443885579-7094-1-git-send-email-hch@lst.de> <1443885579-7094-9-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Don Fry <pcnet32@frontier.com>,
	Oliver Neukum <oneukum@suse.com>,
	linux-net-drivers@solarflare.com, dri-devel@lists.freedesktop.org,
	linux-media <linux-media@vger.kernel.org>,
	netdev@vger.kernel.org, linux-parisc@vger.kernel.org,
	linux-serial@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443885579-7094-9-git-send-email-hch@lst.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Acked-by: Abylay Ospan <aospan@netup.ru>

thanks !

2015-10-03 18:19 GMT+03:00 Christoph Hellwig <hch@lst.de>:
> This ensures the dma mask that is supported by the driver is recorded
> in the device structure.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/media/pci/netup_unidvb/netup_unidvb_core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/media/pci/netup_unidvb/netup_unidvb_core.c b/drivers/media/pci/netup_unidvb/netup_unidvb_core.c
> index 6d8bf627..511144f 100644
> --- a/drivers/media/pci/netup_unidvb/netup_unidvb_core.c
> +++ b/drivers/media/pci/netup_unidvb/netup_unidvb_core.c
> @@ -809,7 +809,7 @@ static int netup_unidvb_initdev(struct pci_dev *pci_dev,
>                 "%s(): board vendor 0x%x, revision 0x%x\n",
>                 __func__, board_vendor, board_revision);
>         pci_set_master(pci_dev);
> -       if (!pci_dma_supported(pci_dev, 0xffffffff)) {
> +       if (!pci_set_dma_mask(pci_dev, 0xffffffff)) {
>                 dev_err(&pci_dev->dev,
>                         "%s(): 32bit PCI DMA is not supported\n", __func__);
>                 goto pci_detect_err;
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-media" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Abylay Ospan,
NetUP Inc.
http://www.netup.tv
