From: Bing Zhao <bzhao@marvell.com>
Subject: RE: [PATCH 4/4] drivers/net/wireless/mwifiex/scan.c: convert
 GFP_KERNEL to GFP_ATOMIC
Date: Mon, 9 Jan 2012 10:49:19 -0800
Message-ID: <477F20668A386D41ADCC57781B1F7043083601A973@SC-VEXCH1.marvell.com>
References: <1326102050-30265-4-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1326102050-30265-4-git-send-email-Julia.Lawall@lip6.fr>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Julia,

Thanks for the patch.

> Subject: [PATCH 4/4] drivers/net/wireless/mwifiex/scan.c: convert GFP_KERNEL to GFP_ATOMIC
> 
> From: Julia Lawall <julia.lawall@lip6.fr>
> 
> The function is called with locks held and thus should not use GFP_KERNEL.
> 
> The semantic patch that makes this report is available
> in scripts/coccinelle/locks/call_kern.cocci.
> 
> More information about semantic patching is available at
> http://coccinelle.lip6.fr/
> 
> Signed-off-by: Julia Lawall <julia.lawall@lip6.fr>

Acked-by: Bing Zhao <bzhao@marvell.com>

Regards,
Bing

> 
> ---
>  drivers/net/wireless/mwifiex/scan.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/mwifiex/scan.c b/drivers/net/wireless/mwifiex/scan.c
> index 6396d33..98f1ca9 100644
> --- a/drivers/net/wireless/mwifiex/scan.c
> +++ b/drivers/net/wireless/mwifiex/scan.c
> @@ -2001,7 +2001,7 @@ mwifiex_save_curr_bcn(struct mwifiex_private *priv)
> 
>  		kfree(priv->curr_bcn_buf);
>  		priv->curr_bcn_buf = kmalloc(curr_bss->beacon_buf_size,
> -						GFP_KERNEL);
> +						GFP_ATOMIC);
>  		if (!priv->curr_bcn_buf) {
>  			dev_err(priv->adapter->dev,
>  					"failed to alloc curr_bcn_buf\n");
