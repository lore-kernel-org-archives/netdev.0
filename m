From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [PATCH v2 net-next 5/5] drivers/net/ethernet: Fix non-kernel-doc
 comments with kernel-doc start markers
Date: Tue, 10 Jul 2012 14:37:32 -0700
Message-ID: <4FFCA09C.7000108@gmail.com>
References: <1341953604.2605.24.camel@bwh-desktop.uk.solarflarecom.com> <1341953819.2605.29.camel@bwh-desktop.uk.solarflarecom.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig551DE05583C075E24ED1B85A"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:29354 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751138Ab2GJVhd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 17:37:33 -0400
In-Reply-To: <1341953819.2605.29.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig551DE05583C075E24ED1B85A
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 07/10/2012 01:56 PM, Ben Hutchings wrote:
> Convert doxygen (or similar) formatted comments to kernel-doc or
> unformatted comment.  Delete a few that are content-free.
>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |    9 -
>  .../net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h    |    4 +-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h   |    3 +-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |    3 +-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h    |    3 +-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h     |   36 +-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c  |    5 +-
>  drivers/net/ethernet/broadcom/cnic.c               |    4 +-
>  drivers/net/ethernet/brocade/bna/bfa_cee.c         |   61 +---
>  drivers/net/ethernet/brocade/bna/bfa_cs.h          |   34 +--
>  drivers/net/ethernet/brocade/bna/bfa_defs.h        |   63 +---
>  drivers/net/ethernet/brocade/bna/bfa_defs_cna.h    |   15 +-
>  .../net/ethernet/brocade/bna/bfa_defs_mfg_comm.h   |   35 +--
>  drivers/net/ethernet/brocade/bna/bfa_defs_status.h |    3 +-
>  drivers/net/ethernet/brocade/bna/bfa_ioc.c         |  393 +++++++-----=
--------
>  drivers/net/ethernet/brocade/bna/bfa_ioc.h         |   43 +--
>  drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c      |   48 +--
>  drivers/net/ethernet/brocade/bna/bfa_msgq.c        |    4 +-
>  drivers/net/ethernet/brocade/bna/bfi.h             |   81 +---
>  drivers/net/ethernet/brocade/bna/bfi_cna.h         |   42 +--
>  drivers/net/ethernet/brocade/bna/bfi_enet.h        |  107 ++----
>  drivers/net/ethernet/brocade/bna/bfi_reg.h         |    4 +-
>  drivers/net/ethernet/brocade/bna/bna.h             |   51 +--
>  drivers/net/ethernet/brocade/bna/bna_enet.c        |   15 +-
>  drivers/net/ethernet/brocade/bna/bna_hw_defs.h     |   33 +--
>  drivers/net/ethernet/brocade/bna/bna_tx_rx.c       |   17 +-
>  drivers/net/ethernet/brocade/bna/bna_types.h       |   66 +---
>  drivers/net/ethernet/brocade/bna/bnad.c            |   12 +-
>  drivers/net/ethernet/brocade/bna/bnad.h            |    4 +-
>  drivers/net/ethernet/ibm/ehea/ehea_qmr.c           |    4 +-
>  drivers/net/ethernet/intel/e1000/e1000_main.c      |    9 +-
>  drivers/net/ethernet/micrel/ks8851_mll.c           |    6 +-
>  drivers/net/ethernet/neterion/vxge/vxge-main.h     |    3 +-
>  drivers/net/ethernet/nvidia/forcedeth.c            |    3 +-
>  drivers/net/ethernet/sfc/mcdi_pcol.h               |    3 +-
>  drivers/net/ethernet/ti/davinci_emac.c             |    8 +-
>  36 files changed, 342 insertions(+), 892 deletions(-)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>



--------------enig551DE05583C075E24ED1B85A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBCgAGBQJP/KCcAAoJEOVv75VaS+3OGLwP/2IMlONBV6w0Go7nl/N2KrmB
L5l7GyZT6+9hF+Y41kDXanUNxn3FQR6kmkLQCCL7amnuAkYPrH4sf+Zv8AiL68MG
paz8J3vlwWONrCtPR6FA/ExY3CIXDcTpl+aOPEIID56I3WMtP+4nknutWjp9hP6g
KTI7Q8rX01AXn7t1HYtpVjS5rTLWqdPwRCeEKnbHSaswdYUMgltWgL/O8vq40laH
KQ4BKGtqjlaq7FWEo6HZ6PETIEnmSYJfwKpqKp+xqoVWFiPOiSkRZXf6UFbfYGcM
pQ1xR9ar8XLyao5YyMdjRS+d8j0cD+gngdrQsRXa+9rwoTbbVv0+Gpbuv7NScfjE
MZ1P2EAJtQAy9iidP+g5mj/miWYAGA7ht46VygUva5dsdxjS1ANuNFbbFvDPD1uW
sMZlXHjcVnv8uQQd0uxCWv+JounUCYcq2n8fHgJycoZf87+MbbwKNzbvKHaGxb47
laxR9lYhinJd7GqaJdHe1pxAFtt/Dgkco4KjPWnp3E1PpbUx4PlVK5XeZM1sQCOv
EkMUwVIeYVFrdkbGrkQHWoJ4MUHN8r7KBu2hDaTtCVxv/ynsvbKL5pR0UnllRxML
XscsyoAW6pZIfhSU/YRa6PVNnXQQ2S68SlOvuMCDlCfBWlxUxP0fsuSMAYxYHkUB
zfzFQDjpLbzj2PZmKmZN
=Pn5c
-----END PGP SIGNATURE-----

--------------enig551DE05583C075E24ED1B85A--
