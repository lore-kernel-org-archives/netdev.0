From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] ipv4: Fix packet size calculation in
 __ip_append_data
Date: Mon, 27 Jun 2011 20:39:48 -0700 (PDT)
Message-ID: <20110627.203948.831737132014461369.davem@davemloft.net>
References: <20110622110437.GG6489@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756448Ab1F1Dj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 23:39:58 -0400
In-Reply-To: <20110622110437.GG6489@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 22 Jun 2011 13:04:37 +0200

> Git commit 59104f06 (ip: take care of last fragment in ip_append_data)
> added a check to see if we exceed the mtu when we add trailer_len.
> However, the mtu is already subtracted by the trailer length when the
> xfrm transfomation bundles are set up. So IPsec packets with mtu
> size get fragmented, or if the DF bit is set the packets will not
> be send even though they match the mtu perfectly fine. This patch
> actually reverts commit 59104f06.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied.
