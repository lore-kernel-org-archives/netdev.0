From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v7 6/8] net: can: c_can: Disable pins when CAN interface
 is down
Date: Fri, 14 Nov 2014 16:49:39 +0100
Message-ID: <54662493.5040002@pengutronix.de>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com> <1415371762-29885-7-git-send-email-rogerq@ti.com> <5464CCFF.5010004@ti.com> <5466225D.2070202@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="3Qgtn8RItDe8Fhuq77fVU0j5cItNRjJXn"
Cc: wsa@the-dreams.de, tony@atomide.com, tglx@linutronix.de,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com, sergei.shtylyov@cogentembedded.com,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, wg@grandegger.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5466225D.2070202@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--3Qgtn8RItDe8Fhuq77fVU0j5cItNRjJXn
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/14/2014 04:40 PM, Roger Quadros wrote:
> DRA7 CAN IP suffers from a problem which causes it to be prevented
> from fully turning OFF (i.e. stuck in transition) if the module was
> disabled while there was traffic on the CAN_RX line.
>=20
> To work around this issue we select the SLEEP pin state by default
> on probe and use the DEFAULT pin state on CAN up and back to the
> SLEEP pin state on CAN down.
>=20
> Signed-off-by: Roger Quadros <rogerq@ti.com>

Wow! Some interations later this patch got quite nice and shiny :)
Applied all to can-next/master.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--3Qgtn8RItDe8Fhuq77fVU0j5cItNRjJXn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUZiSTAAoJECte4hHFiupUOkgQAIG3AwYUQAZhTkEDORjuX51J
i1Ilmgv69uErfPAyjgg4AOTdengrsEHH0Jz6CoItBZtMNB1rY/yy0B7GvmCRF9mU
4xbp58h6Ii3Vy50q5GDWzKmdgJE6IU30pj5D6BP2F10Ei3JmRL+XRc1R+kbz5mm+
BTPO38nvFMBU9UOvb4In/hg9NXnZeAXC15LvQWnY/1ldLWevnT/50Qaj0HsSZzsy
oALJMnKl0z5Gkm+nKfYlcggoj3B7RwZJ29+OS1W7jNNmyV9Wy8ezSos0IqI9ngDy
HWWOrDUaXxZEIszDdDMzVpllr0ilAmLC64Xlv3qvcE3sbXX46+XrsnXRtbDO17NJ
MsYlCfVWdam3Qm3SSrQFtbDATbjTMfjsgoaWimiVDgfee7EPR6cH1vNCZ7C5VFGQ
04DX+idu634zuZKgWug5/5VMoLksRBv5Yp5PFh28QA3UT58EWzD7oYTk04debeoF
lh1saxGZmsyGjiwsb77zhGS4NoeDa2rUgAnePrM0wV6YA9rx6gJkVUSB40WdZvne
5iz+j3B6sNe91vfvCP9FSlAyuS+iBoUS4CS7yZaM4XXOzxT8hDPyQDfXHz5sRuyz
LY6H+194bWu1pzHGU1sqL8ML5TwPJ4b37arfsWLhu0GIjgXjxuDq0212hfPD1e2F
C5GxZyNV6AyH6+x2J/Wd
=glMb
-----END PGP SIGNATURE-----

--3Qgtn8RItDe8Fhuq77fVU0j5cItNRjJXn--
