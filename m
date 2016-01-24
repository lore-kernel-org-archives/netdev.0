From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 0/26] crypto: Use skcipher and ahash/shash where possible
Date: Sun, 24 Jan 2016 21:10:21 +0800
Message-ID: <20160124131021.GA31153@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	dm-devel@redhat.com, linux-wireless@vger.kernel.org,
	linux-cifs@vger.kernel.org, ecryptfs@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, ceph-devel@vger.kernel.org,
	linux-wpan@vger.kernel.org, linux-afs@lists.infradead.org,
	drbd-dev@lists.linbit.com, linux-nfc@lists.01.org,
	open-iscsi@googlegroups.com
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

The crypto hash interface has been obsolete for many years and
this series converts all remaining users to shash and ahash as
appropriate.  Despite the name ahash can be used synchronously
and is the preferred interface for those dealing with SGs.

The blkcipher and ablkcipher interfaces are also being phased out
and is being replaced with the merged skcipher interface which
is essentially the same as ablkcipher but without the implicit
IV generators.  This series converts all users of blkcipher and
ablkcipher over to skcipher.

If you have any objections please shout.  Otherwise I would like
to take these patches through the cryptodev tree so we can proceed
with phasing out the obsolete interfaces.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
