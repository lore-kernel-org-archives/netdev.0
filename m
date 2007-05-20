From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: oops in net/ipv4/icmp.c:icmp_send() with icmp_errors_use_inbound_ifaddr (fwd)
Date: Sun, 20 May 2007 15:26:27 +1000
Message-ID: <E1Hpdw3-0006CY-00@gondolin.me.apana.org.au>
References: <4648B656.6030800@trash.net>
Cc: netdev@vger.kernel.org, jmorris@namei.org, Curtis@greenkey.net,
	davem@davemloft.net
To: kaber@trash.net (Patrick McHardy)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4038 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758601AbXETF0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 May 2007 01:26:47 -0400
In-Reply-To: <4648B656.6030800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> wrote:
> 
> This leaves the question what to do in the path after ip_output,
> when skb->dev points to the output device. We don't know the
> input device anymore, so there doesn't seem to be a way to make
> it do what the sysctl promises.

Perhaps we could change things so that the setting of skb->dev is
delayed until the packet has completely left the IP stack?  It'd
require a massive audit though of the IP stack though.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
