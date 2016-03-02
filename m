From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2] ethtool: check size of user memory before copying
 strings and stats
Date: Wed, 02 Mar 2016 00:12:20 +0000
Message-ID: <1456877540.3098.162.camel@decadent.org.uk>
References: <1456871112-14103-1-git-send-email-jacob.e.keller@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-7GrYd8yW/LcAXwh8NC9w"
Cc: David Miller <davem@davemloft.net>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Garzik <jeff@garzik.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Mark Rustad <mark.d.rustad@intel.com>
To: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:47640 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932546AbcCBAMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 19:12:42 -0500
In-Reply-To: <1456871112-14103-1-git-send-email-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7GrYd8yW/LcAXwh8NC9w
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-03-01 at 14:25 -0800, Jacob Keller wrote:
> Since at least 2005, (oldest commit in ethtool.git), the userspace
> ethtool implementation has given the size of the memory it has allocated
> as the actual size in the ethtool data structures. We previously blindly
> ignore this and overwrite the requested size with the current size
> returned by .get_strings or .get_sset_count. This can cause problems if
> these values aren't static.
[...]

NAK, ethtool is not the only consumer of the ethtool API. =C2=A0How many
times do I have to repeat myself?

Ben.

--=20
Ben Hutchings
Tomorrow will be cancelled due to lack of interest.
--=-7GrYd8yW/LcAXwh8NC9w
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVtYv5Oe/yOyVhhEJAQp+vxAAt7OhStrWiPjptbfRE29mo7LTbfO0sG3J
44uzHS/MvGB9LAyfXAzVKObNUzuEvLpBAMqfAwMEy1IFldGmouy00bOehKByMtzF
j9bUaxJ64TBMCJXW4IWKSxD8E0sfGQaBqTpRybyVeg5/yjtE0nhLTDk9a5mNlX34
Vcg3P77uyuKF4mQtj+WniiWjkaXFA5kFTaGXGxvJreYAVPKBXwAOp6U7wwg2tm6E
GtCB1IW1138WHJbgY/VwosS9ADCmOLBtj5ljLei6TLEvlMjz6ZnpXcJ6WNEKqysk
/pW/ZhJhethkd429P5Bq6lx/1L3GRmKU0Q/bVgn/zGp906PP/RlPg7zURdsejX9B
b0+LLHHv3yRbMykYQ6MSccfE0pQhT+5ejkvliY8ARPdtKL3JiIeYIfs0aRN8zH4E
3DAAkPjvcadDElisr55ZkzPN5grirbvfzmXGHfCtMjUL9oDOBBTjqL+Szn57PnoF
RZCJeSyQn6GMupwLJNpY2hupvR+zZy3k3Nkak78NfYELepJFx4iXMVBQznbYEZ0q
HDpOIamaH3Xy82luCQ2VHz6CIlRMjAGPpGSVlGVkhcH0ExM5JN4MEA4KiXv2iPqA
N5DyHH/wPgA6doJjDH04guq9QGd/JK8+xMPUUZ/GOuD5Ru/6HpZpAWIEBsppiOHi
7/fOaWQi5xA=
=Wjf6
-----END PGP SIGNATURE-----

--=-7GrYd8yW/LcAXwh8NC9w--
