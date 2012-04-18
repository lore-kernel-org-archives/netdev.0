From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: Re: [PATCH 05/11] batman-adv: handle routing code
 initialization properly
Date: Wed, 18 Apr 2012 08:45:05 +0200
Message-ID: <20120418064504.GB27966@ritirata.org>
References: <1334663907-22725-1-git-send-email-ordex@autistici.org>
	<1334663907-22725-6-git-send-email-ordex@autistici.org>
	<20120417.224630.1104076946118354940.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cvVnyQ+4j833TQvp"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	lindner_marek-LWAfsSFWpa4@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120417.224630.1104076946118354940.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


--cvVnyQ+4j833TQvp
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 17, 2012 at 10:46:30 -0400, David Miller wrote:
> From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
> Date: Tue, 17 Apr 2012 13:58:21 +0200
>=20
> > @@ -30,10 +30,11 @@
> >  #include "send.h"
> >  #include "bat_algo.h"
> > =20
> > -static void bat_iv_ogm_iface_enable(struct hard_iface *hard_iface)
> > +static int bat_iv_ogm_iface_enable(struct hard_iface *hard_iface)
> >  {
> >  	struct batman_ogm_packet *batman_ogm_packet;
> >  	unsigned long random_seqno;
> > +	int res =3D -1;
> > =20
> >  	/* randomize initial seqno to avoid collision */
> >  	get_random_bytes(&random_seqno, sizeof(unsigned long));
>=20
> Use real error codes, even as a default, instead of meaningless
> values like -1.

Actually all these kind of return values are handled internally the batman-=
adv
code so we didn't care so much to use real error codes. However using real =
codes
will surely increase readability.

I will modify this patch and I'll try to suggest other developers to use re=
al
codes too.

Thank you.

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--cvVnyQ+4j833TQvp
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQEcBAEBAgAGBQJPjmLwAAoJEFMQTLzJFOZFxAgH/2APyOD61JtjZTgEghTM1F10
vVaLcptAqSg9oPbV4ae6HmpSWFC8L2RvXz5LPTdOfrKAbMmNxcpK0yLrfed/SvVg
NqPEnGNu5QetJK7fmsLT2RVl3XEQLzHSJhi5fUvDnLW8d5pI0SuMw/z+N86gaTIN
+xVs8cNyOaSSVtWsrZrOXTMwjhC/qhNIdeYeNTiO+4KZW3K1l30fcWPILnIo4IH5
pTPTMhrXyyl8UHDIF6y7Zbrj3xAP7VM5AuGhn6Zrr0BUtbm8N2LF1zBjTAQvvxoH
tf4YYYqcF0QVxsEq3ArzyLJILuhm5Y3/XyLF0W4KvsEWxNPtsgbg1cXesr+rews=
=dn/P
-----END PGP SIGNATURE-----

--cvVnyQ+4j833TQvp--
