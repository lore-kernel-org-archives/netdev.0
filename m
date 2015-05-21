From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] crypto: Convert all AEAD users to new interface
Date: Thu, 21 May 2015 12:03:47 -0400 (EDT)
Message-ID: <20150521.120347.286409931588196234.davem@davemloft.net>
References: <20150521103938.GA23035@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	johannes@sipsolutions.net, marcel@holtmann.org,
	steffen.klassert@secunet.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37155 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756977AbbEUQDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 12:03:52 -0400
In-Reply-To: <20150521103938.GA23035@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 21 May 2015 18:39:39 +0800

> This series of patches convert all in-tree AEAD users that I
> could find to the new single SG list interface.  For IPsec it
> also adopts the new explicit IV generator scheme.

No objections on my end.

I assume since the dependencies exist in the crypto tree, you'll
want to merge this series there right?
