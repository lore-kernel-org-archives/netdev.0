From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] drivers/net/wireless/libertas/if_usb.c: add missing
 debugging code
Date: Mon, 16 Apr 2012 11:20:20 -0500
Message-ID: <1334593220.10194.30.camel@dcbw.foobar.com>
References: <1334591040-29298-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334591040-29298-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-04-16 at 17:44 +0200, Julia Lawall wrote:
> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Add a corresponding leave call on error failure.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Acked-by: Dan Williams <dcbw@redhat.com>

> 
> ---
>  drivers/net/wireless/libertas/if_usb.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/libertas/if_usb.c b/drivers/net/wireless/libertas/if_usb.c
> index 74da5f1..ce4938d 100644
> --- a/drivers/net/wireless/libertas/if_usb.c
> +++ b/drivers/net/wireless/libertas/if_usb.c
> @@ -1128,8 +1128,10 @@ static int if_usb_suspend(struct usb_interface *intf, pm_message_t message)
>  
>  	lbs_deb_enter(LBS_DEB_USB);
>  
> -	if (priv->psstate != PS_STATE_FULL_POWER)
> -		return -1;
> +	if (priv->psstate != PS_STATE_FULL_POWER) {
> +		ret = -1;
> +		goto out;
> +	}
>  
>  #ifdef CONFIG_OLPC
>  	if (machine_is_olpc()) {
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
