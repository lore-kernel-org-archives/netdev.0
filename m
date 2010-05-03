From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Sun, 02 May 2010 19:37:56 -0700 (PDT)
Message-ID: <20100502.193756.106812290.davem@davemloft.net>
References: <20100503120847.e9328e75.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	yjwei@cn.fujitsu.com
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53155
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752252Ab0ECChu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 22:37:50 -0400
In-Reply-To: <20100503120847.e9328e75.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 3 May 2010 12:08:47 +1000

> After merging the net tree, today's linux-next build (x86_64
> allmodconfig) failed like this:
> 
> net/sctp/socket.c: In function 'sctp_data_ready':
> net/sctp/socket.c:6191: error: implicit declaration of function 'sk_has_sleeper'
> net/sctp/socket.c:6192: error: 'struct sock' has no member named 'sk_sleep'
> 
> Caused by commit 43815482370c510c569fd18edb57afcb0fa8cab6 ("net:
> sock_def_readable() and friends RCU conversion") interacting with commit
> 561b1733a465cf9677356b40c27653dd45f1ac56 ("sctp: avoid irq lock inversion
> while call sk->sk_data_ready()") which entered Linus' tree on April 29.
> 
> I have used the net tree from next-20100430 for today.

Thanks Stephen, I'll do a merge of net-2.6 into net-next-2.6 and fix
the build for you.
