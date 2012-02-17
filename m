From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH v2 2/2] adi: adapt to eth_hw_addr_random() and changes in arch/blackfin
Date: Fri, 17 Feb 2012 18:15:57 -0500
Message-ID: <201202171815.59846.vapier@gentoo.org>
References: <1329412171-20704-1-git-send-email-danny.kukawka@bisect.de> <CAMjpGUdAe66Nw16EyM1_dv4e8uHV02tcfqiuWL8ipeUrQ=HThg@mail.gmail.com> <201202171157.55585.danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2549883.sFHPnAKmL7";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Sonic Zhang <sonic.zhang@analog.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bob Liu <bob.liu@analog.com>,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201202171157.55585.danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2549883.sFHPnAKmL7
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Friday 17 February 2012 05:57:54 Danny Kukawka wrote:
> On Freitag, 17. Februar 2012, Mike Frysinger wrote:
> > On Thu, Feb 16, 2012 at 12:09, Danny Kukawka wrote:
> > > +                       netdev_warn(ndev, "Setting Ethernet MAC to a
> > > random one\n"); +                       eth_hw_addr_random(ndev);
> >=20
> > would it make sense to have the core dump the warning ?
>=20
> Maybe. Many drivers already print information about setting a random mac
> address to a netdevice. Some with printk, some via
> netdev_warn/netdev_info/netdev_dbg or netif_dbg and other with costum
> methods. I could unify this, in a next step with a netdev_info in
> eth_hw_addr_random(), if it's okay for David.

i think unification in the core makes sense.  it enforces consistency and=20
removes duplication.
=2Dmike

--nextPart2549883.sFHPnAKmL7
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJPPt+vAAoJEEFjO5/oN/WBgwwP/jmWJOdg1PsoX7FN4lGGa/B4
MBbfSHFhURJMg9YXIKzlF6rSgSYg1jm/9V5dxkwAgn6wawdirTAqOX8YpDvboz4D
RYXaFKSSTyRmM4PxmlpqInwcwvggTA3N/U3lb1PN7fTB9Xn7NQ1iYx0Va3flX6m4
yEQTx546rRif7LkMCJnlLUU8rpUXkwv0k6Ar5sUE0WDHo2AdtGqoTyWw2N6McrxG
sZFhm2Baf4QaOj4kfrDo0zVfCZfMmZHxEFGLrWCMgcu21DNr2TThgffinl2rd58Z
dXsQCpX6f63ziNFIXP30Nxs+HtmAWj8AiU5SvrWforV4GtibZfrxKBWNx+I7F5VT
7HVOuujxAcwsb7UgmZ20BJ/z4n9GkqCwd7YtAPzAouj8CTQsfugj+cajkCz4P+gC
1VPwASEPFrMsRbF1lcVpc3aLPo2qFEsGnV61FpUB0KjDMOIn2iHHceQy1ltExRAY
n5K6HDI0omuQnVee8vmKDT2ZnCnz+DJ3l/+MBlk3Flgk5kZ0X0O+nqlYqwJMjjmq
IlEHPkxNuAPk/AhgS9mtkprdLuJZqz8nKM3dHFIsOHI0fChV82iq33G5rVYQSj8Z
9+0Xki58BH5aRaBZ1V14OmotEqiAHXGv8xnlbvfQXWWkKJjhgJYwFxD9fTZ0upk+
OtscyVaTG5PA2QGBo+Z4
=2I5O
-----END PGP SIGNATURE-----

--nextPart2549883.sFHPnAKmL7--
