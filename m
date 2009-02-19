From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Thu, 19 Feb 2009 21:29:17 +0800
Message-ID: <20090219132917.GA11137@gondor.apana.org.au>
References: <20090218135537.GF3600@mini-me.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Valdis.Kletnieks@vt.edu, arvidjaar@mail.ru,
	rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org
To: Theodore Tso <tytso@mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54720 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750851AbZBSNbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 08:31:34 -0500
Content-Disposition: inline
In-Reply-To: <20090218135537.GF3600@mini-me.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Theodore Tso <tytso@mit.edu> wrote:
> 
> I think I can pretty much guarantee that distro users will be
> clamoring for a quick and easy way to block ipv6, and it's in our
> interest to document the recomended way to block it that doesn't cause
> weird problems with bonding, etc.

We already have a way:

echo 0 > /proc/sys/net/ipv6/conf/all/disable_ipv6

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
