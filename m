From: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>
Subject: RE: [PATCH] vxge: Fix wrong boolean operator {nodisc}
Date: Mon, 31 Jan 2011 23:26:40 -0800
Message-ID: <FCA91A92EE52B041906A0358FC28FCC38EFBE64996@FRE1EXCH02.hq.exar.com>
References: <1296253817-7668-1-git-send-email-weil@mail.berlios.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Sivakumar Subramani <Sivakumar.Subramani@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jon Mason <Jon.Mason@exar.com>
To: Stefan Weil <weil@mail.berlios.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1296253817-7668-1-git-send-email-weil@mail.berlios.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This error is reported by cppcheck:
> drivers/net/vxge/vxge-config.c:3693: warning: Mutual exclusion over ||
> always evaluates to true. Did you intend to use && instead?
> 
> It looks like cppcheck is correct, so fix this. No test was run.
> 
> Signed-off-by: Stefan Weil <weil@mail.berlios.de>
> ---
>  drivers/net/vxge/vxge-config.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-
> config.c
> index 01c05f5..228d4f7 100644
> --- a/drivers/net/vxge/vxge-config.c
> +++ b/drivers/net/vxge/vxge-config.c
> @@ -3690,7 +3690,7 @@ __vxge_hw_vpath_rts_table_get(struct
> __vxge_hw_vpath_handle *vp,
>  	if (status != VXGE_HW_OK)
>  		goto exit;
> 
> -	if ((rts_table != VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_DA)
> ||
> +	if ((rts_table != VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_DA)
> &&
>  	    (rts_table !=
>  	     VXGE_HW_RTS_ACS_STEER_CTRL_DATA_STRUCT_SEL_RTH_MULTI_IT))
>  		*data1 = 0;
> --
Fix looks good. Thanks!

Acked-by: Ram Vepa <ram.vepa@exar.com>
