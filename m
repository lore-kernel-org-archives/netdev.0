From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] ipv4: Fix packet size calculation for raw IPsec
 packets in __ip_append_data
Date: Thu, 09 Jun 2011 14:50:08 -0700 (PDT)
Message-ID: <20110609.145008.460297815487707520.davem@davemloft.net>
References: <20110606064603.GB31505@secunet.com>
	<20110606064847.GD31505@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40630 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756275Ab1FIVuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 17:50:24 -0400
In-Reply-To: <20110606064847.GD31505@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 6 Jun 2011 08:48:47 +0200

> We assume that transhdrlen is positive on the first fragment
> which is wrong for raw packets. So we don't add exthdrlen to the
> packet size for raw packets. This leads to a reallocation on IPsec
> because we have not enough headroom on the skb to place the IPsec
> headers. This patch fixes this by adding exthdrlen to the packet
> size whenever the send queue of the socket is empty. This issue was
> introduced with git commit 1470ddf7 (inet: Remove explicit write
> references to sk/inet in ip_append_data)
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied, thanks.
