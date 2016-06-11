From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4 net-next] sctp: sctp should change socket state when
 shutdown is received
Date: Fri, 10 Jun 2016 23:21:45 -0700 (PDT)
Message-ID: <20160610.232145.1944529062698358389.davem@davemloft.net>
References: <d964561c0d409848ea5724615c910e6d2ce53557.1465483698.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com,
	daniel@iogearbox.net, eric.dumazet@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35194 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbcFKGVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 02:21:48 -0400
In-Reply-To: <d964561c0d409848ea5724615c910e6d2ce53557.1465483698.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu,  9 Jun 2016 22:48:18 +0800

> Now sctp doesn't change socket state upon shutdown reception. It changes
> just the assoc state, even though it's a TCP-style socket.
> 
> For some cases, if we really need to check sk->sk_state, it's necessary to
> fix this issue, at least when we use ss or netstat to dump, we can get a
> more exact information.
> 
> As an improvement, we will change sk->sk_state when we change asoc->state
> to SHUTDOWN_RECEIVED, and also do it in sctp_shutdown to keep consistent
> with sctp_close.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
