From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: speedup SIOCINQ ioctl
Date: Mon, 22 Oct 2012 15:11:42 -0400 (EDT)
Message-ID: <20121022.151142.1511773969665363953.davem@davemloft.net>
References: <1350886016.8609.266.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32824 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203Ab2JVTLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 15:11:43 -0400
In-Reply-To: <1350886016.8609.266.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 22 Oct 2012 08:06:56 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> SIOCINQ can use the lock_sock_fast() version to avoid double acquisition
> of socket lock.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
