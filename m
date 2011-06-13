From: Bhavesh Davda <bhavesh@vmware.com>
Subject: RE: [Pv-drivers] [PATCH] vmxnet3: remove unused variable
Date: Mon, 13 Jun 2011 10:10:56 -0700
Message-ID: <382C2929804A6B469FF4A4200E716F480431EFCC7587@EXCH-MBX-1.vmware.com>
References: <1307980110-9585-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "VMware, Inc." <pv-drivers@vmware.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:32349 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753966Ab1FMRK7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2011 13:10:59 -0400
In-Reply-To: <1307980110-9585-1-git-send-email-nhorman@tuxdriver.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Good find. LGTM.

Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>

- Bhavesh
 
Bhavesh P. Davda

> -----Original Message-----
> From: pv-drivers-bounces@vmware.com [mailto:pv-drivers-bounces@vmware.com] On
> Behalf Of Neil Horman
> Sent: Monday, June 13, 2011 8:49 AM
> To: netdev@vger.kernel.org
> Cc: VMware, Inc.; David S. Miller; Neil Horman
> Subject: [Pv-drivers] [PATCH] vmxnet3: remove unused variable
> 
> While doing some backporting I noticed that vmxnet3 had a variable that was
> set
> but never used.  Get rid of it, and stop the compiler from griping
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: "VMware, Inc." <pv-drivers@vmware.com>
> CC: "David S. Miller" <davem@davemloft.net>
> ---
>  drivers/net/vmxnet3/vmxnet3_drv.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c
> b/drivers/net/vmxnet3/vmxnet3_drv.c
> index fa6e2ac..a9b60a2 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -405,10 +405,8 @@ vmxnet3_tq_cleanup(struct vmxnet3_tx_queue *tq,
> 
>  	while (tq->tx_ring.next2comp != tq->tx_ring.next2fill) {
>  		struct vmxnet3_tx_buf_info *tbi;
> -		union Vmxnet3_GenericDesc *gdesc;
> 
>  		tbi = tq->buf_info + tq->tx_ring.next2comp;
> -		gdesc = tq->tx_ring.base + tq->tx_ring.next2comp;
> 
>  		vmxnet3_unmap_tx_buf(tbi, adapter->pdev);
>  		if (tbi->skb) {
> --
> 1.7.5.4
> 
> _______________________________________________
> Pv-drivers mailing list
> Pv-drivers@vmware.com
> http://mailman2.vmware.com/mailman/listinfo/pv-drivers
