From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] r8169: Add tx_buf_sz and rx_buf_coef on
 rtl_cfg_info
Date: Mon, 17 Aug 2015 07:34:29 -0700
Message-ID: <1439822069.7258.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439809846-3002-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Corcodel Marian <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:33574 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961AbbHQOec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 10:34:32 -0400
Received: by pdrh1 with SMTP id h1so57109132pdr.0
        for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 07:34:31 -0700 (PDT)
In-Reply-To: <1439809846-3002-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-08-17 at 14:10 +0300, Corcodel Marian wrote:
> Put rx_buf_sz on rtl_cfg_info structure and add new
>  parameter  rx_buf_coef.Param rx_buf_sz may be different by nic's and same
>  rx_buf_coef On RTL 8101 series rx_buf_coef is not equal with  rx_buf_sz.
>  Add --whitespace=warn on git
> 
> Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 6882eab..fecb7c9 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -344,7 +344,7 @@ static const struct pci_device_id rtl8169_pci_tbl[] = {
>  
>  MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
>  
> -static int rx_buf_sz = 16383;
> +//static int rx_buf_sz = 16383;

Really ?

You keep sending obscure r9169 patches, with no clear explanations.

Why should we review all this ?
