From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] net: bnx2x: fix error value sign
Date: Sun, 14 Nov 2010 22:26:43 +0200
Message-ID: <1289766403.29137.0.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1289765315-6028-1-git-send-email-segoon@openwall.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Vasiliy Kulikov" <segoon@openwall.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1289765315-6028-1-git-send-email-segoon@openwall.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2010-11-14 at 12:08 -0800, Vasiliy Kulikov wrote:
> bnx2x_init_one() should return negative value on error.
> By mistake it returns ENODEV instead of -ENODEV.
> 
> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
Thanks Vasiliy!

Acked-by: Eilon Greenstein <eilong@broadcom.com>
> ---
>  Compile tested.
> 
>  drivers/net/bnx2x/bnx2x_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
> index 4a6f0ea..be52edc 100644
> --- a/drivers/net/bnx2x/bnx2x_main.c
> +++ b/drivers/net/bnx2x/bnx2x_main.c
> @@ -9064,7 +9064,7 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
>  	default:
>  		pr_err("Unknown board_type (%ld), aborting\n",
>  			   ent->driver_data);
> -		return ENODEV;
> +		return -ENODEV;
>  	}
>  
>  	cid_count += CNIC_CONTEXT_USE;
