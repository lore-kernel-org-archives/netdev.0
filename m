From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: alloc skb based on a given data buffer
Date: Fri, 18 Sep 2009 22:56:06 -0700
Message-ID: <1253339766.16125.1.camel@johannes.local>
References: <20090915.020903.93643290.davem@davemloft.net>
	 <1253006111.7549.61.camel@debian>
	 <1253028631.23427.55.camel@johannes.local>
	 <20090915.141606.134994761.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-q77ki/2eoXOCiZi7ADji"
Cc: yi.zhu@intel.com, mel@csn.ul.ie, reinette.chatre@intel.com,
	elendil@planet.nl, Larry.Finger@lwfinger.net,
	linville@tuxdriver.com, penberg@cs.helsinki.fi,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	ipw3945-devel@lists.sourceforge.net, akpm@linux-foundation.org,
	cl@linux-foundation.org, assaf.krauss@intel.com,
	mohamed.abbas@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:40916 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753749AbZISF4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2009 01:56:48 -0400
In-Reply-To: <20090915.141606.134994761.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-q77ki/2eoXOCiZi7ADji
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-09-15 at 14:16 -0700, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Tue, 15 Sep 2009 08:30:31 -0700
>=20
> > Hold, mac80211 can't cope with that at this point for sw crypto and
> > possibly other things.
>=20
> Then it should skb_linearize() at input, or similar.

Not all that much won then since that again means an order-2 allocation.
Fewer, certainly, as most packets are actually much smaller than that.

johannes

--=-q77ki/2eoXOCiZi7ADji
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKtHJyAAoJEODzc/N7+QmaK64QAJxYVAiY0mWYsHhi3iGib2Ma
1VqZdVHNCZ4AbUp90sOkrTfUaS/nL0w5EPQ8hhM1zMQoqcyX7O05dPig2ahnRLJ1
MZXZkPhV3Nb1TAHwYj4PDaRur7X5d9xCBhPDZEt9feLZs3Gw8NqhmJxDoNi3OyA8
VmGVBhifpZMZetST5votEXXJWOx3aN8UAf6xv+jbOAFcfNke3xUWSKFVtK82B6UV
8klkTFAOo/Tq9RlV2Eb83QaFnHYjZLMfj0puh8Tc8E/i6BARrI+qgjT1DJNBFTsL
Bbe3yGq+OWMQ//tWbRvZTN954vKdtvA6PfU6lF3gVdSlJAZKSZUIt6EBHf/ZSz0J
O7eTPweVKNKEHFROglN+w+IWV8ZNZIcms+1sCK3zH3bLxKpR89LyWtiRaIX8tuci
BwvXfLgVTnDJjf89X3uaNmH8XCv3zyX6TBhuMrfB1fjWwc8xPp5Rupo83jC9KPAp
Vzc5NY/VXdD/U27VBNRvS2KQUiKXNU/NyLoZ2o+WW51mkHStwmv/6/HXyBDT9v1U
sc0yBjg3/yJo50RTzaQRvUVmEqWZcLtEujgOlgad3YuCpZMUjdaOHybQWkvGJMxb
jhDfsfCvlLfLSE+8E4/2+9BIlBVSa8qovt2WCkiXMrY+j3YFGNI/E+GPXcTmCxCU
r+CgNqI9zDZusMru3zcU
=AziV
-----END PGP SIGNATURE-----

--=-q77ki/2eoXOCiZi7ADji--

