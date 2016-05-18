From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH 0/2] Follow-ups for GUEoIPv6 patches
Date: Wed, 18 May 2016 16:31:46 -0700
Message-ID: <1463614306.2713.101.camel@intel.com>
References: <20160518173605.2608.42484.stgit@localhost.localdomain>
	 <1463606878.2713.68.camel@intel.com>
	 <CAKgT0UexDWi0axSiR7GWz5jz91oLbjqqz7zPNWL+jyPf4bfLew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/Dg8YstmWMiEyxsh8RMM"
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Netdev <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>,
	David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2241 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751386AbcERXbx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2016 19:31:53 -0400
In-Reply-To: <CAKgT0UexDWi0axSiR7GWz5jz91oLbjqqz7zPNWL+jyPf4bfLew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/Dg8YstmWMiEyxsh8RMM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-05-18 at 16:19 -0700, Alexander Duyck wrote:
> On Wed, May 18, 2016 at 2:27 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > On Wed, 2016-05-18 at 10:44 -0700, Alexander Duyck wrote:
> >> This patch series is meant to be applied after:
> >> [PATCH v7 net-next 00/16] ipv6: Enable GUEoIPv6 and more fixes for v6
> >> tunneling
> >>
> >> The first patch addresses an issue we already resolved in the GREv4
> and
> >> is
> >> now present in GREv6 with the introduction of FOU/GUE for IPv6 based
> GRE
> >> tunnels.
> >>
> >> The second patch goes through and enables IPv6 tunnel offloads for the
> >> Intel
> >> NICs that already support the IPv4 based IP-in-IP tunnel offloads.=C2=
=A0 I
> >> have
> >> only done a bit of touch testing but have seen ~20 Gb/s over an i40e
> >> interface using a v4-in-v6 tunnel, and I have verified IPv6 GRE is
> still
> >> passing traffic at around the same rate.=C2=A0 I plan to do further te=
sting
> >> but
> >> with these patches present it should enable a wider audience to be
> able
> >> to
> >> test the new features introduced in Tom's patchset with hardware
> >> offloads.
> >>
> >> ---
> >>
> >> Alexander Duyck (2):
> >>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ip6_gre: Do not allow segmentation=
 offloads GRE_CSUM is enabled
> >> with FOU/GUE
> >>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 intel: Add support for IPv6 IP-in-=
IP offload
> >
> > Dave, I have this series added to my queue.
>=20
> Jeff,
>=20
> If Tom's patches make it in for 4.7, then I would like to see if we
> could push these patches for "net" since essentially the first patch
> is a fix for Tom's earlier patches and the second is needed in order
> to really be able to test Tom's patches with a driver that actually
> supports a hardware offload.

Yeah, I was thinking that very same thing. =C2=A0I will wait to see if Dave
sucks this into 4.7 or not and plan accordingly. =C2=A0I also figured out t=
hat
your two patch series needs to have Tom's series applied before hand, so I
will be adding Tom's series to my tree just for testing purposes.
--=-/Dg8YstmWMiEyxsh8RMM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXPPtiAAoJEOVv75VaS+3OMfQP/0eQcvSYWZ68Cb+3lNy/htHZ
1/4A8FzzzvrecaIyZUB1IahJit0lnqRVtcPKEEfwpj+QpZnX9k4WUhRlBBhw5J8+
tHNkZPK5tMfxOO51VV2nPg/4R7XwYw6wQFk/x5d2qOeaY3TUfEOFGGEsr7dNNCnP
rb2OvpExUphXLTmWviBWCwBRPQqNeiX+4PI23LiXRBT/giBs+9Pnt6bZvEv03Gux
Of4Pr8c4BSsTkRw5nBDVgoVDHG0PoF8+KPbThpJ+FTExOoAODE+riY3C5DzUHNqu
MNY5tSnr2v6t3n5zLvhevRTb4Unmoc0duo+EsN4HfE0dRkAQE7+eALIbMuLHNBFs
0LhdYVEom/jOd8CiEoAupljpZGZvF59ZAXG4aGXeNip4Om2x6FQgtmY8b16LcaoD
aaeHH8IHXA7IUh5dkDukxZHxSd9C78l+qUmeUjAqHEA37FLzVPhJglESJjSsekmq
EoYtPNaJ0nJqBx6vaO/xn7cGoZdBIc4HUVBNBvwR/21/cYULX645274U8F1s6qn4
+AiKL0kDrMRYbaOM7//nRBXLL+CwjgBG77rtPZwLQ7S7wFmRHf7CzhdXk5hdjM47
UWegaOebc2FCYag7v2crurunG/n1HnUcy3/uKPmWnow1LmWFutsT5iOhVoFFigt1
0jGms+Cn7Ks1EXLeXOeg
=9oeV
-----END PGP SIGNATURE-----

--=-/Dg8YstmWMiEyxsh8RMM--
