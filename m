From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 2/4] e1000e/igb/ixgbe/i40e: fix message
 terminations
Date: Tue, 01 Apr 2014 18:45:41 -0700
Message-ID: <1396403141.2230.3.camel@jtkirshe-mobl>
References: <1396399939-18420-1-git-send-email-kubakici@wp.pl>
	 <1396399939-18420-3-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-pe1mB8CmJET2Vwp4V90A"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27312 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754466AbaDBBps (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2014 21:45:48 -0400
In-Reply-To: <1396399939-18420-3-git-send-email-kubakici@wp.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-pe1mB8CmJET2Vwp4V90A
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-04-02 at 02:52 +0200, Jakub Kicinski wrote:
> Add \n at the end of messages where missing, remove all \r.
>=20
> Reported-by: Joe Perches <joe@perches.com>
> Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c      |  2 +-
>  drivers/net/ethernet/intel/i40e/i40e_nvm.c      |  2 +-
>  drivers/net/ethernet/intel/i40e/i40e_ptp.c      |  4 ++--
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c     |  4 ++--
>  drivers/net/ethernet/intel/igb/e1000_i210.c     |  2 +-
>  drivers/net/ethernet/intel/igb/e1000_mac.c      | 13 ++++++-------
>  drivers/net/ethernet/intel/igb/igb_ptp.c        |  4 ++--
>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |  2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c    |  6 +++---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c    |  4 ++--
>  10 files changed, 21 insertions(+), 22 deletions(-)

Added to my queue, thanks!

--=-pe1mB8CmJET2Vwp4V90A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTO2vFAAoJEOVv75VaS+3OrlAP/iibxZhfW6cT5VsNnn64tbAV
Y0ldl5Mc9rVcD1wtenxf09EcillComiuDcPlLqPv2X4LM6nT2eJ6IQm9kOsANBS6
D5SOMU+59/9GhJvbc8/3WO3Prmqf7lu/QJvmUJrbShl+samhYOhqvrmZXmuARKGU
9v++6sKsB4MGvxt+2S/jUiE2nt2voIX8gasOozqVxDv5QpX+0d5lDugZ2Zg99tG3
QdsKs9CASZn8ITAYaw8LWjOeWE0FXKMdZpgAFC9WskgzpZKVraIrn6kXgZEeDZyg
JXNcUiIIuo1g8Kg+OsR1sp/XlCBHirlb5LNZ5scBpdg060iRKB3NUU1mqFyptWRc
5L2CHbvhHzT5v7RZKqfiVQ5nvq62x/NVOfxxU+N1Kf1o/NiFPRUjf3faAwScsVa9
L9ouCYO3N5Bb40pdy34uU2pzrnh/Qe8K2cbjwgTssMuC6u5JkGR0DMC19t99LQj0
JycmityZoWGkZ7z1C9Rl7OZAOcfdpj46zX/GcmSP/uKtXgpYSilGYK1LvMpNSX3U
nXb5YVEmsGL9mYXv3Tdk7axql2qSuyTyuPZiODwRLYnTKQvsN8CPoU4TyVEaZNXw
qbPIbiqzmJXbnadMUGF/9rk+nDZ0r215QzHs+0Zn23dBhegOalCUP/y2dFQZil6I
GO94lWov8qojeVDOMbnu
=2zyG
-----END PGP SIGNATURE-----

--=-pe1mB8CmJET2Vwp4V90A--
