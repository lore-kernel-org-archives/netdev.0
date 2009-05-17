From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH] Neterion: *FIFO1_DMA_ERR set twice, should 2nd be *FIFO2_DMA_ERR?
Date: Sun, 17 May 2009 03:52:59 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7705444A38@nekter>
References: <4A0DCE67.70106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>
To: "Roel Kluin" <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:39424 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751779AbZEQHw7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 03:52:59 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4A0DCE67.70106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> FIFO1_DMA_ERR is set twice, the second should be FIFO2_DMA_ERR.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> Correct? Please review.
> 
> diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/vxge/vxge-
> traffic.c
> index 7be0ae1..c2eeac4 100644
> --- a/drivers/net/vxge/vxge-traffic.c
> +++ b/drivers/net/vxge/vxge-traffic.c
> @@ -115,7 +115,7 @@ enum vxge_hw_status
vxge_hw_vpath_intr_enable(struct
> __vxge_hw_vpath_handle *vp)
>  		VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO1_POISON|
>  		VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO2_POISON|
>  		VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO1_DMA_ERR|
> -		VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO1_DMA_ERR), 0,
32),
> +		VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO2_DMA_ERR), 0,
32),
>  		&vp_reg->kdfcctl_errors_mask);
> 
>  	__vxge_hw_pio_mem_write32_upper(0,
&vp_reg->vpath_ppif_int_mask);
[Ram] Good catch!
Acked-by: Ram Vepa <ram.vepa@neterion.com>

Thanks,
Ram
