From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipsec tunnel asymmetrical mtu
Date: Tue, 11 Jul 2006 21:54:52 +1000
Message-ID: <20060711115452.GB11396@gondor.apana.org.au>
References: <20060711064232.GA1490@gondor.apana.org.au> <BAY103-F97F4BC613EFB6C6BEB70EB2680@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41234 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751000AbWGKLyz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 07:54:55 -0400
To: Marco Berizzi <pupilla@hotmail.com>
Content-Disposition: inline
In-Reply-To: <BAY103-F97F4BC613EFB6C6BEB70EB2680@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 11, 2006 at 12:32:45PM +0200, Marco Berizzi wrote:
> Running this on mimosa 'mitigates' the problem:
> 
> ip addr add 172.29.128.1/28 dev eth2
> 
> Connections are pretty slow but they aren't
> reseted anymore.

Hmm, I thought 172.29.128.1 was already a local address? What does

ip addr

show?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
