From: "Ariel Elior" <ariele@broadcom.com>
Subject: RE: [PATCH 1/1] net: bnx2x: Staticize local symbols
Date: Tue, 10 Sep 2013 08:23:59 +0000
Message-ID: <6AE768456CEC4B4A9B2248CB6B87EB3E1BEE8FD8@SJEXCHMB05.corp.ad.broadcom.com>
References: <1378798960-6572-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Sachin Kamat" <sachin.kamat@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3759 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752468Ab3IJIYM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 04:24:12 -0400
In-Reply-To: <1378798960-6572-1-git-send-email-sachin.kamat@linaro.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Sachin Kamat
> Sent: Tuesday, September 10, 2013 9:43 AM
> To: netdev@vger.kernel.org
> Cc: davem@davemloft.net; Eilon Greenstein; sachin.kamat@linaro.org
> Subject: [PATCH 1/1] net: bnx2x: Staticize local symbols
> 
> Local symbols used only in this file are made static.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
> index 2604b62..5ec30cc 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
> @@ -2802,7 +2802,7 @@ struct set_vf_state_cookie {
>  	u8 state;
>  };
> 
> -void bnx2x_set_vf_state(void *cookie)
> +static void bnx2x_set_vf_state(void *cookie)
>  {
>  	struct set_vf_state_cookie *p = (struct set_vf_state_cookie
> *)cookie;
> 
> @@ -3222,7 +3222,8 @@ void bnx2x_disable_sriov(struct bnx2x *bp)
>  	pci_disable_sriov(bp->pdev);
>  }
> 
> -int bnx2x_vf_ndo_prep(struct bnx2x *bp, int vfidx, struct bnx2x_virtf **vf,
> +static int
I don't like this form. Better to put the last variable in the next line.

> +bnx2x_vf_ndo_prep(struct bnx2x *bp, int vfidx, struct bnx2x_virtf **vf,
>  			struct pf_vf_bulletin_content **bulletin)
>  {
>  	if (bp->state != BNX2X_STATE_OPEN) {
> --
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Thanks for suggesting the fix.
Not sure this is appropriate for net though...
Ariel
