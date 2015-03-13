From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] rhashtable: Fixes + cleanups + preparation for
 multiple rehash
Date: Fri, 13 Mar 2015 12:25:05 -0400 (EDT)
Message-ID: <20150313.122505.22987105222244414.davem@davemloft.net>
References: <20150313095607.GA598@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51090 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932217AbbCMQZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 12:25:10 -0400
In-Reply-To: <20150313095607.GA598@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 13 Mar 2015 20:56:07 +1100

> Patch 1 fixes the walker so that it behaves properly even during
> a resize.
> 
> Patch 2-3 are cleanups.
> 
> Patch 4-6 lays some ground work for the upcoming multiple rehashing.

Looks like this needs at least one respin, to fix the printf formatting
from changing size to unsigned int from size_t.

And perhaps addressing the ordering of patches #6 and #1.
