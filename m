From: David Miller <davem@davemloft.net>
Subject: Re: arp_hash
Date: Sun, 22 Mar 2015 18:57:14 -0400 (EDT)
Message-ID: <20150322.185714.1793567801322787489.davem@davemloft.net>
References: <20150322114204.GA5010@gondor.apana.org.au>
	<20150322.125458.2054837991708165397.davem@davemloft.net>
	<20150322213408.GC7925@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@purestorage.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895AbbCVW5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 18:57:17 -0400
In-Reply-To: <20150322213408.GC7925@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 23 Mar 2015 08:34:08 +1100

> So what scales we are talking about, twice, three times? Have you
> considered more modern hashes such as SipHash or SpookyHash
> (successor to jhash/lookup3 and supposedly faster)?

I want it to be one cycle or two.

Every single transmitted packet hits this hash demux.
