From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 0/6] rhashtable: Fixes + cleanups + preparation for
 multiple rehash
Date: Sat, 14 Mar 2015 13:53:39 +1100
Message-ID: <20150314025339.GA10585@gondor.apana.org.au>
References: <20150313095607.GA598@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:37390 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbbCNCxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 22:53:41 -0400
Content-Disposition: inline
In-Reply-To: <20150313095607.GA598@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

Patch 1 fixes the walker so that it behaves properly even during
a resize.

Patch 2-3 are cleanups.

Patch 4-6 lays some ground work for the upcoming multiple rehashing.

This revision fixes the warning coming from the bucket_table->size
downsize and improves its changelog.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
