From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 2/3] ipv4: Add a socket release callback for
 datagram sockets
Date: Fri, 18 Jan 2013 14:39:04 -0500 (EST)
Message-ID: <20130118.143904.128171042420419260.davem@davemloft.net>
References: <50F3C153.9030204@oktetlabs.ru>
	<20130118081145.GB24987@secunet.com>
	<20130118081514.GD24987@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yurij.Plotnikov@oktetlabs.ru, bhutchings@solarflare.com,
	netdev@vger.kernel.org, Alexandra.Kossovsky@oktetlabs.ru
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38868 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab3ARTjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 14:39:06 -0500
In-Reply-To: <20130118081514.GD24987@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 18 Jan 2013 09:15:14 +0100

> This implements a socket release callback function to check
> if the socket cached route got invalid during the time
> we owned the socket. The function is used from udp, raw
> and ping sockets.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Ok.
