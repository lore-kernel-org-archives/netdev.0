From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v2] ipv4: more compliant RFC 3168 support
Date: Mon, 16 May 2011 14:49:45 -0400 (EDT)
Message-ID: <20110516.144945.1973022094585295342.davem@davemloft.net>
References: <1305475310.3120.146.camel@edumazet-laptop>
	<1305566204.2898.49.camel@edumazet-laptop>
	<1305571057.2581.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: v13@v13.gr, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49964 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013Ab1EPStz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 14:49:55 -0400
In-Reply-To: <1305571057.2581.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 16 May 2011 20:37:37 +0200

> Commit 6623e3b24a5e (ipv4: IP defragmentation must be ECN aware) was an
> attempt to not lose "Congestion Experienced" (CE) indications when
> performing datagram defragmentation.
> 
> Stefanos Harhalakis raised the point that RFC 3168 requirements were not
> completely met by this commit.
> 
> In particular, we MUST detect invalid combinations and eventually drop
> illegal frames.
> 
> Reported-by: Stefanos Harhalakis <v13@v13.gr>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> v2 : Use a table instead of a switch()

Applied, thanks!
