From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Sun, 16 Dec 2007 15:13:30 +0800
Message-ID: <20071216071330.GA2556@gondor.apana.org.au>
References: <20071215061021.GA26247@gondor.apana.org.au> <20071215024810.20b8a5ae.akpm@linux-foundation.org> <20071215131016.GA28705@gondor.apana.org.au> <20071215.214429.121871076.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3435 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753629AbXLPHNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 02:13:43 -0500
Content-Disposition: inline
In-Reply-To: <20071215.214429.121871076.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 15, 2007 at 09:44:29PM -0800, David Miller wrote:
>
> Such situations (ASSERT_RTNL() in atomic context) have always
> been bugs though, and that continues to be true and I think
> the check should be added somehow.

OK once I've fixed the set_multicast path I'll do an audit of
the existing ASSERT_RTNL users and then add the might_sleep
check.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
