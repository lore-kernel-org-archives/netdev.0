From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/1] Return EINVAL if the user provides a return data
	structure for getsockname that is too small to hold the PF_
	address.  This introduces a new error code but this should be OK as
	the error is real and would otherwise corrupt the
	user-application's stack, i.e., it results in trouble no matter
	what.  I do not do a partial copy of the sockaddr structure because
	it does not make very much sense to retrieve only part of the
	socket address (e.g., ip + af_family).
Date: Fri, 30 Jan 2009 17:20:09 +1100
Message-ID: <20090130062009.GA4625@gondor.apana.org.au>
References: <20090126163452.85EAF54A11@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: John Reumann <reumann.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45667 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751092AbZA3GUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 01:20:14 -0500
Content-Disposition: inline
In-Reply-To: <20090126163452.85EAF54A11@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Reumann <reumann.linux@gmail.com> wrote:
> ---
> net/ipv4/af_inet.c  |    7 +++++--
> net/ipv6/af_inet6.c |    3 +++
> 2 files changed, 8 insertions(+), 2 deletions(-)

Why are you resending this patch with no real changes? We had
already vetoed it in its current form.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
