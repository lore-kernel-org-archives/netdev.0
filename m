From: Ian Kumlien <pomac@vapor.com>
Subject: Re: [BUG] Sky2 driver in 2.6.22-rc5-git1-cfs-v17
Date: Fri, 22 Jun 2007 04:45:25 +0200
Message-ID: <1182480325.7032.13.camel@localhost>
References: <1182459092.7032.11.camel@localhost>
	 <20070621185711.7dc9fe88@oldman>
Reply-To: pomac@vapor.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-1rtw101nTPLdW+T79yTe"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxfep04.bredband.com ([195.54.107.79]:57322 "EHLO
	mxfep04.bredband.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbXFVCyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 22:54:47 -0400
Received: from ironport2.bredband.com ([195.54.107.84] [195.54.107.84])
          by mxfep03.bredband.com with ESMTP
          id <20070622024526.OCUN18298.mxfep03.bredband.com@ironport2.bredband.com>
          for <netdev@vger.kernel.org>; Fri, 22 Jun 2007 04:45:26 +0200
In-Reply-To: <20070621185711.7dc9fe88@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-1rtw101nTPLdW+T79yTe
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On tor, 2007-06-21 at 18:57 -0700, Stephen Hemminger wrote:
> Redirected of LKML,  netdev is the proper list.

Thanks =3D)

> On Thu, 21 Jun 2007 22:51:32 +0200
> Ian Kumlien <pomac@vapor.com> wrote:
>=20
> > Hi,=20
> >=20
> > recently have started to see this in my dmesg:
> >=20
> > NETDEV WATCHDOG: eth0: transmit timed out
> > sky2 eth0: tx timeout
> > sky2 eth0: transmit ring 449 .. 408 report=3D449 done=3D449
> > sky2 eth0: disabling interface
> > sky2 eth0: enabling interface
> > sky2 eth0: ram buffer 48K
> > sky2 eth0: Link is up at 1000 Mbps, full duplex, flow control rx
> >=20
> > I'm not using MSI since it seems to have caused problems in the past.
> >=20
> > I run with a 9k mtu
> >=20
> > sky2 eth0: transmit ring 18 .. 489 report=3D18 done=3D18
> > ---- I assume ring max is 512 (ie 1-512) since:
> > 	Ring parameters for eth0:
> > 	Current hardware settings:
> > 	RX:             168
> > 	RX Mini:        0
> > 	RX Jumbo:       0
> > 	TX:             511
> > =09
> > 	And 489 + 41 - 18 =3D 512
> >=20
> > sky2 eth0: transmit ring 197 .. 156 report=3D197 done=3D197
> > sky2 eth0: transmit ring 480 .. 439 report=3D480 done=3D480
> > sky2 eth0: transmit ring 413 .. 372 report=3D413 done=3D413
> > sky2 eth0: transmit ring 320 .. 279 report=3D320 done=3D320
> >=20
> > Else, they are all off by 41.
> >=20
> > Is this a known bug?
> no

Damn =3DP

> > Comments? ideas?
> >
> which chip version. probably Yukon EC that seems to be the only one
> that does gigabit with Ram buffer.

sky2 0000:02:00.0: v1.14 addr 0xdbffc000 irq 18 Yukon-EC (0xb6) rev 2

> Does it work alright if you set transmit ring size smaller with ethtool?
> There might be an off-by-one bug in the worst case calculations about
> list element usage.

I tried this... but not with a specific size, i think i did 480, and yes
it timed out... any ideas on a more educated value?

--=20
Ian Kumlien <pomac () vapor ! com> -- http://pomac.netswarm.net

--=-1rtw101nTPLdW+T79yTe
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7-ecc0.1.6 (GNU/Linux)

iD8DBQBGezfF7F3Euyc51N8RAp8kAJ0Utmo3GdlfG/p+JD4Y4bKAl/nW3QCfe8rt
8szxaQWs1tClkgriRreBFGE=
=ZufB
-----END PGP SIGNATURE-----

--=-1rtw101nTPLdW+T79yTe--
