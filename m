From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 2/5] net: add IEEE 802.15.4 partial implementation
Date: Sat, 30 May 2009 17:32:16 +0100
Message-ID: <1243701136.3818.22.camel@deadeye>
References: <20090526112157.GA19976@doriath.ww600.siemens.net>
	 <1243336988-20109-1-git-send-email-dbaryshkov@gmail.com>
	 <1243336988-20109-2-git-send-email-dbaryshkov@gmail.com>
	 <1243480131.16597.174.camel@deadeye>
	 <20090528084836.GA6793@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-vU94XdCir6vGDWYSnzLg"
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	slapin@ossfans.org, maxim.osipov@siemens.com,
	dmitry.baryshkov@siemens.com, oliver.fendt@siemens.com
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36890 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759784AbZE3QcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 12:32:20 -0400
In-Reply-To: <20090528084836.GA6793@doriath.ww600.siemens.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vU94XdCir6vGDWYSnzLg
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-05-28 at 12:48 +0400, Dmitry Eremin-Solenikov wrote:
> On Thu, May 28, 2009 at 04:08:51AM +0100, Ben Hutchings wrote:
> > On Tue, 2009-05-26 at 15:23 +0400, Dmitry Eremin-Solenikov wrote:
> > [...]
> > > diff --git a/include/net/ieee802154/af_ieee802154.h b/include/net/iee=
e802154/af_ieee802154.h
> > > new file mode 100644
> > > index 0000000..6eb7f51
> > > --- /dev/null
> > > +++ b/include/net/ieee802154/af_ieee802154.h
> > [...]
> > > +#ifdef __KERNEL__
> > > +#include <linux/skbuff.h>
> > > +#include <linux/netdevice.h>
> >=20
> > The struct declarations would be sufficient.
>=20
> Do you mean just:
> struct sk_buff;
> struct net_device;

Right.

[...]
> >=20
> > [...]
> > > +#define IEEE802154_FETCH_U64(skb, var)			\
> > > +	do {						\
> > > +		if (skb->len < IEEE802154_ADDR_LEN)	\
> >=20
> > I see what you did there...
>=20
> ???
[...]

This macro works with u64 values, not specifically addresses, which
happen to be 8 bytes long too.  I infer that someone search-and-replaced
instances of the literal 8 with IEEE802154_ADDR_LEN and wrongly replaced
this instance.

Ben.

--=20
Ben Hutchings
Logic doesn't apply to the real world. - Marvin Minsky

--=-vU94XdCir6vGDWYSnzLg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQBKIV+I79ZNCRIGYgcRAuXVAKDEeMDu1kHHnALaclTk4OlxQu3wQwCfUSWa
Vs48DRRlEQbe3WdGFNP5bsM=
=mRsa
-----END PGP SIGNATURE-----

--=-vU94XdCir6vGDWYSnzLg--
