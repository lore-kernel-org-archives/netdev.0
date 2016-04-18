From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macsec: fix crypto Kconfig dependency
Date: Mon, 18 Apr 2016 12:43:16 -0400 (EDT)
Message-ID: <20160418.124316.1862068166928198574.davem@davemloft.net>
References: <20160418080202.GA18155@gondor.apana.org.au>
	<11585265.Dbvl2xi4u3@wuerfel>
	<20160418104336.GA19175@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, sd@queasysnail.net, hannes@stressinduktion.org,
	johannes@sipsolutions.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160418104336.GA19175@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 18 Apr 2016 18:43:36 +0800

> Right, the problem is that nothing within crypto ever selects
> CRYPTO since it's also used as a way of hiding the crypto menu
> options.

As far as I understand it, this won't help.  Because selects do not
trigger other selects and dependencies.

This is why we always must list all leaf node dependencies with select
statements, rather than just the specific feature one needs.
