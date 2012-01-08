From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next V3 0/2] igb: ptp hardware clock
Date: Sat, 07 Jan 2012 17:02:39 -0800
Message-ID: <1325984559.2641.0.camel@jtkirshe-mobl>
References: <cover.1325964581.git.richardcochran@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-AM/LdGICpf7xei+lfrMd"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:51124 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752408Ab2AHBCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Jan 2012 20:02:52 -0500
In-Reply-To: <cover.1325964581.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-AM/LdGICpf7xei+lfrMd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2012-01-07 at 20:38 +0100, Richard Cochran wrote:
> * ChangeLog
> ** V3
>    - Driver compiles even without CONFIG_PTP_1588_CLOCK.
>    - Timestamping always works, even when PTP code missing or fails.
> ** V2
>    - Fixed wrong bit shifting in the 82576 code.
>    - Explained the timestamp locking with a comment in the code.
>    - Preserved the comments from the original timecompare
> implementation.
>    - Added an additional test within the overflow counter code to fix
>      a race condition. Details of the problem are given in the commit
>      message.
>=20
> This patch series implements a PHC driver for the Intel 82576 and
> 82580 devices, as part of the igb driver.
>=20
> The first patch adds the PHC driver code as a new source module but
> does not link it into the main igb driver. Because the system time
> counter is not so very wide, the code implements an overflow counter
> in software. Every read operation maintains the overflow counter, as
> does a "delayed work" watchdog. Only the base clock operations are
> implemented. The hardware does have some ancillary features, but these
> can be easily added later.
>=20
> The second patch removes the timecompare code and links in the new
> functions.
>=20
> I have tested the 82580 with good results. However, I don't have the
> 82576 and so would appreciate testing and feedback.
>=20
> Thanks,
> Richard=20

Thanks Richard, I will add this series to my queue.

--=-AM/LdGICpf7xei+lfrMd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPCOsvAAoJEOVv75VaS+3OMhMP/AzQ6IvOluxaf+V3lpmRnl4w
R75W9Ih2lu4fpsSWPlaOfQ0TyoZkFRXRW2joL1b8NIP/I61AholeDMR8YzdBQgVZ
CyeuXXowGYX6+TtCuEXTO0Q1b/ScemCbKkBqHFbfO9dHNy3C3D7or+Hw0cSbrYL2
7yoRPWCyGtq2gFOS8NIxWz/2ssj3hiNwqrm4KMch2E4qX9U8u9zBresacBtgF9oP
i4J6OKYcBSghd71XoszM5SPl7wv4c4S8mzebjHqhAp1UcQudnNhefvwJy6yYY0cU
uK1OZPLSjTevqq/hCR+Pm2ZcW6HEp0wTf49PU2sR7MHVAa5urTif/GXUWPa68LLs
pXrFBFEKhNfHLz13YhH12KoiOnCNPPhWPbRm80Ch163r3MQsH1j6c0uFGid1XBdG
cattz3dtVNuuC5tL/fzmhzDxHWCJPfzHfZ6VrEm7EBuBf9X+tfSsz3wJjFnM2QVL
d/pNT8pWHIBTaO9F4r69RFFr6rgokrpL2vjnFitFmkYz3tIOPE2DR0kszIlr1lar
fo3epTdJKPnxLMTyNkqTiNmK76fgIQraH2Rg2tLMKq/q1kDrYv0v4gTVBl0vddaj
+Io0uB+Bbun3JYYHXM21BbfJntzy825+N85LWQ6m8Yg1zwbVwEZ582BMqodqA40l
bM2jMdoMFwsWGsrh9lH7
=boDA
-----END PGP SIGNATURE-----

--=-AM/LdGICpf7xei+lfrMd--
