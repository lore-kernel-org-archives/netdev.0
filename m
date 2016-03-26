From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3.16]r8169: Add delay on set_rx_mode
Date: Sat, 26 Mar 2016 10:19:18 -0700
Message-ID: <1459012758.6473.73.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458991291-1600-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: Corcodel Marian <asd@marian1000.go.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35683 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348AbcCZRTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2016 13:19:20 -0400
Received: by mail-pf0-f176.google.com with SMTP id n5so104158646pfn.2
        for <netdev@vger.kernel.org>; Sat, 26 Mar 2016 10:19:20 -0700 (PDT)
In-Reply-To: <1458991291-1600-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-03-26 at 13:21 +0200, Corcodel Marian wrote:
>  Set one line  space extra delay on set_rx_mode for starting
>    on full duplex and full speed.
> 
> Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 0ae8969..457b12a 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -4646,6 +4646,7 @@ static void rtl_set_rx_mode(struct net_device *dev)
>  		mc_filter[1] = mc_filter[0] = 0xffffffff;
>  
>  	RTL_W32(MAR0 + 4, mc_filter[1]);
> +
>  	RTL_W32(MAR0 + 0, mc_filter[0]);
>  
>  	RTL_W32(RxConfig, tmp);

Seriously ?
