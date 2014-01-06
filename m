From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 1/5] bnx2x: limit number of interrupt vectors for
 57711
Date: Mon, 06 Jan 2014 17:47:34 +0400
Message-ID: <52CAB3F6.2060901@cogentembedded.com>
References: <1388939634-19948-1-git-send-email-yuvalmin@broadcom.com> <1388939634-19948-2-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com
To: Yuval Mintz <yuvalmin@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:50981 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754254AbaAFNrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 08:47:35 -0500
Received: by mail-la0-f50.google.com with SMTP id el20so9698061lab.23
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 05:47:34 -0800 (PST)
In-Reply-To: <1388939634-19948-2-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05-01-2014 20:33, Yuval Mintz wrote:

> From: Dmitry Kravkov <dmitry@broadcom.com>

> Original straightforward division may lead to zeroing number of SB and
> null-pointer dereference when device is short of MSIX vectors or lacks
> MSIX capabilities.

> Reported-by: Vladislav Zolotarov <vladz@cloudius-systems.com>
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> ---
>   drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      | 2 ++
>   drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 6 +++---
>   2 files changed, 5 insertions(+), 3 deletions(-)

> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> index a1f66e2..cb30d1a 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> @@ -2499,4 +2499,6 @@ void bnx2x_set_local_cmng(struct bnx2x *bp);
>   #define MCPR_SCRATCH_BASE(bp) \
>   	(CHIP_IS_E1x(bp) ? MCP_REG_MCPR_SCRATCH : MCP_A_REG_MCPR_SCRATCH)
>
> +#define E1H_MAX_MF_SB_COUNT (HC_SB_MAX_SB_E1X/(E1HVN_MAX * PORT_MAX))

    Be consistent and put spaces around / too, please.

WBR, Sergei
