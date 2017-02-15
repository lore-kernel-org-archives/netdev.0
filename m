From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next 01/13] net: ethernet: aquantia: Removed extra
 assignment for skb->dev.
Date: Wed, 15 Feb 2017 21:53:54 +0100
Message-ID: <ea14de65-6ad8-7601-aadc-6be1fc1ebb88@gmx.de>
References: <cover.1487187192.git.pavel.belous@aquantia.com>
 <31d152c1fba6779d0ed1a00c620cba34db3df8a2.1487187192.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:58693 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751356AbdBOUyG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 15:54:06 -0500
In-Reply-To: <31d152c1fba6779d0ed1a00c620cba34db3df8a2.1487187192.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 15.02.2017 21:01, Pavel Belous wrote:
> From: Pavel Belous <pavel.belous@aquantia.com>
>
> This assignment is not needed.
>
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
> ---
>  drivers/net/ethernet/aquantia/atlantic/aq_ring.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
> index dea9e9b..4c40644 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
> @@ -214,7 +214,6 @@ int aq_ring_rx_clean(struct aq_ring_s *self, int *work_done, int budget)
>  				goto err_exit;
>  			}
>
> -			skb->dev = ndev;
>  			skb_put(skb, buff->len);
>  		} else {
>  			skb = netdev_alloc_skb(ndev, ETH_HLEN);
>

Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
