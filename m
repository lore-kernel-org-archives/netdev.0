From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 0/9][pull request] Complete drivers/net/ move
Date: Tue, 23 Aug 2011 19:39:47 -0700
Message-ID: <1314153587.2128.242.camel@jtkirshe-mobl>
References: <1314089149-27205-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110823.154157.105644491350157006.davem@davemloft.net>
	 <20110823.161209.503161978488308532.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-heVwpXF+7wfnxF0ab+/x"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:62522 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752028Ab1HXCjs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Aug 2011 22:39:48 -0400
In-Reply-To: <20110823.161209.503161978488308532.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-heVwpXF+7wfnxF0ab+/x
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-08-23 at 16:12 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 23 Aug 2011 15:41:57 -0700 (PDT)
>=20
> > From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date: Tue, 23 Aug 2011 01:45:40 -0700
> >=20
> >> The following series moves the FDDI, PPP, HIPPI, PLIP, SLIP and the cl=
eanup
> >> of the drivers/net/ Kconfig & Makefile's.  This series in addition mov=
es
> >> the 2 remaining drivers in drivers/net/pcmcia/ into their respective
> >> directories (arcnet & tokenring).  The last remaining change is to
> >> make the all the "new" Kconfig options introduced by the Ethernet
> >> drivers move to yes, so that current defconfig's will compile the expe=
cted
> >> drivers.
> >>=20
> >> The following are changes since commit ca1ba7caa68520864e4b9227e67f3bb=
c6fed373b:
> >>   Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git=
/jkirsher/net-next
> >> and are available in the git repository at:
> >>   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/next-organize m=
aster
> >=20
> > I pulled this, but because you changed FDDI and these other newly
> > moved subsystems from a "config FOO" into a "menuconfig FOO", it now
> > prompts for those too during the first oldconfig.
>=20
> I had to unpull, this breaks the build, see the skfddi errors below.
>=20
> Also, you can't change "config" into "menuconfig", it makes things
> that were previously buildable modular no longer able to be.
>=20
> include/config/auto.conf:2204:warning: symbol value 'm' invalid for FDDI
> include/config/auto.conf:3764:warning: symbol value 'm' invalid for ARCNE=
T
> include/config/auto.conf:4044:warning: symbol value 'm' invalid for TR
> include/config/auto.conf:4700:warning: symbol value 'm' invalid for PPP

Grrr, I did not see or find any reason for FDDI, ARCNET, Tokenring or
PPP to loaded as a module.  That was the reason for the change, sorry.

I was seeing the Group Heading for these technologies as just that,
headers (like Ethernet).  I will revert that change.

I will also fix up the new Kconfig options like I did for the new
Ethernet Kconfig options.  (default y).



--=-heVwpXF+7wfnxF0ab+/x
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOVGRzAAoJECTsCADr/EWUvgQIAInpthdgELSAlItxtHD+Vv17
sXJQ2Aw/WTw7PEZczSWJLrSNOHEziNKmEmqlDknC9ywE84K+1UuUSUT2bcOPuQ0k
xgJ3fbNNgKXwVdNLvQfmnuUyNJdQMIf7Jj/s0XomjEJ1XA98pW+DJmzESC2LzmEn
BrFDBPRQseNQPJJ7ebR2dHgJaTNqDrM5rfyaQG14zmZDt9fLdJKF6zDrBiFXJia+
IJ5gfOgMFFfYQCjb4tePsZke+ipqLT7Imbnf9qA0i8bSzNR9pnD22iPcwCfA32Rv
FJPOnbtudGaXPCq0QuW+0eQHoGXo8x2+X4BFQlrYjgNpRUnblLd4P1zRwcPcRRc=
=6l5q
-----END PGP SIGNATURE-----

--=-heVwpXF+7wfnxF0ab+/x--
