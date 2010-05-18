From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/4] ipv6: Replace inet6_ifaddr->dead with state
Date: Tue, 18 May 2010 10:23:34 -0700
Message-ID: <20100518102334.70b6c0b4@nehalam>
References: <20100518110243.GA7750@gondor.apana.org.au>
	<E1OEKax-00022W-6K@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jbohac@suse.cz,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48755 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751568Ab0ERRXk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 May 2010 13:23:40 -0400
In-Reply-To: <E1OEKax-00022W-6K@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 May 2010 21:04:19 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

>  
> +enum {
> +	INET6_IFADDR_STATE_DAD,
> +	INET6_IFADDR_STATE_POSTDAD,
> +	INET6_IFADDR_STATE_UP,
> +	INET6_IFADDR_STATE_DEAD,
> +};
> +
>  #ifdef __KERNEL__

Does this really need to be visible to user applications?

-- 
