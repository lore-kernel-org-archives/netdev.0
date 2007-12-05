From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [UDP]: Avoid repeated counting of checksum errors
 due to peeking
Date: Wed, 05 Dec 2007 01:52:12 -0800 (PST)
Message-ID: <20071205.015212.243064142.davem@davemloft.net>
References: <20071204125844.GA2750@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58621
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751288AbXLEJwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 04:52:12 -0500
In-Reply-To: <20071204125844.GA2750@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 4 Dec 2007 23:58:44 +1100

> [UDP]: Avoid repeated counting of checksum errors due to peeking
> 
> Currently it is possible for two processes to peek on the same socket
> and end up incrementing the error counter twice for the same packet.
> 
> This patch fixes it by making skb_kill_datagram return whether it
> succeeded in unlinking the packet and only incrementing the counter
> if it did.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
