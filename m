From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: UDP checksum broken since 2.6.18?
Date: Wed, 23 May 2007 20:01:12 +1000
Message-ID: <E1Hqnea-0006Af-00@gondolin.me.apana.org.au>
References: <46537DCA.7060603@openpma.org>
Cc: shemminger@linux-foundation.org, pg@futureware.at,
	netdev@vger.kernel.org
To: dm8tbr@openpma.org ("Thomas B. R??cker")
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3185 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757465AbXEWKBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 06:01:50 -0400
In-Reply-To: <46537DCA.7060603@openpma.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Thomas B. R??cker" <dm8tbr@openpma.org> wrote:
> Stephen Hemminger wrote:
>> The packet passed to packet capture programs may not have a valid checksum
>> if you have checksum offload configured on the device.  What kind of hardware
>> do you have on sender and receiver? 
> The c-snippet uses 127.x.x.x --> loopback

We never compute the complete checksum for loopback so that explains
the bogus checksum.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
