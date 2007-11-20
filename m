From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] LRO ack aggregation
Date: Tue, 20 Nov 2007 14:09:18 +0800
Message-ID: <E1IuMIQ-0003gc-00@gondolin.me.apana.org.au>
References: <20071119.210919.177660672.davem@davemloft.net>
Cc: gallatin@myri.com, netdev@vger.kernel.org, ossthema@de.ibm.com
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3058 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756238AbXKTGJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:09:34 -0500
In-Reply-To: <20071119.210919.177660672.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
>
> Fundamentally, I really don't like this change, it batches to the
> point where it begins to erode the natural ACK clocking of TCP, and I
> therefore am very likely to revert it before merging to Linus.

Perhaps make it a tunable that defaults to off?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
