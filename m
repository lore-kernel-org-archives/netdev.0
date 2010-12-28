From: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>
Subject: RE: [patch] vxge: remove duplicated part of check {nodisc}
Date: Tue, 28 Dec 2010 13:51:27 -0800
Message-ID: <FCA91A92EE52B041906A0358FC28FCC38EF8E701E1@FRE1EXCH02.hq.exar.com>
References: <20101224061539.GP1936@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Sivakumar Subramani <Sivakumar.Subramani@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>,
	Jon Mason <Jon.Mason@exar.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.exar.com ([204.154.183.83]:28166 "EHLO smtp1.exar.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752261Ab0L1Vv3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Dec 2010 16:51:29 -0500
In-Reply-To: <20101224061539.GP1936@bicker>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This is just a cleanup to make the static checkers happy.  We don't need
> to check "own" twice.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/vxge/vxge-
> traffic.c
> index 42cc298..4c10d6c 100644
> --- a/drivers/net/vxge/vxge-traffic.c
> +++ b/drivers/net/vxge/vxge-traffic.c
> @@ -1240,7 +1240,7 @@ enum vxge_hw_status vxge_hw_ring_rxd_next_completed(
>  	*t_code	= (u8)VXGE_HW_RING_RXD_T_CODE_GET(control_0);
> 
>  	/* check whether it is not the end */
> -	if (!own || ((*t_code == VXGE_HW_RING_T_CODE_FRM_DROP) && own)) {
> +	if (!own || *t_code == VXGE_HW_RING_T_CODE_FRM_DROP) {
> 
>  		vxge_assert(((struct vxge_hw_ring_rxd_1 *)rxdp)->host_control
> !=
>  				0);
Looks good, thanks.

Acked-by: Ram Vepa <ram.vepa@exar.com>
