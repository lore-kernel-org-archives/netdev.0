From: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
Subject: Re: [PATCH 1/6] batman-adv: free nf_bridge member on
 locally delivered skb
Date: Mon, 23 Dec 2013 01:19:10 +0100
Message-ID: <52B7817E.8090007@meshcoding.com>
References: <1387412132-889-2-git-send-email-antonio@meshcoding.com>	<20131222.185027.572777902017063381.davem@davemloft.net>	<52B77F9E.8040201@meshcoding.com>
 <20131222.191622.118900475665948342.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="7dXcfl16xs4TsMxwv5ADA2xHuv2tevERl"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20131222.191622.118900475665948342.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--7dXcfl16xs4TsMxwv5ADA2xHuv2tevERl
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 23/12/13 01:16, David Miller wrote:
> There is zero reason for your protocol layer to have an ad-hoc private
> SKB netfilter state reset function that touches internals in this way.
>=20

agreed.

> At least with the generic helpers, we know the side effects and the
> function is well known to other developers.
>=20


Ok, I'll do it the clean way and resend the pull request.


Thanks!

--=20
Antonio Quartulli


--7dXcfl16xs4TsMxwv5ADA2xHuv2tevERl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSt4GDAAoJEEKTMo6mOh1VsHcP/jm6GiDip6+hqSA8K3CEczE9
OHvwf0MdaJZcw5GR0oJqbHy3JcjeUS5TU4Ot14fPwIM9gL6D+8sbuKZc+/ptdoc4
W6DufnuD6RPtCY5k6miY8FfBXHEpAaHiIoRCbikofvCF1onCDMyRM4mBZFM/o7sb
wXHHhKZ9UnuIZzxK9IOe0sPl2fzE3GR6oRXi8Nk4gVLvpryrRknNlJPF5M1WSED6
ILEU8oNODuZxkCbVnSEE7CONNOtktF7zRWXs6nCSQW1xdgACDG+8t9ZqhKa1gcLL
IrPi1YTjKdYj7/D35zzfpXVg0X8figtfoAmPmlLvHaRnpwSjAegSUxp7oseeEWA5
l1rxSO0dCNAFuFNMTTq7Klaz6JUVAKOBve4XN+ZTnXgyINXFerOderaqpwh0dIfJ
CUTx7hjHOl5pDS9Au4QsJRdrFy0XHYL6wgLtdmEd+7qLz77AOGZkCCwk5zcpjsrI
iShHKJAKb6AwCyHwCAugKMZ7qynuap8ZjMqMfrA99842wARF4XMMOtL9+QC+qItI
B2M4Nw0/UKmIDH9EXL510Y5myPxiw4wdnWmstiMJZl8GstiQ+ElpTWUNpc3xU17i
xcoaJBfg/aOrzmJ41QgnQb3zJB0186Tmrn+vlLaIGEkCN7EfxSXXzxQkQ+BXXH/w
hZUR23JbFOVT/yJQ/ye3
=Mqg5
-----END PGP SIGNATURE-----

--7dXcfl16xs4TsMxwv5ADA2xHuv2tevERl--
