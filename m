From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/6] bnxt_en: Pass RoCE app priority to
 firmware.
Date: Wed, 11 Jan 2017 10:46:24 -0500 (EST)
Message-ID: <20170111.104624.1616254027007040020.davem@davemloft.net>
References: <1484097159-21575-1-git-send-email-michael.chan@broadcom.com>
        <1484097159-21575-6-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51542 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752144AbdAKPq3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 10:46:29 -0500
In-Reply-To: <1484097159-21575-6-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Tue, 10 Jan 2017 20:12:38 -0500

> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h
> index 35a0d28..f2630cc 100644
> --- a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h
> +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h
> @@ -36,6 +36,9 @@ struct bnxt_cos2bw_cfg {
>  
>  #define HWRM_STRUCT_DATA_SUBTYPE_HOST_OPERATIONAL	0x0300
>  
> +#define ETH_P_ROCE		0x8915

There's also a similar define in the qedr infiniband driver, this doesn't
make much sense.

Please add this to if_ether.h, and reference it from there in the drivers.

Thanks.
