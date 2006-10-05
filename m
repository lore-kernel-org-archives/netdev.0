From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Disable addrconf on ~multicast interfaces?
Date: Thu, 05 Oct 2006 16:35:49 +1000
Message-ID: <E1GVMph-0005Do-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.64.0610050907160.22625@netcore.fi>
Cc: herbert@gondor.apana.org.au, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:6916 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751164AbWJEGfz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 02:35:55 -0400
To: pekkas@netcore.fi (Pekka Savola)
In-Reply-To: <Pine.LNX.4.64.0610050907160.22625@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pekka Savola <pekkas@netcore.fi> wrote:
> On Thu, 5 Oct 2006, Herbert Xu wrote:
>> Are there any non-multicast interfaces that require addrconf?
>> In other words, what does the following patch break :)
> 
> Point-to-point (or NOARP) interfaces such as tunnels.   I'm not sure 
> what are the right flags to check..

Tunnels shouldn't even get into that function so they aren't
affected.  Are there any Ethernet-like interfaces which do not
set IFF_MULTICAST yet still require addrconf?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
