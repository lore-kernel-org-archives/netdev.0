From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC PATCH 6/9] ethtool: Add support for toggling any of the
 GSO offloads
Date: Sat, 19 Mar 2016 01:42:51 +0000
Message-ID: <1458351771.2953.22.camel@decadent.org.uk>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
	 <20160318232516.14955.2907.stgit@localhost.localdomain>
	 <1458346684.2953.16.camel@decadent.org.uk>
	 <CAKgT0UfTVCfTFgVTtA2sq1fZKVatAk=ciFG-dBtfU-oZmsAyiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-h9MCHJT04B6xz53kaYaD"
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Edward Cree <ecree@solarflare.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:35621 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753879AbcCSBnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 21:43:03 -0400
In-Reply-To: <CAKgT0UfTVCfTFgVTtA2sq1fZKVatAk=ciFG-dBtfU-oZmsAyiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-h9MCHJT04B6xz53kaYaD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-18 at 17:30 -0700, Alexander Duyck wrote:
> On Fri, Mar 18, 2016 at 5:18 PM, Ben Hutchings <ben@decadent.org.uk> wrot=
e:
> >=20
> > On Fri, 2016-03-18 at 16:25 -0700, Alexander Duyck wrote:
> >=20
> > >=20
> > > The strings were missing for several of the GSO offloads that are
> > > available.=C2=A0=C2=A0This patch provides the missing strings so that=
 we can toggle
> > > or query any of them via the ethtool command.
> > >=20
> > > Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> > > ---
> > > =C2=A0net/core/ethtool.c |=C2=A0=C2=A0=C2=A0=C2=A03 +++
> > > =C2=A01 file changed, 3 insertions(+)
> > >=20
> > > diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> > > index 2966cd0d7c93..b3c39d531469 100644
> > > --- a/net/core/ethtool.c
> > > +++ b/net/core/ethtool.c
> > > @@ -82,9 +82,12 @@ static const char netdev_features_strings[NETDEV_F=
EATURE_COUNT][ETH_GSTRING_LEN]
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0[NETIF_F_TSO6_BIT] =3D=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0"tx-tc=
p6-segmentation",
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0[NETIF_F_FSO_BIT] =3D=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0"tx=
-fcoe-segmentation",
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0[NETIF_F_GSO_GRE_BIT] =3D=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0"tx-gre-segmentation"=
,
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0[NETIF_F_GSO_GRE_CSUM_BIT] =3D=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0"tx-gre-csum-segmentation",
> > All of the existing checksum offload names include the word "checksum"
> > in full, so I think the new names should do the same.
> It isn't a checksum offload though, it is a segmentation offload for a
> tunnel that has an outer checksum.=C2=A0=C2=A0I was hoping to avoid using=
 the
> word checksum as that might make it confusing as it is a segmentation
> offload, not a checksum offload.

Yes, but my point is that we haven't used the abbreviation "csum".

> > >=20
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0[NETIF_F_GSO_IPIP_BIT] =3D=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0"tx-ipip-segmentation",
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0[NETIF_F_GSO_SIT_BIT] =3D=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0"tx-sit-segmentation"=
,
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0[NETIF_F_GSO_UDP_TUNNEL_BIT] =3D=
=C2=A0=C2=A0=C2=A0"tx-udp_tnl-segmentation",
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0[NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT] =3D =
"tx-udp_tnl-csum-segmentation",
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0[NETIF_F_GSO_TUNNEL_REMCSUM_BIT] =3D "=
tx-remcsum-segmentation",
> > I think this should be "tx-tunnel-remote-checksum-segmentation", though
> > that is getting quite unwieldy.
> Right.=C2=A0=C2=A0As it is I think we might be coming up on the 32 charac=
ter
> limit for the strings.=C2=A0=C2=A0Replacing csum with checksum would prob=
ably
> push us over.

Right, I wasn't even thinking about the static limit! =C2=A0That does weigh
rather heavily in favour of abbreviation here.

Please do at least hyphenate "remcsum" though.

Ben.

--=20
Ben Hutchings
To err is human; to really foul things up requires a computer.
--=-h9MCHJT04B6xz53kaYaD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW7K6bAAoJEOe/yOyVhhEJE9YQAIFmNWTb0PYufg47V8eykFAO
Lz4Het/TP6rs9rS+5jL5iZf8y55LOyW/jqRgjNIavWZPUK43Rq50c6FtD64+VgCq
BDDVigTNXBH2ElukCgSna5mH0+/d8BfbXYVF9i8/xnr4J34li7SKz9FE2jr1bwTK
3yoClN3WnuVL15VCGKSCIUgRbUrm1vaorDQKdF6FzSJ/d/3RT9YAihEVS/LWBc5S
xCAmSbpf52LcbU0x49r+be236mqhawMsR3Pm4X9Pi/GmyprKezOGFgJtEPXPiKds
WVElERHqcb+7g8NNYnDhinhLj8h5G8udpI4nCbnocUAsv0C1whRoLUFLy8HBig+8
zcsMvX0fa+E+XgVmn2czBOcjH+D4gTZTF08Yl+YQ0gzN5zzJ9e1vguRBubz2+gSS
xjSD6SCrHmA6sKfG92MHADBBCoa1BObQCTOlw5hor40R7rIKzfzrKwyVnl/itfWY
hmcrCU61jS5JqLCtgdG1+c4J8j6O02oJInNdThV/aquFTyCAXYaiwQXByR0Gho9m
U/cmBGQr8fDaXG77wUegCN9R2D4r7U2xaqbvP6JVfGydIaH+QTU7YDTneSEyAvpI
2ju0BuLSxaqVjpUGsi5RdAj0tt4hUiuaCXPTrkkMDna/wq5vzrOj+AIBuxw4xa2U
2z8LoztMGJH96NLZ4GW9
=W1v1
-----END PGP SIGNATURE-----

--=-h9MCHJT04B6xz53kaYaD--
