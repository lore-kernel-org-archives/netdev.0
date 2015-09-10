From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during netdevice
 stats retrieval.
Date: Thu, 10 Sep 2015 16:29:51 +0200
Message-ID: <20150910142951.GA25217@calimero.vinschen.de>
References: <55EE81D8.4010008@gmail.com>
 <55F04F40.4040901@gmail.com>
 <20150909155404.GC19913@calimero.vinschen.de>
 <20150909155511.GD19913@calimero.vinschen.de>
 <55F07BBC.9020308@gmail.com>
 <20150909190805.GA26699@calimero.vinschen.de>
 <55F0BCB6.5030508@gmail.com>
 <55F0C5F5.4040101@gmail.com>
 <20150910084709.GB19486@calimero.vinschen.de>
 <55F1793C.50205@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="TB36FDmn/VVEgNH/"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Mike Massonnet <m8t@gandi.net>,
	Bernhard Walle <bernhard.walle@gmx.de>,
	Hendrik Scholz <hscholz@raisdorf.net>,
	Florian Rivoal <frivoal@xfce.org>
To: poma <pomidorabelisima@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:47884 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709AbbIJO3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 10:29:54 -0400
Content-Disposition: inline
In-Reply-To: <55F1793C.50205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sep 10 14:36, poma wrote:
> On 10.09.2015 10:47, Corinna Vinschen wrote:
> > On Sep 10 01:51, poma wrote:
> >> [PATCH v2] r8169: Fix sleeping function called during get_stats64
> >> http://www.spinics.net/lists/netdev/msg342490.html
> >> - the noise is still present
> >>
> >> Corinna, care to share kernel-core & kernel-modules you are testing wi=
th,
> >> to unravel the Gordian Knot?
> >=20
> > Somehow your initrd seem to refuse to pick up the new kernel module.
> > [...etc...]
>=20
> [PATCH v3] r8169: Fix sleeping function called during get_stats64, v2
> http://marc.info/?l=3Dlinux-netdev&m=3D144187488130444&q=3Draw
>=20
> # dracut --omit-drivers r8169 -f --kver 4.3.0-0.rc0.git11.1.fc24.x86_64
>=20
> - the noise is gone
>=20
> Tested-by: poma <pomidorabelisima@gmail.com>

Thanks for testing!


Corinna

--TB36FDmn/VVEgNH/
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV8ZPfAAoJEPU2Bp2uRE+g2L0P/RQTGMo+HkcjBvJspaDbMcPf
FrVVR9JUcy1dtxIUEvhH55TgEK0qDbst3zu/5t+ocNlYk1TmWCTpvlLluUZCp8lR
ufxFy+3G0zUTdbXC8XwJjj/Pw8pmiOG0mhHQr8BEWK0/HtnAyB0aortq8Dhxi/nN
f6qmv5rQUR46pWl/ttkArjLqyQiJCwvQpnoE/F1N/ApZ6hs1BgcrSn9vxWmD4VzU
yOVR0eXE7/t9V5TMSIuyA765iLKqySwdL4xy4eJhyyC17y+MRV9R2e8AFHXTeNOP
jvrLGUK7qN/nDVL0B9zLf3KokAxbTNWVL9TX3Hy0dVCv3cF1c1aVxST3sPWHtZdk
o7IFDvnneavLh9NyazCO2lDMWRUlfInpqGpwgHawvOVG6GR8VgTlbGrhuZCEilJb
5OqJKhUHMJHU0u4pitksQyhxHuRVlKLmRAxYj6GB0C5WfiJ59QqXSUlnqLi0mBF1
pWxw44yVMshCgPluP+dAVBerduF1VhEbDjxPin4RSR6nxrrE2n+zoCOce964si0A
peQ4n3dh3fEGY+Uo+ycr5EaQrqlUW1HNWwxTBq/DkY51GJ82ptBFoQXDIpQkvDBH
qP0/vOagkJ2sLbTIFe9/AAioDkndatFMea59CIoyf3/zwSOF6SqqVhBIU4CjrxAH
DlZlZgEqQXUhWdsiXRV0
=Q+OK
-----END PGP SIGNATURE-----

--TB36FDmn/VVEgNH/--
