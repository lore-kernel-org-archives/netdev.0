From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 0/3] rhashtable: Handle table allocation failure during
 insertion
Date: Tue, 7 Feb 2017 20:38:27 +0800
Message-ID: <20170207123827.GA14678@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:49171 "EHLO
        helcar.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751526AbdBGMjG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 07:39:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

This series tackles the problem of table allocation failures during
insertion.  The issue is that we cannot vmalloc during insertion.
This series deals with this by introducing nested tables.

The first two patches removes manual hash table walks which cannot
work on a nested table.

The final patch introduces nested tables.

I've tested this with test_rhashtable and it appears to work.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
