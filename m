From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] chelsio: Remove addressof casts to same type
Date: Wed, 26 Mar 2014 15:46:48 -0400 (EDT)
Message-ID: <20140326.154648.2160205796112896190.davem@davemloft.net>
References: <1395683112.13968.59.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dm@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395683112.13968.59.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 24 Mar 2014 10:45:12 -0700

> Using addressof then casting to the original type is pointless,
> so remove these unnecessary casts.
> 
> Done via coccinelle script:
> 
> $ cat typecast.cocci 
> @@
> type T;
> T foo;
> @@
> 
> -	(T *)&foo
> +	&foo
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
