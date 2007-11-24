From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] SO_NO_CHECK for IPv6
Date: Sat, 24 Nov 2007 14:00:41 +0800
Message-ID: <E1Ivo4H-0006Z2-00@gondolin.me.apana.org.au>
References: <MDEHLPKNGKAHNMBLJOLKIEFLIGAC.davids@webmaster.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davids@webmaster.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3120 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751112AbXKXGAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Nov 2007 01:00:52 -0500
In-Reply-To: <MDEHLPKNGKAHNMBLJOLKIEFLIGAC.davids@webmaster.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Schwartz <davids@webmaster.com> wrote:
> 
>> Regardless of whatever verifications your application is doing
>> on the data, it is not checksumming the ports and that's what
>> the pseudo-header is helping with.
> 
> So what? We are in the case where the data has already gotten to him. If it
> got to him in error, he'll reject it anyway. The receive checksum check will
> only reject packets that he would reject anyway. That makes it needless.

What if it goes to the wrong recipient who doesn't have the upper-
level checksums?

This is the whole point, IPv6 unlike IPv4 does not have IP header
checksums so the high-level needs to protect it by checksumming
the pseudo-header.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
