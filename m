From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net/core: remove address space warnings on
 verify_iovec()
Date: Thu, 09 Sep 2010 15:02:58 -0700 (PDT)
Message-ID: <20100909.150258.260099563.davem@davemloft.net>
References: <1283953728-15302-1-git-send-email-namhyung@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: namhyung@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34391
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753455Ab0IIWCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 18:02:40 -0400
In-Reply-To: <1283953728-15302-1-git-send-email-namhyung@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Namhyung Kim <namhyung@gmail.com>
Date: Wed,  8 Sep 2010 22:48:47 +0900

> move_addr_to_kernel() and copy_from_user() requires their argument
> as __user pointer but were missing proper markups. Add it.
> This removes following warnings from sparse.
> 
>  net/core/iovec.c:44:52: warning: incorrect type in argument 1 (different address spaces)
>  net/core/iovec.c:44:52:    expected void [noderef] <asn:1>*uaddr
>  net/core/iovec.c:44:52:    got void *msg_name
>  net/core/iovec.c:55:34: warning: incorrect type in argument 2 (different address spaces)
>  net/core/iovec.c:55:34:    expected void const [noderef] <asn:1>*from
>  net/core/iovec.c:55:34:    got struct iovec *msg_iov
> 
> Signed-off-by: Namhyung Kim <namhyung@gmail.com>

Applied.
