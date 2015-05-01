From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/3] igb, ixgbe(vf), i40e(vf), fm10k: Use dev_kfree_skb
 in Tx cleanup path
Date: Thu, 30 Apr 2015 18:46:51 -0700
Message-ID: <1430444811.2669.141.camel@jtkirshe-mobl>
References: <20150430205423.1512.13487.stgit@ahduyck-vm-fedora22>
	 <20150430205818.1512.11765.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-A+j+TaenJJWbAUT0Lidn"
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	Dept-HSGLinuxNICDev@qlogic.com, sony.chacko@qlogic.com,
	intel-wired-lan@lists.osuosl.org, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:52442 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750809AbbEABqx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 21:46:53 -0400
In-Reply-To: <20150430205818.1512.11765.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-A+j+TaenJJWbAUT0Lidn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-04-30 at 13:58 -0700, Alexander Duyck wrote:
> This change replaces the use of either dev_kfree_skb_any or
> dev_consume_skb_any in the Tx cleanup paths of these drivers with
> dev_kfree_skb.  There isn't any need for the "_any" version of these
> functions since the NAPI cleanup context is not a hard irq context.
>=20
> This change allows us to drop one function call from the clean-up path
> since dev_kfree_skb_any was just calling into dev_kfree_skb in these
> paths
> anyway.
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
>  drivers/net/ethernet/intel/fm10k/fm10k_main.c     |    2 +-
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c       |    2 +-
>  drivers/net/ethernet/intel/i40evf/i40e_txrx.c     |    2 +-
>  drivers/net/ethernet/intel/igb/igb_main.c         |    2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    2 +-
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    2 +-
>  6 files changed, 6 insertions(+), 6 deletions(-)



--=-A+j+TaenJJWbAUT0Lidn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVQtsLAAoJEOVv75VaS+3Oo3EP/jA3TLoIIFptpp88T7piS25p
FlgLyu5QDPPpIge1iX2RRa8ZhKuvBVao8gc1YQkGEIF1JWGApdE8duW5Emllsfm1
ShoSXsmYh5DLw3nMjSQhHSyx/N2O+pKN7t/Jpl/oNgES8nRQacAAs7NBnwpVAp5+
49bNFZ+qJdjEfzGb3PXd6cp0OKaj7i3fpDJWEo52zW87KpQVTT/0BziJZ3ljEW7A
KUNVrlVa8oG3f5I44pdQ2l0XjP9Fg1uJyczizHioZnOPickiy8hEJQ/n9mg7cD5V
w/ucvpuQADQXtbgNHIR/GBS4Jjn8thmtmLr4yzOQxtAkJQAFLPiPM6x9L8oAcXo3
XWq+fJx2W48l/EV+G2ShA+fECx1O6nx6195RQHvgavj4rEZxVi8dhHxi/2C+0YnL
hugTdi/iP9BuLTLls1CQL6+aIlNM/2Lc3EH/XAEhApEjcfYIQ3kkjEy0WaEdPnLY
6ObJY0Huxfjg4MgXJO1js29v51Vl9OLZvPiogYtXpjTAqyjNGErtEDjTsYQw5tJH
FO9pI4sjqx/CF+y4YR42KFuGKh0gTx8b4aqUN1yxOdRaAvOF+MFlyXIcbrEbESbV
uPgt+iSYoQPNwDW/3K2UYxIET0DtEQ0ftkE4b8grs56ZNczfegLIt+ydKARfgf7B
cYIIuALe3Sv3I2cCLNQD
=CVEa
-----END PGP SIGNATURE-----

--=-A+j+TaenJJWbAUT0Lidn--
