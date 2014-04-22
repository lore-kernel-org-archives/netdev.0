From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH v5] core, nfqueue,
 openvswitch: Orphan frags in skb_zerocopy and handle errors
Date: Tue, 22 Apr 2014 16:38:38 +0100
Message-ID: <1398181118.3624.203.camel@deadeye.wl.decadent.org.uk>
References: <1395873465-22282-1-git-send-email-zoltan.kiss@citrix.com>
 <20140327.152956.1528740039185894234.davem@davemloft.net>
 <20140421112601.GC3200@hercules>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0802286689288613083=="
Cc: netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mszeredi-AlSwsSmVLrQ@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, JBeulich-IBi9RG/b67k@public.gmane.org,
 therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org,
 kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
 jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org, Paul.Durrant-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Luis Henriques <luis.henriques-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140421112601.GC3200@hercules>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org


--===============0802286689288613083==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-yXhVSZ4fAkZKhh5lQ3eq"


--=-yXhVSZ4fAkZKhh5lQ3eq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-04-21 at 12:26 +0100, Luis Henriques wrote:
> Hi David,
>=20
> On Thu, Mar 27, 2014 at 03:29:56PM -0400, David Miller wrote:
> > From: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
> > Date: Wed, 26 Mar 2014 22:37:45 +0000
> >=20
> > > skb_zerocopy can copy elements of the frags array between skbs, but i=
t doesn't
> > > orphan them. Also, it doesn't handle errors, so this patch takes care=
 of that
> > > as well, and modify the callers accordingly. skb_tx_error() is also a=
dded to
> > > the callers so they will signal the failed delivery towards the creat=
or of the
> > > skb.
> > >=20
> > > Signed-off-by: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
> >=20
> > Fingers crossed :-)  Applied, thanks Zoltan.
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
> Could you please queue this for stable as well?  It has CVE-2014-2568
> assigned to it and I believe it is applicable to some of the trees.

It was applied to 3.13, but needs backporting to earlier versions.  I
posted my attempt in
<1397429860.10849.86.camel-nDn/Rdv9kqW9Jme8/bJn5UCKIB8iOfG2tUK59QYPAWc@public.gmane.org> but it needs
testing/reviewing.

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-yXhVSZ4fAkZKhh5lQ3eq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1aM/ue/yOyVhhEJAQrEZg/9EvsyUfx8GSmtrzqV7LVBTuzLyAysjdu2
iFQrjx4AZroLRPtOu2wE0C3JumJfk4Fo271Oy0vV9m/KriF5LN4M1+7b2i2MdJBH
kwHdIRE3IIN0KFVcQL5uFWv3k34CaUsLkg/SS0v6CC/W9PibguJQo/WnTmvNG8tg
WtFoec/X/n99PNZbfEobICZaEh14d+H60MTSOz38NOWsfXDn9Qjl/HZ+yQPe9+p7
YUEo8MemVP5ZRGe94dDMkW6gZ3bwfN+7XVtJ1KOePStl3nqiLGbg98MX/kCIFdrc
eze4cU5iUWmBoAzzIEVy7Fphv6FXXIHXWsMaf1+liEu3zOtcFowU0R2B06Ekz/57
cmt8MsfILPioBaDUspbZx3A5JwzBEnhgNDZWfYQVdt4D0n7M4BEvl43/wkhLAEFv
P9yUatDWHjbwYPAWPruQ9MvCLdTSdbU1P/UsTjrD741OlAMTDpPszzuy4Fq5W/QH
+U1/CQt50XbDpX5wo/cWtRt4Y7u8d0aaM1TtPPOo/p3RwAOJU4GdABpu6zQMq1Ot
ZKBQHKBqbZz3er1PDT9mWRN3jq0Ct8NHvVTgr6DpJn0+S72YJTGnrYEr33Rn+yml
AvmNm/r6yTqaEknEyOHVnhVsZMFOol1sGyShkvsCddOx8COEA//WZIn2BSljeMM6
YOfG/iGwSqY=
=57mT
-----END PGP SIGNATURE-----

--=-yXhVSZ4fAkZKhh5lQ3eq--

--===============0802286689288613083==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0802286689288613083==--
