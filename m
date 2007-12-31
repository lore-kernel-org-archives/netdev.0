From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Fix transport-mode async resume on intput without
 netfilter
Date: Sun, 30 Dec 2007 21:11:04 -0800 (PST)
Message-ID: <20071230.211104.111830488.davem@davemloft.net>
References: <20071231003117.GA595@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48906
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751153AbXLaFLF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 00:11:05 -0500
In-Reply-To: <20071231003117.GA595@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 31 Dec 2007 11:31:18 +1100

> [IPSEC]: Fix transport-mode async resume on intput without netfilter
> 
> When netfilter is off the transport-mode async resumption doesn't work
> because we don't push back the IP header.  This patch fixes that by
> moving most of the code outside of ifdef NETFILTER since the only part
> that's not common is the short-circuit in the protocol handler.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
