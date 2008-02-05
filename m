From: "Denis V. Lunev" <den@sw.ru>
Subject: Re: [PATCH] [IPV4]: Fix compiler error with CONFIG_PROC_FS=n
Date: Tue, 05 Feb 2008 22:57:38 +0300
Message-ID: <47A8BFB2.7070702@sw.ru>
References: <1202237034.9289.8.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Johann Felix Soden <johfel@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppp91-76-183-162.pppoe.mtu-net.ru ([91.76.183.162]:39444 "EHLO
	iris.sw.ru" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758010AbYBEUcl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 15:32:41 -0500
In-Reply-To: <1202237034.9289.8.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johann Felix Soden wrote:
> From: Johann Felix Soden <johfel@users.sourceforge.net>
> 
> Handle CONFIG_PROC_FS=n in net/ipv4/fib_frontend.c because:
> 
> net/ipv4/fib_frontend.c: In function 'fib_net_init':
> net/ipv4/fib_frontend.c:1032: error: implicit declaration of function 'fib_proc_init'
> net/ipv4/fib_frontend.c: In function 'fib_net_exit':
> net/ipv4/fib_frontend.c:1047: error: implicit declaration of function 'fib_proc_exit'
> 
> Signed-off-by: Johann Felix Soden <johfel@users.sourceforge.net>

Fix from Li Zefan is already commited.
(cc8274f50f2ad9a97a837451f63a0a3e65f7f490)
