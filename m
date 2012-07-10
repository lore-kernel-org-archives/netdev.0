From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [PATCH v2 net-next 4/5] drivers/net/ethernet: Fix (nearly-)kernel-doc
 comments for various functions
Date: Tue, 10 Jul 2012 14:38:52 -0700
Message-ID: <4FFCA0EC.4050705@gmail.com>
References: <1341953604.2605.24.camel@bwh-desktop.uk.solarflarecom.com> <1341953760.2605.28.camel@bwh-desktop.uk.solarflarecom.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enigC53D940A01AB0BD675CAA229"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49019 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752247Ab2GJVjD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 17:39:03 -0400
In-Reply-To: <1341953760.2605.28.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC53D940A01AB0BD675CAA229
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 07/10/2012 01:56 PM, Ben Hutchings wrote:
> Fix incorrect start markers, wrapped summary lines, missing section
> breaks, incorrect separators, and some name mismatches.  Delete
> a few that are content-free.
>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/ethernet/3com/3c501.c                  |    2 +-
>  drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |   68 +++-----
>  drivers/net/ethernet/atheros/atl1e/atl1e_main.c    |   70 +++-----
>  drivers/net/ethernet/atheros/atl1e/atl1e_param.c   |    2 +-
>  drivers/net/ethernet/atheros/atlx/atl1.c           |   41 ++---
>  drivers/net/ethernet/atheros/atlx/atl2.c           |   56 +++----
>  drivers/net/ethernet/atheros/atlx/atlx.c           |   10 +-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |    2 +-
>  drivers/net/ethernet/brocade/bna/bfa_cee.c         |   36 +---
>  drivers/net/ethernet/chelsio/cxgb3/sge.c           |    2 +-
>  drivers/net/ethernet/chelsio/cxgb3/t3_hw.c         |    2 +-
>  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |    2 +-
>  drivers/net/ethernet/ethoc.c                       |    4 +-
>  drivers/net/ethernet/freescale/fec.c               |    4 +-
>  drivers/net/ethernet/intel/e1000/e1000_hw.c        |    8 +-
>  drivers/net/ethernet/intel/e1000e/netdev.c         |    2 +-
>  drivers/net/ethernet/intel/igb/igb_main.c          |    1 +
>  drivers/net/ethernet/intel/igbvf/netdev.c          |    1 +
>  drivers/net/ethernet/intel/igbvf/vf.c              |    5 +-
>  drivers/net/ethernet/intel/ixgb/ixgb_main.c        |    6 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    |    3 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c      |    2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c       |   10 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   41 +++---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c       |   38 ++--
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c     |    8 +-
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |    6 +-
>  drivers/net/ethernet/micrel/ks8851_mll.c           |    2 +-
>  drivers/net/ethernet/micrel/ksz884x.c              |    2 +-
>  drivers/net/ethernet/neterion/s2io.c               |   10 +-
>  drivers/net/ethernet/nvidia/forcedeth.c            |    2 +-
>  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c    |   12 +-
>  .../ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c    |   10 +-
>  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   42 +++---
>  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c  |    4 +-
>  drivers/net/ethernet/sfc/net_driver.h              |    2 +-
>  drivers/net/ethernet/sfc/rx.c                      |    1 +
>  drivers/net/ethernet/smsc/smc911x.c                |    6 +-
>  drivers/net/ethernet/smsc/smc91x.c                 |    6 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |    2 +-
>  drivers/net/ethernet/tehuti/tehuti.c               |  177 ++++++++++++=
--------
>  drivers/net/ethernet/ti/davinci_emac.c             |   70 ++++----
>  drivers/net/ethernet/toshiba/spider_net.c          |    6 +-
>  drivers/net/ethernet/xilinx/ll_temac_main.c        |    2 +-
>  44 files changed, 378 insertions(+), 410 deletions(-)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>



--------------enigC53D940A01AB0BD675CAA229
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBCgAGBQJP/KDsAAoJEOVv75VaS+3O7iUQAIBTueOSS76g2/iPz3obX6Fz
zLwkfIahcw/YACBm0YvDmK5BlO1lqzEQisTl+Ozm2EI3CHrS/oEbMhJrIUAgWos1
9NGVhQFFsizRXScK1JJR5U8x/VlN1rh/JXH1nPJ2uPaplHpUM27C24FWInKljvl/
5T7uqK6/+wKMJ0AYhpXrH/YvJ1G4QCPZGsmATzbGPuzpWwhQLri3L7KeK33E/SL7
tqCr1PPCg4m12P1YN2eEpKP4iX2n+Ya0nWj4jQfr6RwGv3FEHKOMoKCwkf0ZluLt
KkV1webjSrihxWjeTGahRPp9mEk5+DGH7NLXiF18p0wxe3pn0ZhBblCQUmoQgf0S
csUO4eKP8fs/gBhwsDIhpEudiLNh1AXMH7XOBbMlRbN4PrvtnzbnzOK8UbMpbhJE
QPUzA7QnboPvxaNFrUH1rrb8vJCf5trkHA8c1Gc3SrmZid5As1UAw240WdASNEj5
ToQ65W9+ZaTlHnjNsy1JziwrTvXEzYVnbV5A2CwndVB7WKl6HcIanwN2N2uQK3t7
VAXwydZ1vsuzruKoIXy2bWJyST2CIMzM0958Rw/4Z3pC228Hcus+HLddArFYdPMD
P8drovfz48aeD9YCJKePgdjm4URLf9jq5bdqS48EmXTBFiN4tn61f3ut917ZP40p
OLT7MhavqjHXTGidziVr
=+d+G
-----END PGP SIGNATURE-----

--------------enigC53D940A01AB0BD675CAA229--
