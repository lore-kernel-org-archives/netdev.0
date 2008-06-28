From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix corrupt TCP packets when options space overflows
 with MD5SIG enabled (v2)
Date: Fri, 27 Jun 2008 19:47:25 -0700 (PDT)
Message-ID: <20080627.194725.90012391.davem@davemloft.net>
References: <20080618.150104.147203818.davem@davemloft.net>
	<396556a20805301217k293e5718h6bbf02bfe0683145@europa>
	<396556a20805301217k293e5718h6bbf02bfe0683146@europa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54913
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751229AbYF1CrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 22:47:25 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe0683146@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Fri, 20 Jun 2008 13:27:23 -0700

> @@ -296,7 +296,7 @@ static inline void TCP_ECN_send_syn(struct sock *sk, struct sk_buff *skb)
>  	}
>  }
>  
> -static __inline__ void
> +	static __inline__ void
>  TCP_ECN_make_synack(struct request_sock *req, struct tcphdr *th)
>  {
>  	if (inet_rsk(req)->ecn_ok)
>  

What's this new TAB for?
