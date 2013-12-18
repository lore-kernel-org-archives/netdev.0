From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: RE: [PATCH] bnx2x: downgrade "valid ME register value" message level
Date: Wed, 18 Dec 2013 06:37:19 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52AF1CF20@SJEXCHMB10.corp.ad.broadcom.com>
References: <1387302685-32314-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ariel Elior <ariele@broadcom.com>
To: Michal Schmidt <mschmidt@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:62752 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665Ab3LRGhd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 01:37:33 -0500
In-Reply-To: <1387302685-32314-1-git-send-email-mschmidt@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> "valid ME register value" is not an error. It should be logged for
> debugging only.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Yep, that's true; Thanks Michal.

Acked-by: Yuval Mintz <yuvalmin@broadcom.com>

> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
> index efa8a15..3dc2537 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
> @@ -208,7 +208,7 @@ static int bnx2x_get_vf_id(struct bnx2x *bp, u32
> *vf_id)
>  		return -EINVAL;
>  	}
> 
> -	BNX2X_ERR("valid ME register value: 0x%08x\n", me_reg);
> +	DP(BNX2X_MSG_IOV, "valid ME register value: 0x%08x\n", me_reg);
> 
>  	*vf_id = (me_reg & ME_REG_VF_NUM_MASK) >>
> ME_REG_VF_NUM_SHIFT;
