From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] xfrm: add rcu grace period in
 xfrm_policy_destroy()
Date: Tue, 08 Dec 2015 22:58:29 -0500 (EST)
Message-ID: <20151208.225829.122422778076120961.davem@davemloft.net>
References: <1449588122-13941-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49831 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083AbbLID6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 22:58:31 -0500
In-Reply-To: <1449588122-13941-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue,  8 Dec 2015 07:22:01 -0800

> We will soon switch sk->sk_policy[] to RCU protection,
> as SYNACK packets are sent while listener socket is not locked.
> 
> This patch simply adds RCU grace period before struct xfrm_policy
> freeing, and the corresponding rcu_head in struct xfrm_policy.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I'll give Steffen an opportunity to review these two patches.
