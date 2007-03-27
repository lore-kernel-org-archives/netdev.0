From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : inet_ehash_secret should be __read_mostly and
 set only once
Date: Tue, 27 Mar 2007 13:53:38 -0700 (PDT)
Message-ID: <20070327.135338.77404865.davem@davemloft.net>
References: <20070327121343.395a57e5.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41236
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934207AbXC0Uxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 16:53:39 -0400
In-Reply-To: <20070327121343.395a57e5.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 27 Mar 2007 12:13:43 +0200

> Hi David
> 
> Please find this patch against net-2.6.22
> 
> Thank you
> 
> [PATCH] NET : inet_ehash_secret should be __read_mostly and set only once
> 
> There is a very tiny probability that build_ehash_secret() is called at the same time by different CPUS.
> 
> Also, using __read_mostly is a must for inet_ehash_secret
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, but I left out this totally unrelated code formatting
change in your patch:

> @@ -684,7 +694,8 @@ int inet_sendmsg(struct kiocb *iocb, str
>  }
>  
>  
> -static ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset, size_t size, int flags)
> +static ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
> +	size_t size, int flags)
>  {
>  	struct sock *sk = sock->sk;
>  

Thanks!
