From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: Convert function pointer arrays and uses to const
Date: Wed, 10 Dec 2014 15:33:36 -0500 (EST)
Message-ID: <20141210.153336.869064783048125658.davem@davemloft.net>
References: <1418236138.18092.13.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418236138.18092.13.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 10 Dec 2014 10:28:58 -0800

> Making things const is a good thing.
> 
> (x86-64 defconfig with all irda)
> $ size net/irda/built-in.o*
>    text	   data	    bss	    dec	    hex	filename
>  109276	   1868	    244	 111388	  1b31c	net/irda/built-in.o.new
>  108828	   2316	    244	 111388	  1b31c	net/irda/built-in.o.old
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
