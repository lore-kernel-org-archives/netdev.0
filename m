From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH 1/7] dma/shdma.c Typo change desciptor to descriptor.
Date: Wed, 19 Jan 2011 15:38:18 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1101191537280.26685@pobox.suse.cz>
References: <1293817097-7945-1-git-send-email-justinmattock@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: dan.j.williams@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-usb@vger.kernel.org
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293817097-7945-1-git-send-email-justinmattock@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 31 Dec 2010, Justin P. Mattock wrote:

> Below is a patch, that changes a typo from "desciptor" to "descriptor".
> Let me know if I missed anything.
> 
> Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>
> 
> ---
>  drivers/dma/shdma.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/dma/shdma.c b/drivers/dma/shdma.c
> index 85ffd5e..72d25d9 100644
> --- a/drivers/dma/shdma.c
> +++ b/drivers/dma/shdma.c
> @@ -740,7 +740,7 @@ static void sh_chan_xfer_ld_queue(struct sh_dmae_chan *sh_chan)
>  		return;
>  	}
>  
> -	/* Find the first not transferred desciptor */
> +	/* Find the first not transferred descriptor */
>  	list_for_each_entry(desc, &sh_chan->ld_queue, node)
>  		if (desc->mark == DESC_SUBMITTED) {
>  			dev_dbg(sh_chan->dev, "Queue #%d to %d: %u@%x -> %x\n",

I have folded the whole series into one patch and applied, thanks.

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
