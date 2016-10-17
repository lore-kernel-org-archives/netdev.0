From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2: fix locking when netconsole is used
Date: Mon, 17 Oct 2016 13:21:42 -0400 (EDT)
Message-ID: <20161017.132142.526817621160813690.davem@davemloft.net>
References: <1476721231-31624-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
        Dept-HSGLinuxNICDev@qlogic.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58166 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030397AbcJQRVn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 13:21:43 -0400
In-Reply-To: <1476721231-31624-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Mon, 17 Oct 2016 18:20:31 +0200

> diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
> index 27f11a5..9c408413 100644
> --- a/drivers/net/ethernet/broadcom/bnx2.c
> +++ b/drivers/net/ethernet/broadcom/bnx2.c
> @@ -272,21 +272,24 @@ static u32
>  bnx2_reg_rd_ind(struct bnx2 *bp, u32 offset)
>  {
>  	u32 val;
> +	unsigned long flags;
>  

Please order local variable declarations from longest to shortest
line.

Thank you.
