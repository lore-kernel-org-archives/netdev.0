From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: arp_hash
Date: Mon, 23 Mar 2015 10:42:18 +1100
Message-ID: <20150322234218.GA9243@gondor.apana.org.au>
References: <20150322114204.GA5010@gondor.apana.org.au>
 <20150322.125458.2054837991708165397.davem@davemloft.net>
 <20150322213408.GC7925@gondor.apana.org.au>
 <20150322.185714.1793567801322787489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roland@purestorage.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:34940 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926AbbCVXmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 19:42:22 -0400
Content-Disposition: inline
In-Reply-To: <20150322.185714.1793567801322787489.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 22, 2015 at 06:57:14PM -0400, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Mon, 23 Mar 2015 08:34:08 +1100
> 
> > So what scales we are talking about, twice, three times? Have you
> > considered more modern hashes such as SipHash or SpookyHash
> > (successor to jhash/lookup3 and supposedly faster)?
> 
> I want it to be one cycle or two.
> 
> Every single transmitted packet hits this hash demux.

For hosts can we cache this? For routers I guess this is just
the mummified remains of the route cache :)

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
