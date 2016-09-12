From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] atm: iphase: fix newline escape and minor tweak to source
 formatting
Date: Mon, 12 Sep 2016 14:55:23 +0300
Message-ID: <ac162c0a-eca0-5d03-ad9c-9ca23becb1b9@cogentembedded.com>
References: <20160912092930.20683-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        Chas Williams <3chas3@gmail.com>,
        linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160912092930.20683-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 9/12/2016 12:29 PM, Colin King wrote:

> From: Colin Ian King <colin.king@canonical.com>
>
> The newline escape is incorrect and needs fixing. Also adjust source
> formatting / indentation and remove trailing white space.
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/atm/iphase.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
> index 9d8807e..256b191 100644
> --- a/drivers/atm/iphase.c
> +++ b/drivers/atm/iphase.c
> @@ -1885,9 +1885,8 @@ static int open_tx(struct atm_vcc *vcc)
>                  if ((ret = ia_cbr_setup (iadev, vcc)) < 0) {
>                      return ret;
>                  }
> -       }
> -	else
> -           printk("iadev:  Non UBR, ABR and CBR traffic not supportedn");
> +	} else
> +		printk("iadev:  Non UBR, ABR and CBR traffic not supported\n");

    All branches of the *if* statement should have {} if at least one has them 
(perhaps a material for a follow-up patch).

[...]

MBR, Sergei
