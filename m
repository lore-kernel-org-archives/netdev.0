From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 6/20] drivers/net: Use kzalloc
Date: Thu, 13 May 2010 22:29:37 +0200
Message-ID: <20100513202937.GA1795@mail.wantstofly.org>
References: <Pine.LNX.4.64.1005132200050.6282@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:45748 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759035Ab0EMU3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 16:29:42 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.1005132200050.6282@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 13, 2010 at 10:00:22PM +0200, Julia Lawall wrote:

> From: Julia Lawall <julia@diku.dk>
> 
> Use kzalloc rather than the combination of kmalloc and memset.
> 
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @@
> expression x,size,flags;
> statement S;
> @@
> 
> -x = kmalloc(size,flags);
> +x = kzalloc(size,flags);
>  if (x == NULL) S
> -memset(x, 0, size);
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>

Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>
