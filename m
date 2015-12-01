From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] net: rename SOCK_ASYNC_NOSPACE and
 SOCK_ASYNC_WAITDATA
Date: Tue, 01 Dec 2015 15:45:21 -0500 (EST)
Message-ID: <20151201.154521.1008806049047479732.davem@davemloft.net>
References: <1448856191-31435-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com,
	hannes@stressinduktion.org, edumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56935 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756284AbbLAUpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 15:45:24 -0500
In-Reply-To: <1448856191-31435-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Sun, 29 Nov 2015 20:03:10 -0800

> This patch is a cleanup to make following patch easier to
> review.
> 
> Goal is to move SOCK_ASYNC_NOSPACE and SOCK_ASYNC_WAITDATA
> from (struct socket)->flags to a (struct socket_wq)->flags
> to benefit from RCU protection in sock_wake_async()
> 
> To ease backports, we rename both constants.
> 
> Two new helpers, sk_set_bit(int nr, struct sock *sk)
> and sk_clear_bit(int net, struct sock *sk) are added so that
> following patch can change their implementation.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
