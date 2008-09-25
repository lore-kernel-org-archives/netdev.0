From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] atl2: add tx bytes statistic
Date: Wed, 24 Sep 2008 22:15:40 -0400
Message-ID: <48DAF44C.40701@garzik.org>
References: <20080920184705.46ba1669@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <csnook@redhat.com>, jie.yang@atheros.com,
	netdev@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55436 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752671AbYIYCPw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 22:15:52 -0400
In-Reply-To: <20080920184705.46ba1669@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn wrote:
> From: Jay Cliburn <jacliburn@bellsouth.net>
> Date: Sat, 20 Sep 2008 17:37:05 -0500
> Subject: [PATCH] atl2: add tx bytes statistic
> 
> Let's see how many bytes have been transmitted.
> 
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
> ---
>  drivers/net/atlx/atl2.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
> index b2995ac..4f82f66 100644
> --- a/drivers/net/atlx/atl2.c
> +++ b/drivers/net/atlx/atl2.c
> @@ -522,8 +522,10 @@ static void atl2_intr_tx(struct atl2_adapter *adapter)
>  		atomic_set(&adapter->txd_read_ptr, (int)txd_read_ptr);
>  
>  		/* tx statistics: */
> -		if (txs->ok)
> +		if (txs->ok) {
> +			adapter->net_stats.tx_bytes += txs->pkt_size;
>  			adapter->net_stats.tx_packets++;

applied


