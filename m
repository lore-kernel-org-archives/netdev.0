From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macsec: fix crypto Kconfig dependency
Date: Mon, 18 Apr 2016 12:04:01 -0400 (EDT)
Message-ID: <20160418.120401.1404930931456729359.davem@davemloft.net>
References: <1460884918-2879720-1-git-send-email-arnd@arndb.de>
	<20160418080202.GA18155@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, sd@queasysnail.net, hannes@stressinduktion.org,
	johannes@sipsolutions.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160418080202.GA18155@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 18 Apr 2016 16:02:02 +0800

> In fact this strikes me as a kbuild bug because CRYPTO_GCM already
> selects (indirectly) CRYPTO_ALGAPI so why is this happening at all?

Selects don't trigger selects.
