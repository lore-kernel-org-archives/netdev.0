From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] drivers/net/ethernet/broadcom/bnx2.c
Date: Fri, 02 May 2014 17:26:14 +0100
Message-ID: <1399047974.24523.16.camel@deadeye.wl.decadent.org.uk>
References: <5361C29C.5060808@taghos.com.br>
	 <1398922768.3056.4.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <53627814.7090106@taghos.com.br>
	 <1398965975.3056.40.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <53629752.6030606@taghos.com.br>
	 <1398972728.3056.49.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-q9pwReUR2z7Kog1N3ZLP"
Cc: "Magnos A. Hammes" <magnos@taghos.com.br>, netdev@vger.kernel.org,
	"desenvolvimento@taghos.com.br" <desenvolvimento@taghos.com.br>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:59833 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754952AbaEBQ0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 12:26:21 -0400
In-Reply-To: <1398972728.3056.49.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-q9pwReUR2z7Kog1N3ZLP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-05-01 at 12:32 -0700, Michael Chan wrote:
> On Thu, 2014-05-01 at 15:49 -0300, Magnos A. Hammes wrote:
> > Yes, I have some udev rules that run at system boot, but the only
> > thing=20
> > I do is:
> >=20
> > /sbin/udevd --daemon
> > /sbin/udevadm trigger --type=3Dsubsystems --action=3Dadd
> > /sbin/udevadm trigger --type=3Ddevices --action=3Dadd
> > /sbin/udevadm settle
> >=20
> > Udev runs normally and returns no errors or warnings and dmesg shows=
=20
> > nothing weird.
> >=20
> > So, you think this may be a problem with my udev rules or a udev bug?
> >=20
> > I'm using udev version 182.
>=20
> udev is involved in locating and loading the firmware file.

It is usually not involved now.  The kernel tries to load files directly
from /lib/firmware.  Only if that fails and if
CONFIG_FW_LOADER_USER_HELPER is enabled, then it will issue a uevent
which udev may respond to (I think that may have been removed from udev
now).

Ben.

> On my
> system, I have /lib/udev/firmware.sh and a
> generic /lib/udev/rules.d/50-firmware.rules to make request_firmware()
> work.  Your system may be different.


--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.

--=-q9pwReUR2z7Kog1N3ZLP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU2PHJue/yOyVhhEJAQq90A/+KDl02nXokRYTcCTiNoxbpJP6kYTM1RQ5
5+GSmb36Zw9neez8vFaJb5pfQ07u22GADcN3ZukuOBISLBF8C0t/oArBH3Qv0hKa
55OgiU6nT2mltZEMW06CkIE3Jk/4Pu+BSkavoOap6psJFH3Q2O+dSQzDMko6H9uj
FeTYp92n5kXS2BTFe7+UzUmf8PLuydt8KSU2l2tDvdXYYiNRrR57wPgdRuI/e+mg
qu77axmZLS1Jz5U6JZm0YPKcu4cLxYE0bBFnobFL1Nc4GrAlZIS0clKA0cqNyNBJ
pul6HVewqM3KcCehGl2sBz+EttTWNQye5bZVyoxIUXWenh9y5ty2G/53tS5BAXuB
X4ZltrNTpulP6KGmuIrJcsStko5wrTlr6EcWHkIG9XNRxWsQ2tabmpKdmfzit+EA
ZH3insoLEMi7RZFT8VUPj9sI3rUxjJLz6bGkkHZ81s73dpyByK6N5EvMmWmXJOUF
ADV4Mf3DfDqwyY0fj7VWC5BjUGmBLWqKIcew9sgaKXX3mboH2ct8PYJ1fAJ2Ddy1
4otu3YBlFKgmbTX25WH/FyGx6hFhN/j0JnTCbrYKqzaa3ocT5JF2mOhAmFC4Kec0
jcdIToCZrvAwFcQzuKogEHbGQwnsyx8RZxMQ1IUoC9LJmWFoeCTiCpqtYuTeopBB
rhuJvGoSEGY=
=wzm9
-----END PGP SIGNATURE-----

--=-q9pwReUR2z7Kog1N3ZLP--
