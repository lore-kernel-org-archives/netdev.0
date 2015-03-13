From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] rhashtable: Arbitrary rehashing
Date: Thu, 12 Mar 2015 23:02:06 -0400 (EDT)
Message-ID: <20150312.230206.833345501561152507.davem@davemloft.net>
References: <20150309222631.GA12221@gondor.apana.org.au>
	<20150312164635.GA11089@casper.infradead.org>
	<20150313015410.GA28133@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, josh@joshtriplett.org,
	paulmck@linux.vnet.ibm.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43603 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277AbbCMDCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 23:02:07 -0400
In-Reply-To: <20150313015410.GA28133@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 13 Mar 2015 12:54:10 +1100

> rhashtable: Fix read-side crash during rehash
>     
> This patch fixes a typo rhashtable_lookup_compare where we fail
> to recompute the hash when looking up the new table.  This causes
> elements to be missed and potentially a crash during a resize.
> 
> Reported-by: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
