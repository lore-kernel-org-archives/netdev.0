From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] net/*: use SLAB_PANIC
Date: Mon, 28 Aug 2006 10:36:51 +0100
Message-ID: <20060828093651.GA31341@infradead.org>
References: <20060826230841.GA5204@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:65500 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S932477AbWH1JhM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 05:37:12 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
Content-Disposition: inline
In-Reply-To: <20060826230841.GA5204@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 27, 2006 at 03:08:41AM +0400, Alexey Dobriyan wrote:
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  Forgive me reformatting, in some cases making it fit in 80 columns was hard.
> 
>  net/core/flow.c        |    6 +-----
>  net/core/neighbour.c   |   12 ++++--------
>  net/core/skbuff.c      |    9 ++-------
>  net/decnet/dn_route.c  |   11 +++--------
>  net/ipv4/inetpeer.c    |    5 +----
>  net/ipv4/ipmr.c        |    5 +----
>  net/ipv4/route.c       |   10 +++-------
>  net/ipv4/tcp.c         |    4 +---
>  net/ipv6/ip6_fib.c     |    4 +---
>  net/ipv6/route.c       |   10 +++-------

ipv6 can be modular, so panicing on a initialization failure is wrong.

