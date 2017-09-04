From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: Re: [PATCH v06 35/36] uapi linux/tls.h: don't include <net/tcp.h> in
 user space
Date: Mon, 4 Sep 2017 19:15:11 +0300
Message-ID: <20170904161510.GA16001@altlinux.org>
References: <20170806164428.2273-1-mikko.rapeli@iki.fi>
 <20170806164428.2273-36-mikko.rapeli@iki.fi>
 <20170808232554.GK10552@altlinux.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="ikeVEW9yuYc//A+q"
To: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
        Mikko Rapeli <mikko.rapeli@iki.fi>,
        Dave Watson <davejwatson@fb.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170808232554.GK10552@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ikeVEW9yuYc//A+q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 09, 2017 at 02:25:54AM +0300, Dmitry V. Levin wrote:
> On Sun, Aug 06, 2017 at 06:44:26PM +0200, Mikko Rapeli wrote:
> > It is not needed and not part of uapi headers, but causes
> > user space compilation error:
> >=20
> > fatal error: net/tcp.h: No such file or directory
> >  #include <net/tcp.h>
> >                      ^
> >=20
> > Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
> > Cc: Dave Watson <davejwatson@fb.com>
> > Cc: Ilya Lesokhin <ilyal@mellanox.com>
> > Cc: Aviad Yehezkel <aviadye@mellanox.com>
> > ---
> >  include/uapi/linux/tls.h | 2 ++
> >  1 file changed, 2 insertions(+)
> >=20
> > diff --git a/include/uapi/linux/tls.h b/include/uapi/linux/tls.h
> > index cc1d21db35d8..d87c698623f2 100644
> > --- a/include/uapi/linux/tls.h
> > +++ b/include/uapi/linux/tls.h
> > @@ -37,7 +37,9 @@
> >  #include <asm/byteorder.h>
> >  #include <linux/socket.h>
> >  #include <linux/tcp.h>
> > +#ifdef __KERNEL__
> >  #include <net/tcp.h>
> > +#endif
>=20
> Let's move it to include/net/tls.h instead.

So everybody ignored this and *new* uapi header was released
in a totally unusable form along with v4.13.


--=20
ldv

--ikeVEW9yuYc//A+q
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJZrXwOAAoJEAVFT+BVnCUI0v8P/1UZbKR5JkfiUMlJzZ+j0RuE
DDAsysd/fKOeHjZFod1cRIHbALKGvQ2e2EYlCv+ETOpYK+6UJS/6LhEV0I4nQdDQ
f9Bnb9cy8TwBpDwRHJK6XRYidqY+6T5ND9yeZVB85GYC2iRMRIHL78oeje9Mw+vN
yYtsQ0vI5Px9SuyTjk05ToXnSnkvt8XDHWzi4rjLiK0vKaJOZW+b6JKJ9iEEObqz
Gvib+nXBNm2/BoybWBvdyAj1rFFjFPa7rZf0QI08CldPuD3WmCLU9WbRlQYbYWUE
uM4cGU0YtxmGR3DOzFadWSulawEkyQzQVY13WwHOMS4fw71jxn7J2liHe5dG4s8v
1bpd4C0TINZrV+BrITJVDIQAIb+PRoHwP8wYw3sS2In/ntzc38KQQUEKraJu+o+8
00oyGv2dDs/9KUlagLtK7sbcBTAXCHotIyKAaj5lJpreOH+QZFwP1wgfL9mRhRkm
wPmAJyLJw0T7or29Ir4g2t3x5cPjP81w/An+ne2E2sRkqSac2UAzPpY1vKy/GAuI
6fWT7+raS4hmzSanIyNRpuAjyVxki+aYoEjT4vTC0Auzx+qC9KEE0CuqqMiub1yf
Wt9YVnMqRdXutw1504bjSrJ+iBNNFhN5q/Y7Flu7xEhDYOkcxUtb9ViItMSpFRZM
Pmo76lriUGoYVm04lD17
=1FJc
-----END PGP SIGNATURE-----

--ikeVEW9yuYc//A+q--
