From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Patch net] net: allow setting mac address of loopback device
Date: Thu, 30 Jan 2014 07:04:38 -0500
Message-ID: <20140130120438.GA16827@hmsreliant.think-freely.org>
References: <1391038731-7501-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38112 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753227AbaA3MFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 07:05:02 -0500
Content-Disposition: inline
In-Reply-To: <1391038731-7501-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 29, 2014 at 03:38:51PM -0800, Cong Wang wrote:
> We are trying to mirror the local traffic from lo to eth0,
> allowing setting mac address of lo to eth0 would make
> the ether addresses in these packets correct, so that
> we don't have to modify the ether header again.
> 
> Since usually no one cares about its mac address (all-zero),
> it is safe to allow those who care to set its mac address.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> 
> ---
> diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
> index c5011e0..a0ee030 100644
> --- a/drivers/net/loopback.c
> +++ b/drivers/net/loopback.c
> @@ -160,6 +160,7 @@ static const struct net_device_ops loopback_ops = {
>  	.ndo_init      = loopback_dev_init,
>  	.ndo_start_xmit= loopback_xmit,
>  	.ndo_get_stats64 = loopback_get_stats64,
> +	.ndo_set_mac_address = eth_mac_addr,
>  };
>  
>  /*
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Seems reasonable
Acked-by: Neil Horman <nhorman@tuxdriver.com>
