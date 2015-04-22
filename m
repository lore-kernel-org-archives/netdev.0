From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 0/6] crypto: Make all AEAD users include aead.h
Date: Wed, 22 Apr 2015 15:04:55 +0800
Message-ID: <20150422070455.GA8351@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:34685 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754334AbbDVHFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 03:05:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

This series adds inclusions of aead.h to all AEAD users including
AEAD implementors (where it's internal/aead.h).  This is necessary
because I'll be adding an updated AEAD interface and that will live
in aead.h instead of crypto.h.

Dave, if it's OK with you I'd like to push the last two patches
through my tree as the new AEAD interface would depend on them.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
