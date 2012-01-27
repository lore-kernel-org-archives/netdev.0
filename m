From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net V4 0/2] igb: ptp hardware clock
Date: Thu, 26 Jan 2012 20:24:53 -0800
Message-ID: <1327638293.2729.43.camel@jtkirshe-mobl>
References: <cover.1327161325.git.richardcochran@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ugPRRtdmEdBe85OIoKap"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>,
	"Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:58751 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752629Ab2A0EYz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 23:24:55 -0500
In-Reply-To: <cover.1327161325.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ugPRRtdmEdBe85OIoKap
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2012-01-21 at 17:03 +0100, Richard Cochran wrote:
> * ChangeLog
> ** V4
>    - Use standard kernel cyclecounter/timecounter infrastructure
>      instead of a home grown counter overflow implementation.
> ** V3
>    - Driver compiles even without CONFIG_PTP_1588_CLOCK.
>    - Timestamping always works, even when PTP code missing or fails.
> ** V2
>    - Fixed wrong bit shifting in the 82576 code.
>    - Explained the timestamp locking with a comment in the code.
>    - Preserved the comments from the original timecompare implementation.
>    - Added an additional test within the overflow counter code to fix
>      a race condition. Details of the problem are given in the commit
>      message.
>=20
> This patch series implements a PHC driver for the Intel 82576 and
> 82580 devices, as part of the igb driver.  Only the base clock
> operations are implemented. The hardware does have some ancillary
> features, but these can be easily added later.
>=20
> The first patch adds the PHC driver code as a new source module but
> does not link it into the main igb driver. Because the system time
> counter is not so very wide, the code uses the overflow counter from
> the cyclecounter/timecounter code. Every read operation maintains the
> overflow counter, as does a "delayed work" watchdog.=20
>=20
> The second patch removes the timecompare code and links in the new
> functions.
>=20
> I have tested the 82580 with good results. However, I don't have the
> 82576 and so would appreciate testing and feedback.
>=20
> Thanks,
> Richard
>=20
>=20
> Richard Cochran (2):
>   igb: add PTP Hardware Clock code
>   igb: offer a PTP Hardware Clock instead of the timecompare method
>=20
>  drivers/net/ethernet/intel/igb/Makefile   |    2 +-
>  drivers/net/ethernet/intel/igb/igb.h      |   20 ++-
>  drivers/net/ethernet/intel/igb/igb_main.c |  167 +------------
>  drivers/net/ethernet/intel/igb/igb_ptp.c  |  388 +++++++++++++++++++++++=
++++++
>  4 files changed, 407 insertions(+), 170 deletions(-)
>  create mode 100644 drivers/net/ethernet/intel/igb/igb_ptp.c
>=20

Added Aaron Brown to the thread

Richard-

Did you compile test?  Why I ask is our validation team is getting the
following errors when trying to compile in PTP support:

---------------------------
drivers/net/ethernet/intel/igb/igb_ptp.c: In function =C3=A2igb_ptp_init=C3=
=A2:
drivers/net/ethernet/intel/igb/igb_ptp.c:266: error: =C3=A2THIS_MODULE=C3=
=A2 undeclared (first use in this function)
drivers/net/ethernet/intel/igb/igb_ptp.c:266: error: (Each undeclared ident=
ifier is reported only once
drivers/net/ethernet/intel/igb/igb_ptp.c:266: error: for each function it a=
ppears in.)
make[5]: *** [drivers/net/ethernet/intel/igb/igb_ptp.o] Error 1
make[4]: *** [drivers/net/ethernet/intel/igb] Error 2
make[4]: *** Waiting for unfinished jobs....
make[3]: *** [drivers/net/ethernet/intel] Error 2
make[2]: *** [drivers/net/ethernet] Error 2
make[1]: *** [drivers/net] Error 2
make[1]: *** Waiting for unfinished jobs....
make: *** [drivers] Error 2
-------------------------------

Cheers,
Jeff

--=-ugPRRtdmEdBe85OIoKap
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPIicVAAoJEOVv75VaS+3OYM8P/3Ys8HvNvZ1BlYkXJnO3zcpf
fl6MW4HnxEQcQAX1Pv2443fuZabapi4v3EP9JrdFg0jBDDklglTlaEsK5X5hfo7Z
LwtFcy0nrx/o4csmXfFCP5nJ6AJ+maU2B3Yuyi8v/8lQz10gmpk4BuvpEab8oCxg
ZVHY4vnH4/9ORLnEvJtr1n2YdrYGJ0oU5xpiFvnp4+oO1ImUa/YgpTN+94Z860Di
BLFk14xMPgiOw7tcx5Y+cOKywlDo83aC3Si9KnFz5BKwR5cex+j4T0QQbVOR/LLk
7XgnD9qCw2LvgGVdp3qmXWaDKsgEjxhV7qgYDfBG+sjArg+/B5VhREO8TYrxVq0N
TwEn72rnZV/GQaYpgSzsgWA+8IcRrCQSuzzW4a2rnPIcOlgjw0EMXH1y+CFpvMbM
jfBY4oKUXBBZPW8xJ/pQNLIOLYYmtno7KuAACMbsa3oyfO09qD2PaVTl8wQPk093
7pPbcOWVviAZ8Q/pY4eFWP2JXeNLNInoWO73Xtww3AEDby1V/UxbDbA28qeVb0oR
IWbkqQ5KpGFJl9zohFjwBBvy24JulBQMLbaB4rxW7/jwRQ8obJEwXQvn3Ehp1Hep
fiZNSk73XxT3uXjAktaJES3oGnUvHr5OlOVy9TiheVZIba/Jk215AbbNTnCWpcjC
r2wTvJIAB0aPBh9BV+BR
=mYyS
-----END PGP SIGNATURE-----

--=-ugPRRtdmEdBe85OIoKap--
