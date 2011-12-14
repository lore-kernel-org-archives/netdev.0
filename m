From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inet: remove rcu protection on tw_net
Date: Wed, 14 Dec 2011 13:35:28 -0500 (EST)
Message-ID: <20111214.133528.1525977086673753829.davem@davemloft.net>
References: <1323874713.2334.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60221 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757371Ab1LNSfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 13:35:33 -0500
In-Reply-To: <1323874713.2334.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 14 Dec 2011 15:58:33 +0100

> commit b099ce2602d806 (net: Batch inet_twsk_purge) added rcu protection
> on tw_net for no obvious reason.
> 
> struct net are refcounted anyway since timewait sockets escape from rcu
> protected sections. tw_net stay valid for the whole timwait lifetime.
> 
> This also removes a lot of sparse errors.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>

Applied.
