From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH 3/5] ucc_geth: Fix two gcc warnings
Date: Wed, 3 Oct 2012 15:17:37 +0200
Message-ID: <OF3A4988F6.2CF03F70-ONC1257A8C.0049007B-C1257A8C.0049064D@transmode.se>
References: <1347987385-19071-1-git-send-email-Joakim.Tjernlund@transmode.se> <1347987385-19071-3-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:50984 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754802Ab2JCNRj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2012 09:17:39 -0400
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id 47EE52581D4
	for <netdev@vger.kernel.org>; Wed,  3 Oct 2012 15:17:38 +0200 (CEST)
In-Reply-To: <1347987385-19071-3-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ping? Got no comments and I can see it in net or net-next trees either.

Joakim Tjernlund <Joakim.Tjernlund@transmode.se> wrote on 2012/09/18 18:56:23:

> From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> To: netdev@vger.kernel.org,
> Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> Date: 2012/09/18 18:56
> Subject: [PATCH 3/5] ucc_geth: Fix two gcc warnings
>
> ucc_geth.c: In function 'ucc_geth_startup':
> ucc_geth.c:3092:45: warning: comparison between 'enum qe_fltr_largest_external_tbl_lookup_key_size' and 'enum qe_fltr_tbl_lookup_key_size'
>
> ucc_geth.c:3096:45: warning: comparison between 'enum qe_fltr_largest_external_tbl_lookup_key_size' and 'enum qe_fltr_tbl_lookup_key_size'
>
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> ---
>  drivers/net/ethernet/freescale/ucc_geth.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
> index 5f1460a..7d60b95 100644
> --- a/drivers/net/ethernet/freescale/ucc_geth.c
> +++ b/drivers/net/ethernet/freescale/ucc_geth.c
> @@ -3074,11 +3074,11 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
>     if (ug_info->rxExtendedFiltering) {
>        size += THREAD_RX_PRAM_ADDITIONAL_FOR_EXTENDED_FILTERING;
>        if (ug_info->largestexternallookupkeysize ==
> -          QE_FLTR_TABLE_LOOKUP_KEY_SIZE_8_BYTES)
> +          QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_8_BYTES)
>           size +=
>               THREAD_RX_PRAM_ADDITIONAL_FOR_EXTENDED_FILTERING_8;
>        if (ug_info->largestexternallookupkeysize ==
> -          QE_FLTR_TABLE_LOOKUP_KEY_SIZE_16_BYTES)
> +          QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_16_BYTES)
>           size +=
>               THREAD_RX_PRAM_ADDITIONAL_FOR_EXTENDED_FILTERING_16;
>     }
> --
> 1.7.8.6
>
