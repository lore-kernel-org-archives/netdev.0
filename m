From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/7] altera: Remove casts of pointer to same
 type
Date: Wed, 26 Mar 2014 15:47:30 -0400 (EDT)
Message-ID: <20140326.154730.1546138586026156236.davem@davemloft.net>
References: <cover.1395692043.git.joe@perches.com>
	<b3437e88a3d02c3ee8b9378b5801471a38cf24c5.1395692043.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nios2-dev@lists.rocketboards.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b3437e88a3d02c3ee8b9378b5801471a38cf24c5.1395692043.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 24 Mar 2014 13:15:34 -0700

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
