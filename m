From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rhashtable: fix shift by 64 when shrinking
Date: Mon, 15 Aug 2016 11:10:46 -0700 (PDT)
Message-ID: <20160815.111046.654025349514800255.davem@davemloft.net>
References: <1471025444-22800-1-git-send-email-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: vegard.nossum@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753268AbcHOSKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 14:10:48 -0400
In-Reply-To: <1471025444-22800-1-git-send-email-vegard.nossum@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vegard Nossum <vegard.nossum@oracle.com>
Date: Fri, 12 Aug 2016 20:10:44 +0200

> I got this:
 ...
> roundup_pow_of_two() is undefined when called with an argument of 0, so
> let's avoid the call and just fall back to ht->p.min_size (which should
> never be smaller than HASH_MIN_SIZE).
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>

Applied, thank you.
