From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink recvmsg() and MSG_TRUNC
Date: Wed, 07 Mar 2007 10:49:07 +1100
Message-ID: <E1HOjP1-0003NM-00@gondolin.me.apana.org.au>
References: <20070306.151953.112290310.davem@davemloft.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3045 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030728AbXCFXtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 18:49:11 -0500
In-Reply-To: <20070306.151953.112290310.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> 
> I guess one thing the user could do when it sees MSG_TRUNC
> is keep calling recvmsg() until the receive queue is emptied
> of packets, in order to get that pesky nlk->cb cleared to
> NULL, then resubmit.
> 
> But that's rediculous and complicated.
> 
> Any ideas?

Which netlink family generates (or needs to generate) unbounded
messages to user-space? Or indeed which ones generate messages
greater than 64K (or 4K for that matter)?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
