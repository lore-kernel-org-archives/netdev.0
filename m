From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next-next v4 1/2] net: Use 16bits for inner_*_headers
 fields of struct skbuff
Date: Thu, 23 May 2013 18:38:17 -0700 (PDT)
Message-ID: <20130523.183817.86513902587870539.davem@davemloft.net>
References: <1369205836-9407-1-git-send-email-horms@verge.net.au>
	<1369205836-9407-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dev@openvswitch.org, netdev@vger.kernel.org, jesse@nicira.com,
	pshelar@nicira.com, jarno.rajahalme@nsn.com,
	eric.dumazet@gmail.com, maze@google.com
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37423 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758000Ab3EXBiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 21:38:18 -0400
In-Reply-To: <1369205836-9407-2-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Wed, 22 May 2013 15:57:15 +0900

> @@ -509,9 +509,9 @@ struct sk_buff {
>  		__u32		reserved_tailroom;
>  	};
>  
> -	sk_buff_data_t		inner_transport_header;
> -	sk_buff_data_t		inner_network_header;
> -	sk_buff_data_t		inner_mac_header;
> +	__u16			inner_transport_header;
> +	__u16			inner_network_header;
> +	__u16			inner_mac_header;
>  	sk_buff_data_t		transport_header;
>  	sk_buff_data_t		network_header;
>  	sk_buff_data_t		mac_header;

As Pekka suggested, let's try to convert them allto __u16.

Thanks.
