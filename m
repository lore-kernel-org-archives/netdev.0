From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ipv6: Allow sending packets through
 tunnels with wildcard endpoints
Date: Thu, 06 Nov 2014 14:19:35 -0500 (EST)
Message-ID: <20141106.141935.751338071351325786.davem@davemloft.net>
References: <20141105070248.GC6390@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262AbaKFTTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 14:19:40 -0500
In-Reply-To: <20141105070248.GC6390@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 5 Nov 2014 08:02:48 +0100

> Currently we need the IP6_TNL_F_CAP_XMIT capabiltiy to transmit
> packets through an ipv6 tunnel. This capability is set when the
> tunnel gets configured, based on the tunnel endpoint addresses.
> 
> On tunnels with wildcard tunnel endpoints, we need to do the
> capabiltiy checking on a per packet basis like it is done in
> the receive path.
> 
> This patch extends ip6_tnl_xmit_ctl() to take local and remote
> addresses as parameters to allow for per packet capabiltiy
> checking.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied.
