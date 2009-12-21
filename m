From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 3/7] drivers/net/cxgb3: Use kzalloc for allocating only
 one thing
Date: Mon, 21 Dec 2009 15:33:41 -0800
Message-ID: <4B3005D5.9070608@chelsio.com>
References: <Pine.LNX.4.64.0912190816340.30546@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751534AbZLUXjl@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0912190816340.30546@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julia Lawall wrote:
>
> From: Julia Lawall <julia@diku.dk>
>
> Use kzalloc rather than kcalloc(1,...)
>
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
>
> // <smpl>
> @@
> @@
>
> - kcalloc(1,
> + kzalloc(
>           ...)
> // </smpl>
>
> Signed-off-by: Julia Lawall <julia@diku.dk>
>

Acked-by: Divy Le Ray <divy@chelsio.com>

>
> ---
>  drivers/net/cxgb3/cxgb3_offload.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff -u -p a/drivers/net/cxgb3/cxgb3_offload.c 
> b/drivers/net/cxgb3/cxgb3_offload.c
> --- a/drivers/net/cxgb3/cxgb3_offload.c 2009-09-14 14:55:49.000000000 
> +0200
> +++ b/drivers/net/cxgb3/cxgb3_offload.c 2009-12-19 07:52:52.000000000 
> +0100
> @@ -1252,7 +1252,7 @@ int cxgb3_offload_activate(struct adapte
>         struct mtutab mtutab;
>         unsigned int l2t_capacity;
>
> -       t = kcalloc(1, sizeof(*t), GFP_KERNEL);
> +       t = kzalloc(sizeof(*t), GFP_KERNEL);
>         if (!t)
>                 return -ENOMEM;
>
