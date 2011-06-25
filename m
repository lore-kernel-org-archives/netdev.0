From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: unintended ipv4 broadcast policy change
Date: Sat, 25 Jun 2011 08:27:24 +0800
Message-ID: <20110625002724.GA12880@gondor.apana.org.au>
References: <20110623170137.69054c83@s6510.ftrdhcpuser.net> <20110623.140821.674961342350404546.davem@davemloft.net> <20110624100121.63bbc93a@nehalam.ftrdhcpuser.net> <20110624.125406.600608999605842473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:39238 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066Ab1FYA1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 20:27:31 -0400
Content-Disposition: inline
In-Reply-To: <20110624.125406.600608999605842473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 24, 2011 at 12:54:06PM -0700, David Miller wrote:
> They must be because this is capturing ETH_P_ALL with type SOCK_PACKET
> which means receive all packets unconditionally.

sock_queue_rcv_skb calls sk_filter, strange but true :)
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
