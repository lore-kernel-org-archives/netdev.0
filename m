From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mv643xx_eth: Neaten
 mv643xx_eth_program_multicast_filter
Date: Tue, 15 Sep 2015 12:49:32 -0700 (PDT)
Message-ID: <20150915.124932.2021612592296257940.davem@davemloft.net>
References: <1441787886-7214-1-git-send-email-linux@rasmusvillemoes.dk>
	<20150909.170620.88355755480464840.davem@davemloft.net>
	<1441845656.17219.110.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@rasmusvillemoes.dk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sebastian.hesselbarth@gmail.com
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441845656.17219.110.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 09 Sep 2015 17:40:56 -0700

> The code around the allocation and loops are a bit obfuscated.
> 
> Neaten it by using:
> 
> o kcalloc with decimal count and sizeof(u32)
> o Decimal loop indexing and i++ not i += 4
> o A promiscuous block using a similar style
>   to the multicast block
> o Remove unnecessary variables
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
