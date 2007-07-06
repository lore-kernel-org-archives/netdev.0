From: Jay Cliburn <jcliburn@gmail.com>
Subject: Re: [PATCH] atl1: remove write-only var in tx handler
Date: Fri, 6 Jul 2007 10:28:19 -0500
Message-ID: <20070706102819.5702f29f@osprey.hogchain.net>
References: <20070706150525.GD11067@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, csnook@redhat.com
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:57062 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757490AbXGFP2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 11:28:21 -0400
Received: by an-out-0708.google.com with SMTP id d31so51553and
        for <netdev@vger.kernel.org>; Fri, 06 Jul 2007 08:28:20 -0700 (PDT)
In-Reply-To: <20070706150525.GD11067@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 6 Jul 2007 19:05:25 +0400
Alexey Dobriyan <adobriyan@sw.ru> wrote:

> Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>
> ---
> 
>  drivers/net/atl1/atl1_main.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> --- a/drivers/net/atl1/atl1_main.c
> +++ b/drivers/net/atl1/atl1_main.c
> @@ -634,14 +634,13 @@ static void atl1_intr_tx(struct atl1_adapter
> *adapter) struct atl1_buffer *buffer_info;
>  	u16 sw_tpd_next_to_clean;
>  	u16 cmb_tpd_next_to_clean;
> -	u8 update = 0;
>  
>  	sw_tpd_next_to_clean = atomic_read(&tpd_ring->next_to_clean);
>  	cmb_tpd_next_to_clean =
> le16_to_cpu(adapter->cmb.cmb->tpd_cons_idx); 
>  	while (cmb_tpd_next_to_clean != sw_tpd_next_to_clean) {
>  		struct tx_packet_desc *tpd;
> -		update = 1;
> +
>  		tpd = ATL1_TPD_DESC(tpd_ring, sw_tpd_next_to_clean);
>  		buffer_info =
> &tpd_ring->buffer_info[sw_tpd_next_to_clean]; if (buffer_info->dma) {
> 
Acked-by: Jay Cliburn <jacliburn@bellsouth.net>
