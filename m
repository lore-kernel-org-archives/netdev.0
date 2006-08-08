From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: airo: inconsistent {hardirq-on-W} -> {in-hardirq-W} usage.
Date: Tue, 08 Aug 2006 21:16:13 +1000
Message-ID: <E1GAPZF-0003w4-00@gondolin.me.apana.org.au>
References: <20060808094410.GA29313@ee.oulu.fi>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56338 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964849AbWHHLQR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 07:16:17 -0400
To: pp@ee.oulu.fi (Pekka Pietikainen)
In-Reply-To: <20060808094410.GA29313@ee.oulu.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pekka Pietikainen <pp@ee.oulu.fi> wrote:
> Only aironet lockdep related report I could find was 
> http://marc.theaimsgroup.com/?l=linux-netdev&m=115406279721287&w=2
> 
> this looks a bit different:
> 
> Linux version 2.6.17-1.2528.fc6 (brewbuilder@hs20-bc2-2.build.redhat.com) (gcc version 4.1.1 20060802 (Red Hat 4.1.1-14)) #1 SMP Sun Aug 6 01:43:42 EDT 2006

If you run the latest upstream kernel this warning will disappear
as different skb queues no have different lock keys.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
