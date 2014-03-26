From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/7] alx: Remove casts of pointer to same type
Date: Wed, 26 Mar 2014 15:47:37 -0400 (EDT)
Message-ID: <20140326.154737.1717367560265062054.davem@davemloft.net>
References: <cover.1395692043.git.joe@perches.com>
	<b8c7eec08a896af664e5ef18d1278504f450cfee.1395692043.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b8c7eec08a896af664e5ef18d1278504f450cfee.1395692043.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 24 Mar 2014 13:15:35 -0700

> Casting a pointer to a pointer of the same type is pointless,
> so remove these unnecessary casts.
> 
> Done via coccinelle script:
> 
> $ cat typecast_2.cocci
> @@
> type T;
> T *foo;
> @@
> 
> -	(T *)foo
> +	foo
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
