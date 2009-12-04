From: Emese Revfy <re.emese@gmail.com>
Subject: Re: [PATCH 22/31] Constify struct neigh_ops for 2.6.32 v1
Date: Sat, 05 Dec 2009 00:02:48 +0100
Message-ID: <4B199518.7090300@gmail.com>
References: <4B198670.2000406@gmail.com> <4B198FA1.7090807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:52559 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753481AbZLDXA5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2009 18:00:57 -0500
In-Reply-To: <4B198FA1.7090807@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added netdev@vger.kernel.org to CC.
> From: Emese Revfy <re.emese@gmail.com>
> 
> Constify struct neigh_ops.
> 
> Signed-off-by: Emese Revfy <re.emese@gmail.com>
> ---
>  include/net/neighbour.h |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/include/net/neighbour.h b/include/net/neighbour.h
> index 3817fda..2c61d38 100644
> --- a/include/net/neighbour.h
> +++ b/include/net/neighbour.h
> @@ -125,12 +125,12 @@ struct neighbour
>  struct neigh_ops
>  {
>  	int			family;
> -	void			(*solicit)(struct neighbour *, struct sk_buff*);
> -	void			(*error_report)(struct neighbour *, struct sk_buff*);
> -	int			(*output)(struct sk_buff*);
> -	int			(*connected_output)(struct sk_buff*);
> -	int			(*hh_output)(struct sk_buff*);
> -	int			(*queue_xmit)(struct sk_buff*);
> +	void			(* const solicit)(struct neighbour *, struct sk_buff*);
> +	void			(* const error_report)(struct neighbour *, struct sk_buff*);
> +	int			(* const output)(struct sk_buff*);
> +	int			(* const connected_output)(struct sk_buff*);
> +	int			(* const hh_output)(struct sk_buff*);
> +	int			(* const queue_xmit)(struct sk_buff*);
>  };
>  
>  struct pneigh_entry
> 
> 

