From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Tue, 27 Jan 2015 11:16:04 +0000
Message-ID: <20150127111604.GF22262@casper.infradead.org>
References: <E1YFWUl-0004gE-SH@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CAD2C12@AcuExch.aculab.com>
 <20150126222259.GC30116@gondor.apana.org.au>
 <20150126.143613.1798698028405169123.davem@davemloft.net>
 <20150126224216.GA30551@gondor.apana.org.au>
 <20150126233100.GA31108@gondor.apana.org.au>
 <20150127094541.GC22262@casper.infradead.org>
 <20150127095454.GA2695@gondor.apana.org.au>
 <20150127101512.GE22262@casper.infradead.org>
 <20150127102420.GA3777@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, David.Laight@ACULAB.COM,
	ying.xue@windriver.com, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37842 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754203AbbA0LQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 06:16:08 -0500
Content-Disposition: inline
In-Reply-To: <20150127102420.GA3777@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/27/15 at 09:24pm, Herbert Xu wrote:
> The point is that for netfilter as it stands it makes no sense
> to go lockless because its modus operandi is to hold a single
> lock over everything, including walking/dumping.

No objection. I have a patch prepared which allows the user to
provide ht->mutex himself so nfset can provide its own existing
mutex to rhashtable and lock out the resizes from inserts,
removals and dump iterations automatically That would restore the
old behaviour of the nfset API without major surgery.

I was just waiting on your walker as you requested a hold off.
