From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 19/26] ipsec: Use skcipher and ahash when probing
 algorithms
Date: Sun, 24 Jan 2016 22:02:27 -0800 (PST)
Message-ID: <20160124.220227.1203168765001083726.davem@davemloft.net>
References: <20160124131021.GA31153@gondor.apana.org.au>
	<E1aNKZT-0008Ew-7q@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	dm-devel@redhat.com, linux-wireless@vger.kernel.org,
	linux-cifs@vger.kernel.org, ecryptfs@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, ceph-devel@vger.kernel.org,
	linux-wpan@vger.kernel.org, linux-afs@lists.infradead.org,
	drbd-dev@lists.linbit.com, open-iscsi@googlegroups.com
To: herbert@gondor.apana.org.au
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <E1aNKZT-0008Ew-7q@gondolin.me.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:19:11 +0800

> This patch removes the last reference to hash and ablkcipher from
> IPsec and replaces them with ahash and skcipher respectively.  For
> skcipher there is currently no difference at all, while for ahash
> the current code is actually buggy and would prevent asynchronous
> algorithms from being discovered.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: David S. Miller <davem@davemloft.net>
