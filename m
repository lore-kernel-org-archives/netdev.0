From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH] drivers: net: xgene: constify xgene_cle_ops structure
Date: Sun, 1 May 2016 16:10:36 -0700
Message-ID: <CAKh23F=fpRhTp1Y+XvJHa6Q6Bp_BGKS_AYyr8Cryx8A+KGHM7Q@mail.gmail.com>
References: <1462106189-14277-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kernel-janitors@vger.kernel.org, Keyur Chudgar <kchudgar@apm.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:36390 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752453AbcEAXKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 19:10:38 -0400
Received: by mail-oi0-f44.google.com with SMTP id x201so173159839oif.3
        for <netdev@vger.kernel.org>; Sun, 01 May 2016 16:10:37 -0700 (PDT)
In-Reply-To: <1462106189-14277-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 1, 2016 at 5:36 AM, Julia Lawall <Julia.Lawall@lip6.fr> wrote:
> The xgene_cle_ops structure is never modified, so declare it as const.
>
> Done with the help of Coccinelle.
>
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
>
> ---
>  drivers/net/ethernet/apm/xgene/xgene_enet_cle.c  |    2 +-
>  drivers/net/ethernet/apm/xgene/xgene_enet_cle.h  |    2 +-
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.h |    2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
> index b2124886..6479288 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
> @@ -729,6 +729,6 @@ static int xgene_enet_cle_init(struct xgene_enet_pdata *pdata)
>         return xgene_cle_setup_ptree(pdata, enet_cle);
>  }
>
> -struct xgene_cle_ops xgene_cle3in_ops = {
> +const struct xgene_cle_ops xgene_cle3in_ops = {
>         .cle_init = xgene_enet_cle_init,
>  };
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h
> index 29a17ab..13e829a 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h
> @@ -290,6 +290,6 @@ struct xgene_enet_cle {
>         u32 jump_bytes;
>  };
>
> -extern struct xgene_cle_ops xgene_cle3in_ops;
> +extern const struct xgene_cle_ops xgene_cle3in_ops;
>
>  #endif /* __XGENE_ENET_CLE_H__ */
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
> index 175d188..0a2887b 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
> @@ -191,7 +191,7 @@ struct xgene_enet_pdata {
>         const struct xgene_mac_ops *mac_ops;
>         const struct xgene_port_ops *port_ops;
>         struct xgene_ring_ops *ring_ops;
> -       struct xgene_cle_ops *cle_ops;
> +       const struct xgene_cle_ops *cle_ops;
>         struct delayed_work link_work;
>         u32 port_id;
>         u8 cpu_bufnum;
>

Thanks Julia.

Acked-by: Iyappan Subramanian <isubramanian@apm.com>
