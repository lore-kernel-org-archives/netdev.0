From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] xfrm6: Don't call icmpv6_send on local error
Date: Tue, 18 Oct 2011 23:53:26 -0400 (EDT)
Message-ID: <20111018.235326.728003889061782561.davem@davemloft.net>
References: <20111011114251.GH1830@secunet.com>
	<20111011114430.GJ1830@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32980 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753560Ab1JSDxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 23:53:32 -0400
In-Reply-To: <20111011114430.GJ1830@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 11 Oct 2011 13:44:30 +0200

> Calling icmpv6_send() on a local message size error leads to
> an incorrect update of the path mtu. So use xfrm6_local_rxpmtu()
> to notify about the pmtu if the IPV6_DONTFRAG socket option is
> set on an udp or raw socket, according RFC 3542 and use
> ipv6_local_error() otherwise.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied.
