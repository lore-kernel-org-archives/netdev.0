From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 08/12] r8152: support TSO
Date: Tue, 04 Mar 2014 08:52:09 -0800
Message-ID: <1393951929.26794.120.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
	 <1393934464-23675-9-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393934464-23675-9-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-03-04 at 20:01 +0800, Hayes Wang wrote:
> Support scatter gather and TSO.

>  
> -	netdev->features |= NETIF_F_RXCSUM | NETIF_F_IP_CSUM;
> -	netdev->hw_features = NETIF_F_RXCSUM | NETIF_F_IP_CSUM;
> +	netdev->features |= NETIF_F_RXCSUM | NETIF_F_IP_CSUM | NETIF_F_SG |
> +			    NETIF_F_TSO;
> +	netdev->hw_features = NETIF_F_RXCSUM | NETIF_F_IP_CSUM | NETIF_F_SG |
> +			      NETIF_F_TSO;
>  

Minor nit :

If you use skb_copy_bits(), then you also can add NETIF_F_FRAGLIST here.
