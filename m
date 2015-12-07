From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xfrm: take care of request sockets
Date: Mon, 07 Dec 2015 17:07:52 -0500 (EST)
Message-ID: <20151207.170752.1447114240818192828.davem@davemloft.net>
References: <20151130232733.GA27119@codemonkey.org.uk>
	<1448932931.25582.2.camel@edumazet-glaptop2.roam.corp.google.com>
	<1449507197.25029.73.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org,
	steffen.klassert@secunet.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51591 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755877AbbLGWHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 17:07:53 -0500
In-Reply-To: <1449507197.25029.73.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 07 Dec 2015 08:53:17 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> TCP SYNACK messages might now be attached to request sockets.
> 
> XFRM needs to get back to a listener socket.
> 
> Adds new helpers that might be used elsewhere :
> sk_to_full_sk() and sk_const_to_full_sk()
> 
> Note: We also need to add RCU protection for xfrm lookups,
> now TCP/DCCP have lockless listener processing. This will
> be addressed in separate patches.
> 
> Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
> Reported-by: Dave Jones <davej@codemonkey.org.uk>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
