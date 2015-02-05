From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen-netback: fix sparse warning
Date: Thu, 5 Feb 2015 14:01:12 +0000
Message-ID: <20150205140112.GC4311@zion.uk.xensource.com>
References: <1423143487-4722-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Lad Prabhakar <prabhakar.csengg@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1423143487-4722-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 05, 2015 at 01:38:07PM +0000, Lad Prabhakar wrote:
> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
> 
> this patch fixes following sparse warning:
> 
> interface.c:83:5: warning: symbol 'xenvif_poll' was not declared. Should it be static?
> 
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

Thanks!

> ---
>  Found this issue on linux-next (gcc  version 4.9.2,
>  sparse version  0.4.5-rc1)and applies on top linux-next.
> 
>  drivers/net/xen-netback/interface.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 12f9e27..f38227a 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -80,7 +80,7 @@ static irqreturn_t xenvif_tx_interrupt(int irq, void *dev_id)
>  	return IRQ_HANDLED;
>  }
>  
> -int xenvif_poll(struct napi_struct *napi, int budget)
> +static int xenvif_poll(struct napi_struct *napi, int budget)
>  {
>  	struct xenvif_queue *queue =
>  		container_of(napi, struct xenvif_queue, napi);
> -- 
> 1.9.1
