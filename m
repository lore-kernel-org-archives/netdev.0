From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v8 8/8] net: e1000e: Adds hardware supported cross
 timestamp on e1000e nic
Date: Wed, 24 Feb 2016 12:22:44 -0800
Message-ID: <1456345364.2808.1.camel@intel.com>
References: <1456139726-3327-1-git-send-email-christopher.s.hall@intel.com>
	 <1456139726-3327-9-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-wS9stkXUJ9Z3aXLvDnMu"
Cc: x86@kernel.org, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	kevin.b.stanton@intel.com, kevin.j.clarke@intel.com
To: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	tglx@linutronix.de, richardcochran@gmail.com, mingo@redhat.com,
	john.stultz@linaro.org, hpa@zytor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456139726-3327-9-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-wS9stkXUJ9Z3aXLvDnMu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-02-22 at 03:15 -0800, Christopher S. Hall wrote:
> Modern Intel systems supports cross timestamping of the network
> device
> clock and Always Running Timer (ART) in hardware.=C2=A0 This allows the
> device time and system time to be precisely correlated. The timestamp
> pair is returned through e1000e_phc_get_syncdevicetime() used by
> get_system_device_crosststamp().=C2=A0 The hardware cross-timestamp resul=
t
> is made available to applications through the PTP_SYS_OFFSET_PRECISE
> ioctl which calls e1000e_phc_getcrosststamp().
>=20
> Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
> [jstultz: Reworked to use new interface, commit message tweaks]
> Signed-off-by: John Stultz <john.stultz@linaro.org>
> ---
> =C2=A0drivers/net/ethernet/intel/Kconfig=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 9 +++
> =C2=A0drivers/net/ethernet/intel/e1000e/defines.h |=C2=A0 5 ++
> =C2=A0drivers/net/ethernet/intel/e1000e/ptp.c=C2=A0=C2=A0=C2=A0=C2=A0 | 8=
5
> +++++++++++++++++++++++++++++
> =C2=A0drivers/net/ethernet/intel/e1000e/regs.h=C2=A0=C2=A0=C2=A0 |=C2=A0 =
4 ++
> =C2=A04 files changed, 103 insertions(+)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
--=-wS9stkXUJ9Z3aXLvDnMu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWzhEUAAoJEOVv75VaS+3OPCYQAIA1CJcLRdfvJ2KJaBe56juQ
iBYLFuneEDRQsc0ADglHlNtDiFm2vCJC2FRMcr+qfZ9lCnpW6wwbY08aUw1ZX/HN
6HgXmJBfb7EErzJv2HERrLeFdIC7FBQs4Cg9bZqy3JsiFAQ4qElPdPfthmafWX6l
FWzJiVA/JFqRjeeXsYke0d72t3NyYQiA9xmZpo0PpN4ro2Q+cGY11oLv9P+12TBV
n4UB+7mW3w235PrM+APPRUpDuBUHvbdQCaoZKFJJb0NGPITL7wX3tTqaCQ5SAGTr
dc/jLcKTFVrqKKrh0Nx62V5+HgD1SeDLhpS3piKd4CA8Ysj9l81krrta3lTgyIy0
C1hRHsKZDyFmpDW/zpFqg6EX+IJp1zhnfwMMix/IBjKA/+2h7Kkb91mujCepdNbz
GDRd6LGkftIZHKNfynrUXOr7zK9Z+MwOVK+kBjBDJvugk+6YicaP/zr37AGJ2F2R
RsHq7FSlHtDIwLs7rip0eqgJoaVK1lTkCHYC81R0Wuj6t0Kk5WkHI6P0eyWC9/Wt
+jT2zVU3gJo0giHkmjHxVHi38eA8tIwuo4PYiCyf2tdEZiq+yVeSSC5y0slRyF/i
A2E7W2XrvgyoXXafCFy+PoHNC/MvYswmsRkuUdWo8t/PrOqDIdbI0VecelGzqCc8
+XsDdFy8V9a4L1kHTT0z
=fJ9b
-----END PGP SIGNATURE-----

--=-wS9stkXUJ9Z3aXLvDnMu--
