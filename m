From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: Move hash_rnd into bucket_table
Date: Wed, 4 Feb 2015 07:17:51 +1100
Message-ID: <20150203201750.GA22474@gondor.apana.org.au>
References: <20150131102150.GA29498@gondor.apana.org.au>
 <20150202.191956.404010205495035337.davem@davemloft.net>
 <20150202.192634.1792206005008667377.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:52792 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543AbbBCUSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 15:18:03 -0500
Content-Disposition: inline
In-Reply-To: <20150202.192634.1792206005008667377.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 02, 2015 at 07:26:34PM -0800, David Miller wrote:
>
> Firstly, the hash_rnd change results in this:
>=20
> lib/rhashtable.c: In function =E2=80=98obj_raw_hashfn=E2=80=99:
> lib/rhashtable.c:84:9: warning: passing argument 1 of =E2=80=98lockde=
p_rht_mutex_is_held=E2=80=99 discards =E2=80=98const=E2=80=99 qualifier=
 from pointer target type [enabled by default]
> lib/rhashtable.c:57:5: note: expected =E2=80=98struct rhashtable *=E2=
=80=99 but argument is of type =E2=80=98const struct rhashtable *=E2=80=
=99

Pleas drop the hash_rnd patch since that's only needed by my
rehash work which is not yet complete.  Although I thought it
built correctly on its own since I've always had it in my test
tree but obviously I missed something.

> Next, the netfilter change results in:
>=20
> ERROR: "rhashtable_walk_start" [net/netfilter/nft_hash.ko] undefined!

Oops, I missed an export on that symbol.  I'll fix it up and
repost.

Thanks,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
