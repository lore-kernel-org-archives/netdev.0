From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH 05/11] drivers/net/irda: Remove unnecessary casts of
 pci_get_drvdata
Date: Tue, 16 Nov 2010 12:27:55 +0100
Message-ID: <1289906875.7016.1.camel@sortiz-mobl>
References: <cover.1289851770.git.joe@perches.com>
	 <11b30b9512bf0438efaf70d6c0a819756dbf0e2f.1289851770.git.joe@perches.com>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Kosina <trivial@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <11b30b9512bf0438efaf70d6c0a819756dbf0e2f.1289851770.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

On Mon, 2010-11-15 at 12:13 -0800, Joe Perches wrote:
> Signed-off-by: Joe Perches <joe@perches.com>
Thanks, I'll apply it to my irda tree.

Cheers,
Samuel.


> ---
>  drivers/net/irda/donauboe.c |    6 +++---
>  drivers/net/irda/vlsi_ir.c  |    2 +-
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
> index b626ccc..bee5ccc 100644
> --- a/drivers/net/irda/donauboe.c
> +++ b/drivers/net/irda/donauboe.c
> @@ -1488,7 +1488,7 @@ static void
>  toshoboe_close (struct pci_dev *pci_dev)
>  {
>    int i;
> -  struct toshoboe_cb *self = (struct toshoboe_cb*)pci_get_drvdata(pci_dev);
> +  struct toshoboe_cb *self = pci_get_drvdata(pci_dev);
>  
>    IRDA_DEBUG (4, "%s()\n", __func__);
>  
> @@ -1698,7 +1698,7 @@ freeself:
>  static int
>  toshoboe_gotosleep (struct pci_dev *pci_dev, pm_message_t crap)
>  {
> -  struct toshoboe_cb *self = (struct toshoboe_cb*)pci_get_drvdata(pci_dev);
> +  struct toshoboe_cb *self = pci_get_drvdata(pci_dev);
>    unsigned long flags;
>    int i = 10;
>  
> @@ -1727,7 +1727,7 @@ toshoboe_gotosleep (struct pci_dev *pci_dev, pm_message_t crap)
>  static int
>  toshoboe_wakeup (struct pci_dev *pci_dev)
>  {
> -  struct toshoboe_cb *self = (struct toshoboe_cb*)pci_get_drvdata(pci_dev);
> +  struct toshoboe_cb *self = pci_get_drvdata(pci_dev);
>    unsigned long flags;
>  
>    IRDA_DEBUG (4, "%s()\n", __func__);
> diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
> index c3d0738..62f2d12 100644
> --- a/drivers/net/irda/vlsi_ir.c
> +++ b/drivers/net/irda/vlsi_ir.c
> @@ -542,7 +542,7 @@ static int vlsi_process_rx(struct vlsi_ring *r, struct ring_descr *rd)
>  	int		crclen, len = 0;
>  	struct sk_buff	*skb;
>  	int		ret = 0;
> -	struct net_device *ndev = (struct net_device *)pci_get_drvdata(r->pdev);
> +	struct net_device *ndev = pci_get_drvdata(r->pdev);
>  	vlsi_irda_dev_t *idev = netdev_priv(ndev);
>  
>  	pci_dma_sync_single_for_cpu(r->pdev, rd_get_addr(rd), r->len, r->dir);
