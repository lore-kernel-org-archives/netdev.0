From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Fri, 14 Dec 2007 20:46:47 +0800
Message-ID: <20071214124647.GB17898@gondor.apana.org.au>
References: <200712140002.lBE02aGO025491@imap1.linux-foundation.org> <E1J35d6-00041l-00@gondolin.me.apana.org.au> <20071214002209.ac748206.akpm@linux-foundation.org> <1197635860.16079.51.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2763 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1761816AbXLNMrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 07:47:04 -0500
Content-Disposition: inline
In-Reply-To: <1197635860.16079.51.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 14, 2007 at 01:37:40PM +0100, Johannes Berg wrote:
> 
> I agree with this. IIRC I removed some ASSERT_RTNL()s in the wireless
> code (or maybe it was only during testing patches) where we had a
> function that required only the rtnl to be held but in certain contexts
> was called from within an RCU section.

Please point me to the actual code so I can see if this is legit
or not.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
