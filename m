From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net] i825xx:xscale:8390:freescale: Fix Kconfig dependancies
Date: Fri, 04 Nov 2011 15:30:42 -0700
Message-ID: <1320445843.5386.16.camel@jtkirshe-mobl>
References: <1320229852-18161-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20111104.174159.1262489521924521081.davem@redhat.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-EO+RRvNN+dzmaOzywN7Q"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:46220 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932691Ab1KDWao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 18:30:44 -0400
In-Reply-To: <20111104.174159.1262489521924521081.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-EO+RRvNN+dzmaOzywN7Q
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-11-04 at 14:41 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Wed,  2 Nov 2011 03:30:52 -0700
>=20
> > i825xx and xscale are "sub" Kconfigs to NET_VENDOR_INTEL, so
> > NET_VENDOR_INTEL should contain ALL the dependencies of the
> > "sub" Kconfigs.
> >=20
> > Same with 8390 is a "sub" Kconfig to NET_VENDOR_NATSEMI, so
> > NET_VENDOR_NATSEMI needs to contains ALL the dependencies.
> >=20
> > Freescale Kconfig only had fs_enet as a sub Kconfig, and already
> > contained the needed dependencies, just cleaned up the dependencies.
> >=20
> > Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> Applied, but:
>=20
> > +		   XTENSA_PLATFORM_XT2000 || ZORRO
> > +		  =20
> >  	---help---
>=20
> I removed that extraneous white-space-only line before "--help--"
>=20

Sorry about that Dave, that was not intended.  Thanks

--=-EO+RRvNN+dzmaOzywN7Q
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJOtGeTAAoJEOVv75VaS+3OLJMP+gNa9Jq+ynvmwA9v1hLZzxiB
Yc22x5BnO6cKB8z+CX5JmBoMsukEJ72lzdvQsxKox0EBeDdjcuzVYp11eUINmGdx
dQ9KStRzfQCFdw9Wr7wMWoA1ORKR7967W3utjlVNC16r9GJV5X4x/lHzy1kyoj8o
0O0a1MEAZGOKp9RPCVGEq0YGy/Tge07Mub7qfu3qivCZIkF3t5CjrH1g9iB5xRBF
KtbySd+iX2tt/IJzYywZPoPIjk1i4hTej9euGlsYkdtBMCKryV+0jOr8YRiQZMSF
SGQ9rTuAX/gPSllrFD5uquUUw3qRYatQCMohMosJOEymLrrzAhmgTO3cllc0/KmL
JhDZQ5b4KoT3xayiyYgIw0ydp/ZVNklWJP9WjCGW3WF4iq9/jrzbbWJIfyKetcwR
yuMq2C3LBPPynwWCiW8ycNJ9BNiQqHbhy4ET8Haqz9j3CnaL7dJnPrHa/nF+NdtO
UXD0IphmytWVNiWer0XJpCyAz294ruQ4JmnVP4YDBIL/bhi3qETMd+C6suLHiF6d
9+RcLcfN2Pbq2ikNHgMoh/ifNTmMPk0YHtawGTe/VdUqg7sqX5d668jEiNe60uxT
NB9DRUnWNzq/DSVVhkKOjglugl8BwmSCBxtkVsXr6vtvrfAaGPW6R9OQc9Vz9yoS
/E0CXfCGjXwmzbbRctJM
=ZBxM
-----END PGP SIGNATURE-----

--=-EO+RRvNN+dzmaOzywN7Q--
