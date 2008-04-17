From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 06/13] sis190: use netdev_alloc_skb
Date: Thu, 17 Apr 2008 10:16:26 +0800
Message-ID: <4806B2FA.8020805@cn.fujitsu.com>
References: <20080416233727.732025083@vyatta.com> <20080416233757.391517921@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52879 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751325AbYDQCRu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 22:17:50 -0400
In-Reply-To: <20080416233757.391517921@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger said the following on 2008-4-17 7:37:
> +static int sis190_try_rx_copy(struct net_device *dev,
> +			      struct sk_buff **sk_buff, int pkt_size,
> +			      struct RxDesc *desc, int rx_buf_sz)
>  {
> -	int ret = -1;
> +	int ret = 01;
>

why not : ret = 1
  
>  	if (pkt_size < rx_copybreak) {
>  		struct sk_buff *skb;
>  
> -		skb = dev_alloc_skb(pkt_size + NET_IP_ALIGN);
> +		skb = netdev_alloc_skb(dev, pkt_size + 2);
>  		if (skb) {
> -			skb_reserve(skb, NET_IP_ALIGN);
> +			skb_reserve(skb, 2);

why?
[PATCH 02/13] atl1: use netdev_alloc_skb
using NET_IP_ALIGN, not 2.

