From: Carsten Otto <c-otto@gmx.de>
Subject: Re: Intel e1000 fails after RAM upgrade
Date: Tue, 20 Dec 2005 01:47:52 +0100
Message-ID: <20051220004752.GA19114@carsten-otto.halifax.rwth-aachen.de>
References: <20051219195458.GA23650@carsten-otto.halifax.rwth-aachen.de> <4807377b0512191535i13d00b8chd97872b3e540e2b5@mail.gmail.com>
Reply-To: c-otto@gmx.de
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fdj2RfSjLxBAspz7"
Cc: linux-kernel@vger.kernel.org, NetDEV list <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750721AbVLTArz@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Content-Disposition: inline
In-Reply-To: <4807377b0512191535i13d00b8chd97872b3e540e2b5@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 19, 2005 at 03:35:57PM -0800, Jesse Brandeburg wrote:
> >   TDH                  <2000>
> >   TDT                  <2000>
> >   next_to_use          <6>
> >   next_to_clean        <0>
> > buffer_info[next_to_clean]
> >   dma                  <13024c002>
> >   time_stamp           <ffffd8c7>
> >   next_to_watch        <0>
> >   jiffies              <ffffe096>
> >   next_to_watch.status <0>
>=20
> are you using 4096 tx descriptors?  what is your MTU configured to?=20
> I'm confused because it appears you have 8192 (0x2000) descriptors but
> the driver only allows 4096

I am not. My MTU is 1500. At the moment the error message is:

  TDH                  <0>
  TDT                  <3>
  next_to_use          <3>
  next_to_clean        <0>
buffer_info[next_to_clean]
  dma                  <128d61202>
  time_stamp           <100026052>
  next_to_watch        <0>
  jiffies              <10002667c>
  next_to_watch.status <0>

I can't reproduce the 2000 value.

PS: The problem does not occur with Knoppix 3.9.

Thanks for the help,
--=20
Carsten Otto
c-otto@gmx.de
www.c-otto.de

--fdj2RfSjLxBAspz7
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFDp1S4jUF4jpCSQBQRAhwIAJsFyypYpSHfyRbnizITg2CMYtfosACfY2XE
2kYPsjJE534IQiVi5UiNvPg=
=ecjy
-----END PGP SIGNATURE-----

--fdj2RfSjLxBAspz7--
