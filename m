From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 0/4] rhashtable: Allow local locks to be used and tested
Date: Thu, 13 Nov 2014 18:10:25 +0800
Message-ID: <20141113101025.GA3728@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:49428 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932218AbaKMKKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 05:10:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

This series moves mutex_is_held entirely under PROVE_LOCKING so
there is zero foot print when we're not debugging.  More importantly
it adds a parrent argument to mutex_is_held so that we can test
local locks rather than global ones (e.g., per-namespace locks).

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
