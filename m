From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 0/3] rhashtable: Get rid of raw table walkers part 1
Date: Thu, 18 Aug 2016 16:48:54 +0800
Message-ID: <20160818084854.GA11502@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:47329 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbcHRItt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 04:49:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

This series starts the process of getting rid of all raw rhashtable
walkers (e.g., using any of the rht_for_each helpers) from the
kernel.

We need to do this before I can fix the resize kmalloc failure issue
by using multi-layered tables.

We should do this anyway because almost all raw table walkers are
already buggy in that they don't handle multiple rhashtables during
a resize.

Dave/Tomas, please keep an eye out for any new patches that try
to introduce raw table walkers and nack them.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
