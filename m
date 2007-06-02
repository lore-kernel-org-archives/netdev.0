From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: raw sockets ignore IP_HDRINCL data
Date: Sat, 02 Jun 2007 21:07:17 +1000
Message-ID: <E1HuRS1-0002aE-00@gondolin.me.apana.org.au>
References: <1180676187.5956.52.camel@localhost>
Cc: netdev@vger.kernel.org
To: mick_mccreath@au.securecomputing.com (Mick McCreath)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4771 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755241AbXFBLHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2007 07:07:25 -0400
In-Reply-To: <1180676187.5956.52.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mick McCreath <mick_mccreath@au.securecomputing.com> wrote:
> 
> When I run traceroute -i eth1 5.4.3.2, the UDP packets are routed out
> eth2.
> 
> Has anybody seen this behaviour with traceroute??

Well the version of traceroute here actually does a BINDTODEVICE so it
will go out of the right interface.  It also binds the socket so that
it gets the right source address.

I can see your point of view that it would be nice if the kernel read
the IP headers in making its routing decision.  However, the current
behaviour has been there forever and it's unclear what we might break
by changing it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
