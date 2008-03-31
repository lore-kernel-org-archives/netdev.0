From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [BUILD_FAILURE] linux-next: Tree for March 31 build fails with
 CONFIG_SLICOSS=y
Date: Tue, 1 Apr 2008 00:31:10 +1100
Message-ID: <20080401003110.d4834b07.sfr@canb.auug.org.au>
References: <20080331181118.7964d4a9.sfr@canb.auug.org.au>
	<47F0E456.5080201@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__1_Apr_2008_00_31_10_+1100_Bdaj1oqzY26=Pywn"
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>,
	Christopher Harrer <charrer@alacritech.com>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:34528 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750764AbYCaNbU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 09:31:20 -0400
In-Reply-To: <47F0E456.5080201@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Tue__1_Apr_2008_00_31_10_+1100_Bdaj1oqzY26=Pywn
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

On Mon, 31 Mar 2008 18:47:10 +0530 Kamalesh Babulal <kamalesh@linux.vnet.ib=
m.com> wrote:
>
> The kernel next-20080331 kernel build fails with Alacritech's IS-NIC giga=
bit ethernet
> driver on powerpc with allyesconfig (with # CONFIG_NOVFS is not set)
>=20
>   CC      drivers/net/slicoss/slicoss.o
> drivers/net/slicoss/slicoss.c: In function =E2=80=98slic_xmit_build_reque=
st=E2=80=99:
> drivers/net/slicoss/slicoss.c:933: error: =E2=80=98Stop=E2=80=99 undeclar=
ed (first use in this function)
> drivers/net/slicoss/slicoss.c:933: error: (Each undeclared identifier is =
reported only once
> drivers/net/slicoss/slicoss.c:933: error: for each function it appears in=
.)
> drivers/net/slicoss/slicoss.c:933: error: expected =E2=80=98;=E2=80=99 be=
fore =E2=80=98Compilation=E2=80=99
> drivers/net/slicoss/slicoss.c: In function =E2=80=98slic_link_event_handl=
er=E2=80=99:
> drivers/net/slicoss/slicoss.c:1420: error: =E2=80=98Stop=E2=80=99 undecla=
red (first use in this function)
> drivers/net/slicoss/slicoss.c:1420: error: expected =E2=80=98;=E2=80=99 b=
efore =E2=80=98compilation=E2=80=99
> drivers/net/slicoss/slicoss.c: In function =E2=80=98slic_if_init=E2=80=99:
> drivers/net/slicoss/slicoss.c:1848: error: =E2=80=98Stop=E2=80=99 undecla=
red (first use in this function)
> drivers/net/slicoss/slicoss.c:1848: error: expected =E2=80=98;=E2=80=99 b=
efore =E2=80=98Compilations=E2=80=99
> drivers/net/slicoss/slicoss.c: In function =E2=80=98slic_card_init=E2=80=
=99:
> drivers/net/slicoss/slicoss.c:2518: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c: In function =E2=80=98slic_timer_get_stats=
=E2=80=99:
> drivers/net/slicoss/slicoss.c:3269: error: =E2=80=98Stop=E2=80=99 undecla=
red (first use in this function)
> drivers/net/slicoss/slicoss.c:3269: error: expected =E2=80=98;=E2=80=99 b=
efore =E2=80=98compilation=E2=80=99
> drivers/net/slicoss/slicoss.c: In function =E2=80=98slic_link_upr_complet=
e=E2=80=99:
> drivers/net/slicoss/slicoss.c:3683: error: =E2=80=98Stop=E2=80=99 undecla=
red (first use in this function)
> drivers/net/slicoss/slicoss.c:3683: error: expected =E2=80=98;=E2=80=99 b=
efore =E2=80=98Compilation=E2=80=99
> drivers/net/slicoss/slicoss.c: In function =E2=80=98slic_eeprom_cksum=E2=
=80=99:
> drivers/net/slicoss/slicoss.c:3806: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c: In function =E2=80=98slic_rspqueue_init=E2=
=80=99:
> drivers/net/slicoss/slicoss.c:3901: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c:3901: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c: In function =E2=80=98slic_rspqueue_getnext=
=E2=80=99:
> drivers/net/slicoss/slicoss.c:3990: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c:3990: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c:4004: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c:4004: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c:4009: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c:4009: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c: In function =E2=80=98slic_cmdqmem_addpage=
=E2=80=99:
> drivers/net/slicoss/slicoss.c:4056: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c:4056: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c: In function =E2=80=98slic_cmdq_init=E2=80=
=99:
> drivers/net/slicoss/slicoss.c:4081: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c:4081: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c: In function =E2=80=98slic_cmdq_addcmdpage=
=E2=80=99:
> drivers/net/slicoss/slicoss.c:4184: error: implicit declaration of functi=
on =E2=80=98virt_to_bus=E2=80=99
> drivers/net/slicoss/slicoss.c:4224: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c:4224: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c:4230: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c:4230: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c: In function =E2=80=98slic_cmdq_getdone=E2=
=80=99:
> drivers/net/slicoss/slicoss.c:4271: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c:4271: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c: In function =E2=80=98slic_cmdq_putdone=E2=
=80=99:
> drivers/net/slicoss/slicoss.c:4287: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c:4287: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c:4289: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c:4289: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c: In function =E2=80=98slic_cmdq_putdone_irq=
=E2=80=99:
> drivers/net/slicoss/slicoss.c:4301: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c:4301: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c:4303: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c:4303: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c: In function =E2=80=98slic_rcvqueue_fill=E2=
=80=99:
> drivers/net/slicoss/slicoss.c:4425: warning: cast from pointer to integer=
 of different size
> drivers/net/slicoss/slicoss.c: In function =E2=80=98slic_rcvqueue_reinser=
t=E2=80=99:
> drivers/net/slicoss/slicoss.c:4504: warning: cast from pointer to integer=
 of different size

Strike two!  Again, these drivers need to build (or not try to build) for
all architectures ... Its out until you tell me the above is true.

#if defined(CONFIG_X86_64)
        hcmd->cmdsize =3D (ulong32) ((((ulong64) & ihcmd->u.slic_buffers.bu=
fs[1] -
                                     (ulong64) hcmd) + 31) >> 5);
#elif defined(CONFIG_X86)
        hcmd->cmdsize =3D ((((ulong32) & ihcmd->u.slic_buffers.bufs[1] -
                           (ulong32) hcmd) + 31) >> 5);
#else
        Stop Compilation;
#endif

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__1_Apr_2008_00_31_10_+1100_Bdaj1oqzY26=Pywn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFH8OekTgG2atn1QN8RArpTAJ46aXba7Ym/XBHQ8muBVJLefA7fewCeItXY
fi3StL/Z8d8sZKWqyhZZWgw=
=nt9o
-----END PGP SIGNATURE-----

--Signature=_Tue__1_Apr_2008_00_31_10_+1100_Bdaj1oqzY26=Pywn--
