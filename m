From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] udp: Generic functions to set checksum
Date: Sun, 01 Jun 2014 19:49:42 -0700 (PDT)
Message-ID: <20140601.194942.1014308083943595457.davem@davemloft.net>
References: <alpine.DEB.2.02.1405282113290.6331@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753804AbaFBCtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 22:49:43 -0400
In-Reply-To: <alpine.DEB.2.02.1405282113290.6331@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 28 May 2014 21:23:27 -0700 (PDT)

> Added udp_set_csum and udp6_set_csum functions to set UDP checksums
> in packets. These are for simple UDP packets such as those that might
> be created in UDP tunnels.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/net/ip6_checksum.h | 45 +++++++++++++++++++++++++++++++++++++++++++++
>  include/net/udp.h          | 42 ++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 87 insertions(+)
> 
> diff --git a/include/net/ip6_checksum.h b/include/net/ip6_checksum.h
> index 8ac5c21..7382a12 100644
> --- a/include/net/ip6_checksum.h
> +++ b/include/net/ip6_checksum.h
> @@ -82,5 +82,50 @@ static inline void tcp_v6_send_check(struct sock *sk, struct sk_buff *skb)
>  }
>  #endif
>  
> +static inline __sum16 udp_v6_check(int len,
> +				       const struct in6_addr *saddr,
> +				       const struct in6_addr *daddr,
> +				       __wsum base)

Tom, please indent this correctly.  I applied this patch and double checked
and it comes out like this:

static inline __sum16 udp_v6_check(int len,
				       const struct in6_addr *saddr,
				       const struct in6_addr *daddr,
				       __wsum base)

Those arguments must start precisely at the first column after the
openning parenthesis of the function declaration.
