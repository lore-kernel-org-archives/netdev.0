From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fix checksum features handling in
 netif_skb_features()
Date: Thu, 21 Aug 2014 16:33:20 -0700 (PDT)
Message-ID: <20140821.163320.476216950054835385.davem@davemloft.net>
References: <20140815095617.3006CA0BED@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mkubecek@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140815095617.3006CA0BED@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Kubecek <mkubecek@suse.cz>
Date: Fri, 15 Aug 2014 11:56:17 +0200 (CEST)

> @@ -2587,13 +2587,18 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
>  		return harmonize_features(skb, features);
>  	}
>  
> -	features &= (skb->dev->vlan_features | NETIF_F_HW_VLAN_CTAG_TX |
> -					       NETIF_F_HW_VLAN_STAG_TX);
> +	features = netdev_intersect_features(features, skb->dev->vlan_features |
> +						       NETIF_F_HW_VLAN_CTAG_TX |
> +						       NETIF_F_HW_VLAN_STAG_TX);

This is not indented properly.

The second and subsequent lines of the function call should start precisely
at the first column after the openning parenthesis on the first line.  You
should use the appropriate number of TAB and SPACE characters necessary
to do so.

Thanks.
