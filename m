From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/3 net-next] e1000: Allocate pm_qos_req as needed
Date: Thu, 09 Apr 2015 17:08:23 -0700
Message-ID: <1428624503.2729.55.camel@jtkirshe-mobl>
References: <cover.1428622095.git.tgraf@suug.ch>
	 <99ad8b242a65a60e2a76e952b4c91de2b54a0013.1428622095.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+HEJ9U+yDuOkvogsLgyE"
Cc: davem@davemloft.net, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61341 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932217AbbDJAIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 20:08:35 -0400
In-Reply-To: <99ad8b242a65a60e2a76e952b4c91de2b54a0013.1428622095.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+HEJ9U+yDuOkvogsLgyE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-04-10 at 01:43 +0200, Thomas Graf wrote:
> e1000 is the only driver requiring pm_qos_req, instead of causing
> every device to waste up to 240 bytes. Allocate it for the specific
> driver.
>=20
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 15 +++++++++++----
>  include/linux/netdevice.h                  |  2 +-
>  2 files changed, 12 insertions(+), 5 deletions(-)

Small nitpick, it is e1000e not e1000 that you are modifying.

--=-+HEJ9U+yDuOkvogsLgyE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVJxR3AAoJEOVv75VaS+3O560P/1wLO0lkcGiB/1M2PmC4AyLt
PhOzki9uEqnvFujbmHmYt+Mus7LFfkR9OvPRW0r9JHBneAa3UBi596RKmFwV5LUt
eCIGk0ni1Cw1vhEIUlikC4s0kihmL8mDwu7yX39/OE9AzXG+ni7XcVhs9ZMwl3k4
xx7wSP+iYyjqANgdYGox5dVoTxO1uF+bjBV2Rke3PQ3xQuXya3yFCyQkFm2hqC+4
kIshDzWyTuaTjBZTKdoNPASTuOaIEknOa4MJCch4EcliabesZ7yO7s8oVvjE2BDv
zdxPgoGtHFOmRN2/Mu1Dg4d8q0IWnoL+E043hc6RMxIT99Z06cmK3A2/KPdGgtOT
IiY5q4ScZ8jqMdvzqs1CqpBLBYRbVMJX1ug67ptvhb72rCylWLNiSLuY16phNIof
BRsWPxqzjtVnhHWkXNeZM1Sv1EPQcVWjppKZ+5ChDr0rBs6pDjYKF4e5f/l4akKU
AsmZCBe1Coe0FSD2YTARoJFNVngi5L/Bv4orFMbs7yB8XpPu9AzRTG1uJxcn4b86
LjfWk3rX0d0Lt6A//En4FVoOa/ZbhNqo1X4up3ZZtxOoFQzZ17+hRoQ7bVc/uOtJ
cuma99URF70C/3nAOaX1iKfyDrxz+C6Ox7Fs6X442M3szgrNC2nQFlbvt6IOQB7b
RVntJdZl12ujiIf4LQQz
=y7zS
-----END PGP SIGNATURE-----

--=-+HEJ9U+yDuOkvogsLgyE--
