From: Pekka Riikonen <priikone@iki.fi>
Subject: Re: [PATCH next-next v4 1/2] net: Use 16bits for inner_*_headers
 fields of struct skbuff
Date: Wed, 22 May 2013 09:25:16 +0200 (CEST)
Message-ID: <alpine.GSO.2.00.1305220923130.11532@git.silcnet.org>
References: <1369205836-9407-1-git-send-email-horms@verge.net.au> <1369205836-9407-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	jarno.rajahalme@nsn.com, Eric Dumazet <eric.dumazet@gmail.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from git.silcnet.org ([81.89.56.81]:42361 "EHLO git.silcnet.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751742Ab3EVH0Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 03:26:16 -0400
In-Reply-To: <1369205836-9407-2-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 May 2013, Simon Horman wrote:

> include/linux/skbuff.h | 63 +++++++-------------------------------------------
> 1 file changed, 8 insertions(+), 55 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 2e0ced1..3791615 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -509,9 +509,9 @@ struct sk_buff {
> 		__u32		reserved_tailroom;
> 	};
>
> -	sk_buff_data_t		inner_transport_header;
> -	sk_buff_data_t		inner_network_header;
> -	sk_buff_data_t		inner_mac_header;
> +	__u16			inner_transport_header;
> +	__u16			inner_network_header;
> +	__u16			inner_mac_header;
> 	sk_buff_data_t		transport_header;
> 	sk_buff_data_t		network_header;
> 	sk_buff_data_t		mac_header;
>
Why not take one more step and use 16-bit fields for the other header 
fields too: transport_header, network_header and mac_header?

 	Pekka
