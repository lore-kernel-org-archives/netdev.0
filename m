From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Is it valid to add a macvlan virtual interface to a bridge? If so, there seems to be a bug with it.
Date: Thu, 18 Dec 2008 14:44:07 +1100
Message-ID: <E1LD9nz-0007sR-OP@gondolin.me.apana.org.au>
References: <4937D494.8080202@trash.net>
Cc: ipng@69706e6720323030352d30312d31340a.nosense.org,
	netdev@vger.kernel.org
To: kaber@trash.net (Patrick McHardy)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33229 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751257AbYLRDoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 22:44:20 -0500
In-Reply-To: <4937D494.8080202@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> wrote:
> 
>> I've had a look at the dev.c file in 2.6.27, and my very naive guess
>> is that as the handle_bridge() call is before the handle_macvlan() call,
>> because the incoming real physical interface is not part of the bridge,
>> the incoming unicast packet is being dropped, before the macvlan code
>> gets a look at it.
> 
> Yes, that seems correct.

Would it be possible to implement promiscuous mode for macvlans by
simply keeping a separate list of macvlan devices in promiscuous
mode and sending all inbound packets to them?

This should make bridging work, right?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
