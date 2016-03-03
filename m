From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 8/8] net: e1000e: Adds hardware supported cross
 timestamp on e1000e nic
Date: Thu, 03 Mar 2016 14:27:03 -0800
Message-ID: <1457044023.2936.2.camel@intel.com>
References: <1456978919-30076-1-git-send-email-john.stultz@linaro.org>
	 <1456978919-30076-9-git-send-email-john.stultz@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-I4vrhOAh0b6N4GFH9Uuo"
Cc: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	Prarit Bhargava <prarit@redhat.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	kevin.b.stanton@intel.com, kevin.j.clarke@intel.com, hpa@zytor.com,
	netdev@vger.kernel.org
To: John Stultz <john.stultz@linaro.org>,
	lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23532 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758508AbcCCW1F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2016 17:27:05 -0500
In-Reply-To: <1456978919-30076-9-git-send-email-john.stultz@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-I4vrhOAh0b6N4GFH9Uuo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-03-02 at 20:21 -0800, John Stultz wrote:
> From: "Christopher S. Hall" <christopher.s.hall@intel.com>
>=20
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
> Cc: Prarit Bhargava <prarit@redhat.com>
> Cc: Richard Cochran <richardcochran@gmail.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: kevin.b.stanton@intel.com
> Cc: kevin.j.clarke@intel.com
> Cc: hpa@zytor.com
> Cc: jeffrey.t.kirsher@intel.com
> Cc: netdev@vger.kernel.org
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
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

Since you are making changes to patch 6's title, then you should fix
this patch title as well, it should be:

[PATCH 8/8] e1000e: Adds hardware supported...
--=-I4vrhOAh0b6N4GFH9Uuo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW2Lo3AAoJEOVv75VaS+3O1a8P/0C083vGKmRhmmILkQ+13+02
DIJshrVJBTGnAkGTsrKwIfHhF32alAn/EOdMHKYF+mktXI/GYFbSZmZa9zkUu3qt
1q+TuUOEXSQDk5vqNBWR7xVnHvkOFF8w6F990tEiawoIhjK+F7VAIEdSyy2Auok5
9ChkOkW/rcaaSDaIFJKmrxZHjH3zpExXioW2nfa3PEuTRm2ZsSGCzSl95HJVwEfv
ZlN3GU+ycZ/ghZnP0pIALo/a7XaHqc3vDXPRXFcdhEeEwOK9Q5wP+ZoM8VyeyZ4v
M5yQqhIlJgUKF/U/5JdQySbxOrLsTwxoMIweu9Fu99TC9rb9GFvVtiAhtxkoozJY
n72w+5VJysLV54A0/gQVy0rXykmBewoCZ8jKHJDu25WvnNOfPf7FC9IXcOt7zBvm
lkbpaD0mj/VkeOdqA05IVNNKP1E3SmZJNSNnuUXjz54G3GP+crZatitPaT/bGiyB
OR7M5QTufmakbVLHw5ffJVA3GdlO4s1ajdRyhUmPLAntJM9jGjVcRlCafNy0DEuC
PeKW89EwMtdcAvyBC5aHBWGQLa3x1Mn0JF1JnlifeVtC0kvULS4aDw7JN2FYpm3D
HI0HFoeyzKA5uBeQuGKQQb8dfNrr6ee1d7wtaS2OKtjlJpC79vQJHxxmfppomG9M
i35BZsUXxy49iPHM000q
=8PkT
-----END PGP SIGNATURE-----

--=-I4vrhOAh0b6N4GFH9Uuo--
