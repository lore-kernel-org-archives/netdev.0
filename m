From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch for 2.6.27? 4/6] drivers/net/mlx4/alloc.c needs mm.h
Date: Sat, 13 Sep 2008 15:13:23 -0400
Message-ID: <48CC10D3.3010704@garzik.org>
References: <200809052104.m85L47vw020360@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59944 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752660AbYIMTN0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:13:26 -0400
In-Reply-To: <200809052104.m85L47vw020360@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> sparc32 allmodconfig with linux-next:
> 
> drivers/net/mlx4/alloc.c: In function 'mlx4_buf_alloc':
> drivers/net/mlx4/alloc.c:164: error: 'PAGE_KERNEL' undeclared (first use in this function)
> drivers/net/mlx4/alloc.c:164: error: (Each undeclared identifier is reported only once
> drivers/net/mlx4/alloc.c:164: error: for each function it appears in.)
> 
> this is due to some header shuffle in linux-next.  I didn't look to see what
> it was.  I'd sugges that this patch be merged ahead of a linux-next merge to
> avoid bisection breaks.
> 
> We strictly only need asm/pgtable.h, but going direct to asm includes always
> seems grubby.
> 
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/mlx4/alloc.c |    1 +
>  1 file changed, 1 insertion(+)

applied


