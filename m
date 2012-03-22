From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Fix possible overrun and simplify interrupt
 name field creation
Date: Wed, 21 Mar 2012 22:34:57 -0400 (EDT)
Message-ID: <20120321.223457.641438956547942596.davem@davemloft.net>
References: <17d93e9eb16cbad75b20cdbcaf38f268260d6fd5.1332010469.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sandeep.kumar@freescale.com
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <17d93e9eb16cbad75b20cdbcaf38f268260d6fd5.1332010469.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sat, 17 Mar 2012 12:05:38 -0700

> Space allocated for int_name_<foo> is unsufficient for
> maximal device name, expand it.
> 
> Code to create int_name_<foo> is obscure, simplify it
> by using sprintf.
> 
> Found by looking for unnecessary \ line continuations.
> Uncompiled, untested.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Can a gianfar expert please review and test this patch?

Thanks.
