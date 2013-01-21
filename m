From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4: Add a socket release callback for datagram
 sockets
Date: Mon, 21 Jan 2013 14:18:14 -0500 (EST)
Message-ID: <20130121.141814.1782262806382665066.davem@davemloft.net>
References: <20130121115911.GE30530@secunet.com>
	<20130121120003.GF30530@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yurij.Plotnikov@oktetlabs.ru, ja@ssi.bg, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41347 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755640Ab3AUTSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 14:18:16 -0500
In-Reply-To: <20130121120003.GF30530@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 21 Jan 2013 13:00:03 +0100

> This implements a socket release callback function to check
> if the socket cached route got invalid during the time
> we owned the socket. The function is used from udp, raw
> and ping sockets.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied.
