From: David Miller <davem@davemloft.net>
Subject: Re: [v1 PATCH 0/6] rhashtable: Fix two bugs caused by multiple
 rehash preparation
Date: Sun, 15 Mar 2015 22:23:35 -0400 (EDT)
Message-ID: <20150315.222335.209041741330241010.davem@davemloft.net>
References: <20150314025339.GA10585@gondor.apana.org.au>
	<20150315.013613.2034532005621627761.davem@davemloft.net>
	<20150315101004.GA21383@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53347 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844AbbCPCXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 22:23:38 -0400
In-Reply-To: <20150315101004.GA21383@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 15 Mar 2015 21:10:04 +1100

> While testing some new patches over the weekend I discovered a
> couple of bugs in the series that had just been merged.  These
> two patches fix them:
> 
> 1) A use-after-free in the walker that can cause crashes when
> walking during a rehash.
> 
> 2) When a second rehash starts during a single rhashtable_remove
> call the remove may fail when it shouldn't.

Series applied, thanks Herbert.
