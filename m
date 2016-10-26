From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Intel-wired-lan] [net-next PATCH 26/27] igb: Update code to
 better handle incrementing page count
Date: Wed, 26 Oct 2016 10:21:52 -0700
Message-ID: <1477502512.2431.1.camel@intel.com>
References: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
	 <20161025153906.4815.61652.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-0f++dvhAy/23Xp0vvR9u"
Cc: davem@davemloft.net, brouer@redhat.com
To: Alexander Duyck <alexander.h.duyck@intel.com>, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20161025153906.4815.61652.stgit@ahduyck-blue-test.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org


--=-0f++dvhAy/23Xp0vvR9u
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-10-25 at 11:39 -0400, Alexander Duyck wrote:
> This patch updates the driver code so that we do bulk updates of the page
> reference count instead of just incrementing it by one reference at a
> time.
> The advantage to doing this is that we cut down on atomic operations and
> this in turn should give us a slight improvement in cycles per packet.=C2=
=A0
> In
> addition if we eventually move this over to using build_skb the gains
> will
> be more noticeable.
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
--=-0f++dvhAy/23Xp0vvR9u
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJYEOYwAAoJEOVv75VaS+3O+90P/RzEWysXswEA6WCLQghQzin4
AyEx54yCGcDsov1babvWDe1tg/IO3SCwEL/VHT0ku3CznqYlHfQZntTZrxD+DSPt
Ao0cD7AxdS925Q+qJcyzrhY0bzkVkL+V14VrpmWAIBMTUDuRliPPor37J0VPpvYC
CGFfe7lOr50pGcABz9RyXdGxqXGma2hZ2a2b953cBaLlkv5ovG0aBgC0hCaZFpmj
Apiatjc8prktsiP0qWwrjqKaqRcmWa9PJ2Qtt2WH1Gseg9ZGqIYkZSxT6dcF2qfs
4RK7fxxClZVOdnIYASkOkztpW8sAVztgrAflJ4QU6eH8GOBv3zBOlWfYcqPzSaHd
1otUncjOcAaA/wo/nrytXjIwJ0kKLjVlTlb8nslhFuXqFHAskUJ8hLp03lHtMkHz
pRxM5A4CtXaFSmrxjOc2LQUkGpDTgki6iLt3adJNa15+Jju1yI45zTrxwMouMskY
KkvCC2ueLD1z7fBLL8g00e/MjeNGH9oq8ONxQQQN6SHBVStrTt7jwskJCXHYAJ7t
99mivUy6aNu0cdPWYzzf/SNxof4pMPq+qiIWAQgjeDMEwZJlLx/97ThBvkG/8f38
gdHFG5gcdcM5b/riTJjcPCYm9ty71fbs2pVlHx/TkX7ZOH5sFyLf0IMijw8cxdon
ilygxstkUcu9eASLDNUj
=u6jM
-----END PGP SIGNATURE-----

--=-0f++dvhAy/23Xp0vvR9u--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
