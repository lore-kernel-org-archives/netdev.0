From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 01/11] time: move the timecounter/cyclecounter
 code into its own file.
Date: Tue, 23 Dec 2014 13:03:38 -0800
Message-ID: <1419368618.2470.28.camel@jtkirshe-mobl>
References: <cover.1418504883.git.richardcochran@gmail.com>
	 <3698bac182b6c5aba4dd541afabc1a5d61db1d00.1418504887.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-LT4M64/PN8EN3uyxzMAl"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>,
	Miroslav Lichvar <mlichvar@redhat.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tom Lendacky <thomas.lendacky@amd.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3698bac182b6c5aba4dd541afabc1a5d61db1d00.1418504887.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-LT4M64/PN8EN3uyxzMAl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-12-21 at 19:46 +0100, Richard Cochran wrote:
> The timecounter code has almost nothing to do with the clocksource
> code. Let it live in its own file. This will help isolate the
> timecounter users from the clocksource users in the source tree.
>=20
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
For the Intel driver changes...

> ---
>  drivers/net/ethernet/amd/xgbe/xgbe.h        |    2 +-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x.h |    2 +-
>  drivers/net/ethernet/freescale/fec.h        |    1 +
>  drivers/net/ethernet/intel/e1000e/e1000.h   |    2 +-
>  drivers/net/ethernet/intel/igb/igb.h        |    2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h    |    2 +-
>  drivers/net/ethernet/ti/cpts.h              |    1 +
>  include/clocksource/arm_arch_timer.h        |    2 +-
>  include/linux/clocksource.h                 |  102
> ----------------------
>  include/linux/mlx4/device.h                 |    2 +-
>  include/linux/timecounter.h                 |  122
> +++++++++++++++++++++++++++
>  include/linux/types.h                       |    3 +
>  kernel/time/Makefile                        |    2 +-
>  kernel/time/clocksource.c                   |   76 -----------------
>  kernel/time/timecounter.c                   |   95
> +++++++++++++++++++++
>  sound/pci/hda/hda_priv.h                    |    2 +-
>  16 files changed, 231 insertions(+), 187 deletions(-)
>  create mode 100644 include/linux/timecounter.h
>  create mode 100644 kernel/time/timecounter.c



--=-LT4M64/PN8EN3uyxzMAl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUmdiqAAoJEOVv75VaS+3OzDwP/iW1qePSsNYO7e9xJvJ9LKXB
5M6MGNmBM7y6vJkjngen/lt1Cr0Uw6tuIx8urJPL93HeRm3WUl6f47/hsTRbQXPA
iy+gBEsWmOMt4DACKyjIm+ZTW95SZmUdlc42z6h5Lo0R5t26hClZ1qaJzgr76Skm
+El6kUVbeAAPuB+5csJHA/IRqUbUevw2JoYzpXML3224hoQE86ptlkxXBpBn7xjO
VZJQO/8DnuFDrbyPanu7hJJ+ot4jhwK7YvbmQRX6D3fx5mgH8PEh6Z+iAm4Q4rku
8yEqT9HfeYDxYaF/gWx/yhwnjpsqFfqDdev0aTsR+f3EGURixRN5Le5AUypS/uVu
EmgXn1QY5cDiLsdlBSPghvA3ypLryQUIvwdDDNB96IK0pajGcaYdafUaWFPt5qaV
GzWSnJrsv4pDkxD45143VbSsVfKdda219rGWS6S1gSJPZveo0YdedtM5n3is4iMn
JC0nDgF1YgKe42g6EFCMvyuzSMvyitjYMtZ01j4s29Baf/iLzvNeT/DSPh/Jv1XK
URiCem85gImPgFiZJZFhuFQKaSOqejvZjoibJ+MsmXGIdDR3Wh3SQXApru2wzUOb
f74fINz6BqtzRNsfwLlcrqvc7CrE4PrFvuSkPLyve/ZwuWEA8pRcz9TlkC19tQlT
CjM3L10FOdqoIx+riT1z
=JJai
-----END PGP SIGNATURE-----

--=-LT4M64/PN8EN3uyxzMAl--
