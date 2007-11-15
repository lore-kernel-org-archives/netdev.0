From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: network interface state
Date: Thu, 15 Nov 2007 10:11:35 +0800
Message-ID: <E1IsUCd-0005f4-00@gondolin.me.apana.org.au>
References: <20071114.162201.174150647.davem@davemloft.net>
Cc: drepper@redhat.com, netdev@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4857 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754553AbXKOCLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 21:11:45 -0500
In-Reply-To: <20071114.162201.174150647.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
>
>> BTW, is it possible to send both these requests out before starting to
>> read the results?  This would reduce the amount of code quite a bit.
> 
> Unfortunately, that won't work.  Like datagram protocols,
> netlink assumes one message per sendmsg() call.

Actually netlink packets come with headers so we do allow chaining.
See netlink_rcv_skb for details.

We don't make use of that on recvmsg() though although theoretically
user-space is supposed to be ready to handle that too.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
