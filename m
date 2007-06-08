From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Multicast and hardware checksum
Date: Fri, 08 Jun 2007 16:20:02 +1000
Message-ID: <E1HwXpK-0005RC-00@gondolin.me.apana.org.au>
References: <466887AA.800@ev-en.org>
Cc: netdev@vger.kernel.org
To: baruch@ev-en.org (Baruch Even)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2288 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754903AbXFHGUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 02:20:14 -0400
In-Reply-To: <466887AA.800@ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Baruch Even <baruch@ev-en.org> wrote:
> 
> I have a machine on which I have an applications that sends multicast 
> through eth interface with hardware tx checksum enabled. On the same 
> machine I have mrouted running that routes the multicast traffic to a 
> set of ppp interfaces. The packets that are received by the client have 
> their checksum fixed on some number which is incorrect. If I disable tx 
> checksum on the eth device the packets arrive with the proper checksum.

Where is the client? On the same machine or behind a PPP link?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
