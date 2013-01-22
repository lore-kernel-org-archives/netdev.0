From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Fix route refcount on pmtu discovery
Date: Tue, 22 Jan 2013 14:23:52 -0500 (EST)
Message-ID: <20130122.142352.297304738389100208.davem@davemloft.net>
References: <20130122100128.GD9147@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55875 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263Ab3AVTXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 14:23:54 -0500
In-Reply-To: <20130122100128.GD9147@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 22 Jan 2013 11:01:28 +0100

> git commit 9cb3a50c (ipv4: Invalidate the socket cached route on
> pmtu events if possible) introduced a refcount problem. We don't
> get a refcount on the route if we get it from__sk_dst_get(), but
> we need one if we want to reuse this route because __sk_dst_set()
> releases the refcount of the old route. This patch adds proper
> refcount handling for that case. We introduce a 'new' flag to
> indicate that we are going to use a new route and we release the
> old route only if we replace it by a new one.
> 
> Reported-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied, thanks.
