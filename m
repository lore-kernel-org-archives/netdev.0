From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 19/43] drivers/net/hamradio: fix warning: format not a
 string literal and no ...
Date: Tue, 17 Feb 2009 17:27:49 -0800 (PST)
Message-ID: <20090217.172749.224722175.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214213243.24377.94508.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49810
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756230AbZBRB2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 20:28:05 -0500
In-Reply-To: <20090214213243.24377.94508.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:33:21 +0100

> Impact: Use 'static const char[]' instead of 'static char[]' and while
> being at it fix an issue in 'mkiss_init_driver', where in case of an
> error the status code was not passed to printk.
> 
> Fix this warnings:
>   drivers/net/hamradio/6pack.c: In function 'sixpack_init_driver':
>   drivers/net/hamradio/6pack.c:802: warning: format not a string literal and no format arguments
>   drivers/net/hamradio/bpqether.c: In function 'bpq_init_driver':
>   drivers/net/hamradio/bpqether.c:609: warning: format not a string literal and no format arguments
>   drivers/net/hamradio/mkiss.c: In function 'mkiss_init_driver':
>   drivers/net/hamradio/mkiss.c:988: warning: format not a string literal and no format arguments
>   drivers/net/hamradio/mkiss.c:991: warning: format not a string literal and no format arguments
>   drivers/net/hamradio/scc.c: In function 'scc_init_driver':
>   drivers/net/hamradio/scc.c:2109: warning: format not a string literal and no format arguments
>   drivers/net/hamradio/yam.c: In function 'yam_init_driver':
>   drivers/net/hamradio/yam.c:1094: warning: format not a string literal and no format arguments
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
