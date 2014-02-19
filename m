From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] atm: nicstar: use NULL instead of 0 for pointer
Date: Wed, 19 Feb 2014 09:53:44 -0500
Message-ID: <20140219095344.6d5003fc@thirdoffive.cmf.nrl.navy.mil>
References: <1738246.bUPoQjSxLC@daeseok-laptop.cloud.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Daeseok Youn <daeseok.youn@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1738246.bUPoQjSxLC@daeseok-laptop.cloud.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Feb 2014 14:12:46 +0900
Daeseok Youn <daeseok.youn@gmail.com> wrote:

> >From c320d2ea1ed51c88255c33a50c74fa3598ab7be6 Mon Sep 17 00:00:00 2001
> From: Daeseok Youn <daeseok.youn@gmail.com>
> Date: Wed, 19 Feb 2014 10:10:11 +0900
> Subject: [PATCH] atm: nicstar: use NULL instead of 0 for pointer
> 
> sparse says:
> 
> drivers/atm/nicstar.c:642:27: warning:
>  Using plain integer as NULL pointer
> drivers/atm/nicstar.c:644:27:
>  warning: Using plain integer as NULL pointer
> drivers/atm/nicstar.c:982:51:
>  warning: Using plain integer as NULL pointer
> drivers/atm/nicstar.c:996:51:
>  warning: Using plain integer as NULL pointer
> 
> Signed-off-by: Daeseok Youn <daeseok.youn@gmail.com>
> ---
>  drivers/atm/nicstar.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
> index 9587e95..13ed54c 100644
> --- a/drivers/atm/nicstar.c
> +++ b/drivers/atm/nicstar.c
> @@ -639,9 +639,9 @@ static int ns_init_card(int i, struct pci_dev *pcidev)
>  	card->hbnr.init = NUM_HB;
>  	card->hbnr.max = MAX_HB;
>  
> -	card->sm_handle = 0x00000000;
> +	card->sm_handle = NULL;
>  	card->sm_addr = 0x00000000;
> -	card->lg_handle = 0x00000000;
> +	card->lg_handle = NULL;
>  	card->lg_addr = 0x00000000;
>  
>  	card->efbie = 1;	/* To prevent push_rxbufs from enabling the interrupt */
> @@ -979,7 +979,7 @@ static void push_rxbufs(ns_dev * card, struct sk_buff *skb)
>  				addr2 = card->sm_addr;
>  				handle2 = card->sm_handle;
>  				card->sm_addr = 0x00000000;
> -				card->sm_handle = 0x00000000;
> +				card->sm_handle = NULL;
>  			} else {	/* (!sm_addr) */
>  
>  				card->sm_addr = addr1;
> @@ -993,7 +993,7 @@ static void push_rxbufs(ns_dev * card, struct sk_buff *skb)
>  				addr2 = card->lg_addr;
>  				handle2 = card->lg_handle;
>  				card->lg_addr = 0x00000000;
> -				card->lg_handle = 0x00000000;
> +				card->lg_handle = NULL;
>  			} else {	/* (!lg_addr) */
>  
>  				card->lg_addr = addr1;

Acked-by: Chas Williams <chas@cmf.nrl.navy.mil>
