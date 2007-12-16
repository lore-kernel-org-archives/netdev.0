From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 9543] New: RTNL: assertion failed at net/ipv6/addrconf.c (2164)/RTNL: assertion failed at net/ipv4/devinet.c (1055)
Date: Sun, 16 Dec 2007 10:27:32 +0800
Message-ID: <E1J3jE4-0000FE-00@gondolin.me.apana.org.au>
References: <bdfc5d6e0712150709k2dc0a845n84c494c519298f8d@mail.gmail.com>
Cc: herbert@gondor.apana.org.au, olel@ans.pl, fubar@us.ibm.com,
	akpm@linux-foundation.org, bugme-daemon@bugzilla.kernel.org,
	shemminger@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: andy@greyhouse.net (Andy Gospodarek)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2164 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754647AbXLPC2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 21:28:30 -0500
In-Reply-To: <bdfc5d6e0712150709k2dc0a845n84c494c519298f8d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:
>
> I agree with you completely, Herbet, which is why I was surprised that
> my first apparently did not resolve the issue.  I felt it should
> have....

Did it change all occurrences of read_lock(&bond->lock) to
read_lock_bh? If so I better look at the lockdep output again.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
