From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Allow forwarding of ip_summed except CHECKSUM_COMPLETE
Date: Wed, 28 Mar 2007 07:20:03 +1000
Message-ID: <20070327212003.GA30862@gondor.apana.org.au>
References: <20070327053821.GA23596@gondor.apana.org.au> <460983E9.5040005@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1057 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965440AbXC0VUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 17:20:14 -0400
Content-Disposition: inline
In-Reply-To: <460983E9.5040005@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 27, 2007 at 10:51:53PM +0200, Patrick McHardy wrote:
> 
> Just wondering, how does Xen know whether a packet will be forwarded?

It's up to Linux to handle it correctly.

> The input path doesn't seem to deal with CHECKSUM_PARTIAL correctly,
> ip_defrag for example resets them to CHECKSUM_NONE, so further checks
> will fail, others seem to either ignore them or handle them together
> with CHECKSUM_NONE.

That's OK, Linux/Xen never generates any CHECKSUM_PARTIAL fragments.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
