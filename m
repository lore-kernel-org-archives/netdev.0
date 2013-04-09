From: Antonio Quartulli <antonio@open-mesh.com>
Subject: Re: [PATCH 1/3] if.h: add IFF_BRIDGE_RESTRICTED flag
Date: Tue, 9 Apr 2013 08:33:43 +0200
Message-ID: <20130409063342.GA3771@open-mesh.com>
References: <1365442863-32394-1-git-send-email-antonio@open-mesh.com>
 <1365442863-32394-2-git-send-email-antonio@open-mesh.com>
 <CAOaVG17nHuoRsf2Kss6LnpgC-Aojcso_zLYyBa18Vn9CGGY+GA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="a8Wt8u1KmwUX3Y2C"
Cc: "David S. Miller" <davem@davemloft.net>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ht1.myhostedexchange.com ([69.50.2.37]:62009 "EHLO
	ht1.hostedexchange.local" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751186Ab3DIGfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 02:35:14 -0400
Content-Disposition: inline
In-Reply-To: <CAOaVG17nHuoRsf2Kss6LnpgC-Aojcso_zLYyBa18Vn9CGGY+GA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Stephen,

thank you for your reply.

On Mon, Apr 08, 2013 at 11:58:48 -0700, Stephen Hemminger wrote:
> The standard way to do this is to use netfilter. Considering the
> additional device flags and skb flag changes, I am not sure that your
> method is better.
>=20

The point is that netfilter would not help me in "distributing" this policy
remotely over a generic layer2 network.

Using these flags, instead, I can make other modules (e.g. batman-adv) noti=
ce
that the skb has been marked and then react using their own logic.

If netfilter (at the bridge level) could "mark" the skbs somehow then I cou=
ld use
it for this purpose. But I don't think this is really possible.

Cheers,

> On Mon, Apr 8, 2013 at 10:41 AM, Antonio Quartulli
> <antonio@open-mesh.com> wrote:
> > This new flag tells whether a network device has to be
> > considered as restricted in the new bridge forwarding logic.
> >
> > Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
> > ---
> >  include/uapi/linux/if.h | 1 +
> >  net/core/dev.c          | 2 +-
> >  2 files changed, 2 insertions(+), 1 deletion(-)
> >
> > diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
> > index 1ec407b..5c3a9bd 100644
> > --- a/include/uapi/linux/if.h
> > +++ b/include/uapi/linux/if.h
> > @@ -83,6 +83,7 @@
> >  #define IFF_SUPP_NOFCS 0x80000         /* device supports sending cust=
om FCS */
> >  #define IFF_LIVE_ADDR_CHANGE 0x100000  /* device supports hardware add=
ress
> >                                          * change when it's running */
> > +#define IFF_BRIDGE_RESTRICTED 0x200000 /* device is bridge-restricted =
*/
> >
> >
> >  #define IF_GET_IFACE   0x0001          /* for querying only */
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 3655ff9..49eafc8 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -4627,7 +4627,7 @@ int __dev_change_flags(struct net_device *dev, un=
signed int flags)
> >
> >         dev->flags =3D (flags & (IFF_DEBUG | IFF_NOTRAILERS | IFF_NOARP=
 |
> >                                IFF_DYNAMIC | IFF_MULTICAST | IFF_PORTSE=
L |
> > -                              IFF_AUTOMEDIA)) |
> > +                              IFF_AUTOMEDIA | IFF_BRIDGE_RESTRICTED)) |
> >                      (dev->flags & (IFF_UP | IFF_VOLATILE | IFF_PROMISC=
 |
> >                                     IFF_ALLMULTI));
> >
> > --
> > 1.8.1.5
> >

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--a8Wt8u1KmwUX3Y2C
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJRY7ZGAAoJEADl0hg6qKeOvhQQALngU7c2gRUTq0iCezHMYRMn
uSsp+MwR5r4oGb7bD7s29wpBbkW0y8/BBzELOsHQOi8ArXRUR3ui10DMG+iiWVSj
M19z7k3CzE6q/h3d1ghYTPL/9tx4RxKhWy4NSTdXgo1TFGdZV47f6KCmHEzoq6fu
Wk1zuIzVWAhm58Rih94b1C5rKOkK8ICiOPbUcqHR5xMluAaj3RSu/oLUPJzAQWw8
S2ykua9jFsDucqGoYFEst8jnau7fw10UvoljvptCoQr/ZYur9/UW4mxWUMnlO08h
qq7DNJbChNxTW8lLQ919hsNmAo35gPbbP89YvAxgbOU4M2cNFjcEHlJQM/xEP7hT
Qi/8cy3pCjndaVWVABvAn9uAqTK4YiriOy/vYF9yY8cLREcnbD+yMpeIEv6FMUuo
nTvaECESRFsBYMQePM/Z1k6yomor4K9zN8LGNH4ORDoElFkuSSQXzfyue4pgKEVt
0kn7uQaPgzQIK6Ms5SXX76Su8o/bF7AcCuGo0rYc4tBLQlL0x0Vd2YvJInYuagbk
Ka+RaQIEfAGkTuumNAUlI6zvUUSuYp4JhrkzQqX3cXFwzjn2nWrhLhCZ7huXkJNR
tDGb9W4UcNEaDBeJVVWCXPE9X02NYDba42415WZdTF5EwxeeRxCc9HWNgDHihWWL
ZWEJsSln3ygzv6waIcI9
=nQQ+
-----END PGP SIGNATURE-----

--a8Wt8u1KmwUX3Y2C--
