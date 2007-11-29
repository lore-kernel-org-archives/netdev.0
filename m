From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket filter
Date: Thu, 29 Nov 2007 21:21:22 +1100
Message-ID: <20071129102122.GA22537@gondor.apana.org.au>
References: <20071119.142313.63549156.davem@davemloft.net> <20071120002945.91fafb2b.billfink@mindspring.com> <20071120140518.GA1502@one.firstfloor.org> <20071120.173928.53148729.davem@davemloft.net> <474E707A.3080106@cn.fujitsu.com> <20071129092136.GB30066@gondor.apana.org.au> <474E8F9E.7040309@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	netdev@vger.kernel.org, gerrit@erg.abdn.ac.uk,
	bfields@fieldses.org, neilb@suse.de
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1744 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750741AbXK2KVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 05:21:35 -0500
Content-Disposition: inline
In-Reply-To: <474E8F9E.7040309@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 29, 2007 at 06:08:30PM +0800, Wang Chen wrote:
> 
> Add a new UdpInEarlyDatagrams counter to count datagrams received early,
> but which might be dropped later.

Could you please split this into two patches? Have one do the
UdpInDatagrams change and the other to introduce the EarlyDatagrams
counter.

I'm a bit hesitant to introduce new counters in the MIB because
it'd be difficult if not impossible to ever remove them.  Do you
really need the early counter?

One more thing, please put the is_udplite clean-up in its own
patch too so it's absolutely clear what we're changing in the
patches that aren't clean-ups.

> Signed-off-by: Andi Kleen <ak@suse.de>
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Who's the author? Andi or you? Please make this obvious with a From
header when you resubmit.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
