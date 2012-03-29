From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: bpf_slow_path: sibling call to `skb_copy_bits' not allowed
 multiple TOCs (ppc)
Date: Thu, 29 Mar 2012 14:30:40 +1100
Message-ID: <20120329143040.6568ff46a45e6bd10d428473@canb.auug.org.au>
References: <CAP=VYLqwbjNDQ-TTbs_6cH4X2MMzy=MAFy4=R116zGL8a6qUag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__29_Mar_2012_14_30_40_+1100_f5hVC7kYy1MacNUS"
Cc: netdev <netdev@vger.kernel.org>, linuxppc-dev@ozlabs.org,
	linux-next@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <CAP=VYLqwbjNDQ-TTbs_6cH4X2MMzy=MAFy4=R116zGL8a6qUag@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__29_Mar_2012_14_30_40_+1100_f5hVC7kYy1MacNUS
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Paul,

On Wed, 28 Mar 2012 20:54:56 -0400 Paul Gortmaker <paul.gortmaker@windriver=
.com> wrote:
>
> coverage.   Even in the absence of the skb error, it still fails to link =
with:
>=20
>     "powerpc-linux-ld: TOC section size exceeds 64k"
>=20
> i.e. it never links into anything a person could actually try and boot an=
yway.
>=20
> So, just knowing "yes that is bogus because you've got a giant kernel
> with multiple TOC" would be useful information here.

This last message has been known for a long time and would require us to
change the way we link the kernel to fix.  I had a go at it a year or so
ago, but ran into binutils bugs :-(

The other message may be a result of the TOC section size problem, but I
am not sure.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__29_Mar_2012_14_30_40_+1100_f5hVC7kYy1MacNUS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPc9dgAAoJEECxmPOUX5FEERYQAJzFfKRzt8dpA3LYf3NH3OX7
0ZP7iugBed2JQvJB6HRFzLnzmqcVZYRV1RQan6X0K6Z0P+HNyhdeHITirtNE7Xuj
yWOdLxz8+0XUBHrxAgsEMaTAYLHow13wcTxV4pCYWMCNyn11/ZkkHPf4K3apc+N8
C6GE9nH2PBjJvXnu6YlQmeeb2NGBih6FN9D4f9YCL1m+uYzahnJhLb4LjBvrW4WI
qJiL/UzGT+qq83Sf25HrhQa3hXUc+Gzo3LAZ1U38yotZCaRHhIpnjzzJVZakrZ3P
E7t78/goPI+LsUKr/BBfRHC9PR4Wj/IzOV+42O6hpQg15iZtqlK2gHk6ko+TWEiT
vA/pKBIzOoysrI1ijRH49CqGJEaHd+1hwVTDdtug8xYSFRu4aGQM7cLg4LebXMyU
qpV3WWzCvUnDDIElE4Vb9MPsyPV7nBckTGRT7BS6wJCmlXE/8qukA5neaaITnJty
UlBOmQQIXww1l0yRnR9K9zovIDo5IPv7iTih7rlzSW9Qf8gIXb4VHdywvc+EE9Bg
OiTqGTmGJo1PkqWujNwUc9K+aTilh2KtJRwggbGcBJ+oId2UTbw66LW+pp/RJd25
cebkJPNMNkmxVYEvhDoyELNxbnV6zFnYbdCJLDNSGxH8kxIiRyVJd9m6WeqWAy7H
ymp2+d/nt8HBJF/mkuSb
=R7bv
-----END PGP SIGNATURE-----

--Signature=_Thu__29_Mar_2012_14_30_40_+1100_f5hVC7kYy1MacNUS--
