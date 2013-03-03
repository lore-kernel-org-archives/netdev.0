From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] CAIF: fix sparse warning for caif_usb
Date: Sun, 03 Mar 2013 17:49:25 -0500 (EST)
Message-ID: <20130303.174925.982387903456722818.davem@davemloft.net>
References: <1362316188-2927-1-git-send-email-silviupopescu1990@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sjur.brandeland@stericsson.com,
	linux-kernel@vger.kernel.org
To: silviupopescu1990@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362316188-2927-1-git-send-email-silviupopescu1990@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Date: Sun,  3 Mar 2013 15:09:48 +0200

> This fixes the following sparse warning:
> net/caif/caif_usb.c:84:16: warning: symbol 'cfusbl_create' was not
> declared. Should it be static?
> 
> Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
> ---
>  net/caif/caif_usb.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/caif/caif_usb.c b/net/caif/caif_usb.c
> index 3ebc8cb..cbae9b0 100644
> --- a/net/caif/caif_usb.c
> +++ b/net/caif/caif_usb.c
> @@ -81,7 +81,7 @@ static void cfusbl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
>  		layr->up->ctrlcmd(layr->up, ctrl, layr->id);
>  }
>  
> -struct cflayer *cfusbl_create(int phyid, u8 ethaddr[ETH_ALEN],
> +static struct cflayer *cfusbl_create(int phyid, u8 ethaddr[ETH_ALEN],
>  					u8 braddr[ETH_ALEN])

You need to fix up the indentation of the second line of
function arguments if you move the location of the openning
parenthesis on the first line, because all arguments on the
second and subsequent line must line up exactly at the first
column after the openning parenthesis of the first line.

Thanks.
