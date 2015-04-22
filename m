From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] crypto: Make all AEAD users include aead.h
Date: Wed, 22 Apr 2015 11:41:48 -0400 (EDT)
Message-ID: <20150422.114148.495349325919156837.davem@davemloft.net>
References: <20150422070455.GA8351@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	johannes@sipsolutions.net, marcel@holtmann.org
To: herbert@gondor.apana.org.au
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20150422070455.GA8351@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 22 Apr 2015 15:04:55 +0800

> This series adds inclusions of aead.h to all AEAD users including
> AEAD implementors (where it's internal/aead.h).  This is necessary
> because I'll be adding an updated AEAD interface and that will live
> in aead.h instead of crypto.h.
> 
> Dave, if it's OK with you I'd like to push the last two patches
> through my tree as the new AEAD interface would depend on them.

No objection, feel free to add my:

Acked-by: David S. Miller <davem@davemloft.net>
