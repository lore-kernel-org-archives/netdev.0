From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: disallow bind() to reuse addr/port
Date: Tue, 11 Jan 2011 14:03:36 -0800 (PST)
Message-ID: <20110111.140336.128591591.davem@davemloft.net>
References: <1294140172.3579.81.camel@edumazet-laptop>
	<AANLkTimuNM7vmeR89WKXtrUbJO1Wt1ivp9y=bQvtWg0j@mail.gmail.com>
	<1294744462.2927.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel.baluta@gmail.com, gasparch@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43163
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752112Ab1AKWDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 17:03:04 -0500
In-Reply-To: <1294744462.2927.53.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 11 Jan 2011 12:14:22 +0100

> [PATCH] tcp: disallow bind() to reuse addr/port
> 
> inet_csk_bind_conflict() logic currently disallows a bind() if
> it finds a friend socket (a socket bound on same address/port)
> satisfying a set of conditions :
> 
> 1) Current (to be bound) socket doesnt have sk_reuse set
> OR
> 2) other socket doesnt have sk_reuse set
> OR
> 3) other socket is in LISTEN state
> 
> We should add the CLOSE state in the 3) condition, in order to avoid two
> REUSEADDR sockets in CLOSE state with same local address/port, since
> this can deny further operations.
> 
> Note : a prior patch tried to address the problem in a different (and
> buggy) way. (commit fda48a0d7a8412ced tcp: bind() fix when many ports
> are bound).
> 
> Reported-by: Gaspar Chilingarov <gasparch@gmail.com>
> Reported-by: Daniel Baluta <daniel.baluta@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
