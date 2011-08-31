From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 1/1] net/can/af_can.c: Change del_timer to del_timer_sync
Date: Wed, 31 Aug 2011 19:28:02 +0200
Message-ID: <4E5E6F22.4060206@hartkopp.net>
References: <1314784658-23938-1-git-send-email-rajan.aggarwal85@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs.thuermann@volkswagen.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Rajan Aggarwal <rajan.aggarwal85@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:10999 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753736Ab1HaR2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 13:28:00 -0400
In-Reply-To: <1314784658-23938-1-git-send-email-rajan.aggarwal85@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31.08.2011 11:57, Rajan Aggarwal wrote:

> From: Rajan Aggarwal <Rajan Aggarwal rajan.aggarwal85@gmail.com>
> 
> This is important for SMP platform to check if timer function is
> executing on other CPU with deleting the timer.
> 
> Signed-off-by: Rajan Aggarwal <Rajan Aggarwal rajan.aggarwal85@gmail.com>
> ---


Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>

Tnx Rajan.

>  net/can/af_can.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/can/af_can.c b/net/can/af_can.c
> index 8ce926d..9b0c32a 100644
> --- a/net/can/af_can.c
> +++ b/net/can/af_can.c
> @@ -857,7 +857,7 @@ static __exit void can_exit(void)
>  	struct net_device *dev;
>  
>  	if (stats_timer)
> -		del_timer(&can_stattimer);
> +		del_timer_sync(&can_stattimer);
>  
>  	can_remove_proc();
>  
