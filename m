From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net-2.6.22] [IPV4]: Fix build without procfs.
Date: Wed, 25 Apr 2007 12:54:49 +1000
Message-ID: <20070425025449.GA1513@gondor.apana.org.au>
References: <20070425.002048.109830535.yoshfuji@linux-ipv6.org> <E1HgXMD-0000LK-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1645 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1161831AbXDYCyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 22:54:54 -0400
Content-Disposition: inline
In-Reply-To: <E1HgXMD-0000LK-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 25, 2007 at 12:35:49PM +1000, Herbert Xu wrote:
> 
> [IPV4]: Move snmp_mib_init out of proc.c
> 
> The function snmp_mib_init has nothing to do with proc so this patch
> moves it out of proc.c and to the only place that uses it.  Right now
> there is only one user so I'ved made it static too.

Please ignore that patch.  I'm working on a better one that
eliminates the duplicate code between IPv4 and IPv6 too.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
