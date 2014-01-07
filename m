From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-gre-gro: Add GRE support to the GRO stack
Date: Tue, 07 Jan 2014 16:22:51 -0500 (EST)
Message-ID: <20140107.162251.778631453084913688.davem@davemloft.net>
References: <1389118999-16359-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, herbert@gondor.apana.org.au,
	ogerlitz@mellanox.com, netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44824 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753165AbaAGVWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 16:22:52 -0500
In-Reply-To: <1389118999-16359-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "H.K. Jerry Chu" <hkchu@google.com>
Date: Tue,  7 Jan 2014 10:23:19 -0800

> From: Jerry Chu <hkchu@google.com>
> 
> This patch built on top of Commit 299603e8370a93dd5d8e8d800f0dff1ce2c53d36
> ("net-gro: Prepare GRO stack for the upcoming tunneling support") to add
> the support of the standard GRE (RFC1701/RFC2784/RFC2890) to the GRO
> stack. It also serves as an example for supporting other encapsulation
> protocols in the GRO stack in the future.
 ...
> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
> Reviewed-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.

We really need to talk about what we want to happen with these GRO
offloads when GRE is not configured into the kernel.

Right now, the GRO offloads simply won't happen.
