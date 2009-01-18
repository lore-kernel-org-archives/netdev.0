From: David Miller <davem@davemloft.net>
Subject: Re: [1/3] gro: Fix handling of complete checksums in IPv6
Date: Sat, 17 Jan 2009 23:04:23 -0800 (PST)
Message-ID: <20090117.230423.112049696.davem@davemloft.net>
References: <20090118054616.GA24899@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37546
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755450AbZARHEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 02:04:21 -0500
In-Reply-To: <20090118054616.GA24899@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 18 Jan 2009 16:46:16 +1100

> gro: Fix handling of complete checksums in IPv6
> 
> We need to perform skb_postpull_rcsum after pulling the IPv6
> header in order to maintain the correctness of the complete
> checksum.
> 
> This patch also adds a missing iph reload after pulling.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
