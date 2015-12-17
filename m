From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: restore fastopen with no data in SYN packet
Date: Thu, 17 Dec 2015 15:38:26 -0500 (EST)
Message-ID: <20151217.153826.362691551404297472.davem@davemloft.net>
References: <1450302790.8474.101.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, viro@zeniv.linux.org.uk
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56756 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932449AbbLQUi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 15:38:28 -0500
In-Reply-To: <1450302790.8474.101.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Dec 2015 13:53:10 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Yuchung tracked a regression caused by commit 57be5bdad759 ("ip: convert
> tcp_sendmsg() to iov_iter primitives") for TCP Fast Open.
> 
> Some Fast Open users do not actually add any data in the SYN packet.
> 
> Fixes: 57be5bdad759 ("ip: convert tcp_sendmsg() to iov_iter primitives")
> Reported-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
