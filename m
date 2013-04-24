From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 2/4] net: increase frag hash size
Date: Wed, 24 Apr 2013 16:48:59 -0700
Message-ID: <1366847339.8964.90.camel@edumazet-glaptop>
References: <20130424154624.16883.40974.stgit@dragon>
	 <20130424154822.16883.93014.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f47.google.com ([209.85.210.47]:43780 "EHLO
	mail-da0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932068Ab3DXXtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 19:49:01 -0400
Received: by mail-da0-f47.google.com with SMTP id p1so1115073dad.6
        for <netdev@vger.kernel.org>; Wed, 24 Apr 2013 16:49:01 -0700 (PDT)
In-Reply-To: <20130424154822.16883.93014.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-24 at 17:48 +0200, Jesper Dangaard Brouer wrote:
> Increase fragmentation hash bucket size to 1024 from old 64 elems.
> 
> After we increased the frag mem limits (in commit v3.8-rc3-503-gc2a9366)
> the hash size of 64 elements is simply too small.  Also considering
> the mem limit is per netns and the hash table is shared for all netns.
> 
> For the embedded people, note that this increase will change the hash
> table/array from using approx 1 Kbytes to 16 Kbytes.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
> 
>  include/net/inet_frag.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
> index eb1d6ee..4e15856 100644
> --- a/include/net/inet_frag.h
> +++ b/include/net/inet_frag.h
> @@ -41,7 +41,7 @@ struct inet_frag_queue {
>  	struct netns_frags	*net;
>  };
>  
> -#define INETFRAGS_HASHSZ		64
> +#define INETFRAGS_HASHSZ	1024

Acked-by: Eric Dumazet <edumazet@google.com>
