From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] pasemi_mac: fix typo
Date: Tue, 23 Oct 2007 20:23:42 -0400
Message-ID: <471E908E.8080409@pobox.com>
References: <20071020191003.GB30034@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36033 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755625AbXJXAXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 20:23:46 -0400
In-Reply-To: <20071020191003.GB30034@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olof Johansson wrote:
> Add missing &:
> 
> drivers/net/pasemi_mac.c: In function 'pasemi_mac_clean_rx':
> drivers/net/pasemi_mac.c:553: warning: passing argument 1 of 'prefetch'
> makes pointer from integer without a cast
> 
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>
> 
> diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
> index 9f9a421..ab4d309 100644
> --- a/drivers/net/pasemi_mac.c
> +++ b/drivers/net/pasemi_mac.c
> @@ -550,7 +550,7 @@ static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
>  
>  	n = mac->rx->next_to_clean;
>  
> -	prefetch(RX_RING(mac, n));
> +	prefetch(&RX_RING(mac, n));
>  
>  	for (count = 0; count < limit; count++) {
>  		macrx = RX_RING(mac, n);

applied


