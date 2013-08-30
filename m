From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc-next 2013-08-30
Date: Fri, 30 Aug 2013 04:36:34 +0100
Message-ID: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="=-iZY49gTjkeiSuUQuAC85"
Cc: netdev <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34876 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753316Ab3H3Dgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:36:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-iZY49gTjkeiSuUQuAC85
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit d4fbdcfe93928fbcb7374ea490e41f7b69d95380=
:

  sfc: Use extended MC_CMD_SENSOR_INFO and MC_CMD_READ_SENSORS (2013-08-27 =
22:29:56 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

for you to fetch changes up to f7a6d2c4427790cc8695401576dc594fcce8fc80:

  sfc: Update copyright banners (2013-08-29 23:34:51 +0100)

1. A little more refactoring.
2. Remove the unnecessary use of atomic_t that you pointed out.
3. Add support for starting or queueing firmware requests from atomic
context.
4. Add hwmon support for additional sensors found on some new boards.
5. Add support for the EF10 controller architecture, the SFC9100 family
and specifically the SFC9120 controller.

Ben.

----------------------------------------------------------------
Alexandre Rames (1):
      sfc: Use a global count of active queues instead of pending drains

Ben Hutchings (12):
      sfc: Add support for new board sensors
      sfc: Refactor efx_mcdi_rpc_start() and efx_mcdi_copyin()
      sfc: Remove unnecessary use of atomic_t
      sfc: Implement asynchronous MCDI requests
      sfc: Document conditions for multicast replication vs filter replacem=
ent
      sfc: Allow efx_nic_type::dimension_resources to fail
      sfc: Initialise IRQ moderation for all NIC types from efx_init_eventq=
()
      sfc: Extend struct efx_tx_buffer to allow pushing option descriptors
      sfc: Add EF10 register and structure definitions
      sfc: Make efx_mcdi_{init,fini}() call efx_mcdi_drv_attach()
      sfc: Add support for Solarflare SFC9100 family
      sfc: Update copyright banners

Jon Cooper (2):
      sfc: Allow event queue initialisation to fail
      sfc: Prepare for RX scatter on EF10

Matthew Slattery (1):
      sfc: Allocate NVRAM partition ID range for PHY images

 drivers/net/ethernet/sfc/Kconfig         |    9 +-
 drivers/net/ethernet/sfc/Makefile        |    4 +-
 drivers/net/ethernet/sfc/bitfield.h      |    8 +-
 drivers/net/ethernet/sfc/ef10.c          | 3043 ++++++++++++++++++++++++++=
++++
 drivers/net/ethernet/sfc/ef10_regs.h     |  415 ++++
 drivers/net/ethernet/sfc/efx.c           |  175 +-
 drivers/net/ethernet/sfc/efx.h           |   26 +-
 drivers/net/ethernet/sfc/enum.h          |    4 +-
 drivers/net/ethernet/sfc/ethtool.c       |    6 +-
 drivers/net/ethernet/sfc/falcon.c        |    7 +-
 drivers/net/ethernet/sfc/falcon_boards.c |    4 +-
 drivers/net/ethernet/sfc/farch.c         |   28 +-
 drivers/net/ethernet/sfc/farch_regs.h    |    4 +-
 drivers/net/ethernet/sfc/filter.h        |    4 +-
 drivers/net/ethernet/sfc/io.h            |   24 +-
 drivers/net/ethernet/sfc/mcdi.c          |  461 ++++-
 drivers/net/ethernet/sfc/mcdi.h          |   45 +-
 drivers/net/ethernet/sfc/mcdi_mon.c      |  125 +-
 drivers/net/ethernet/sfc/mcdi_pcol.h     |    4 +
 drivers/net/ethernet/sfc/mcdi_port.c     |   25 +-
 drivers/net/ethernet/sfc/mdio_10g.c      |    2 +-
 drivers/net/ethernet/sfc/mdio_10g.h      |    2 +-
 drivers/net/ethernet/sfc/mtd.c           |    4 +-
 drivers/net/ethernet/sfc/net_driver.h    |   33 +-
 drivers/net/ethernet/sfc/nic.c           |    4 +-
 drivers/net/ethernet/sfc/nic.h           |   89 +-
 drivers/net/ethernet/sfc/phy.h           |    2 +-
 drivers/net/ethernet/sfc/ptp.c           |    4 +-
 drivers/net/ethernet/sfc/qt202x_phy.c    |    4 +-
 drivers/net/ethernet/sfc/rx.c            |   46 +-
 drivers/net/ethernet/sfc/selftest.c      |    4 +-
 drivers/net/ethernet/sfc/selftest.h      |    4 +-
 drivers/net/ethernet/sfc/siena.c         |   28 +-
 drivers/net/ethernet/sfc/siena_sriov.c   |    4 +-
 drivers/net/ethernet/sfc/tenxpress.c     |    2 +-
 drivers/net/ethernet/sfc/tx.c            |    8 +-
 drivers/net/ethernet/sfc/txc43128_phy.c  |    2 +-
 drivers/net/ethernet/sfc/vfdi.h          |    2 +-
 drivers/net/ethernet/sfc/workarounds.h   |   10 +-
 39 files changed, 4404 insertions(+), 271 deletions(-)
 create mode 100644 drivers/net/ethernet/sfc/ef10.c
 create mode 100644 drivers/net/ethernet/sfc/ef10_regs.h


--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-iZY49gTjkeiSuUQuAC85
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQEVAwUAUiATQmkILBsOca60AQqJwQf/XMpKy9L+RkuSa8JNToVZFEsTNWluHNK6
EcCIK2yUtsH16ojeO3xv28eYMwT7ZdugHolhyzkU295sfelOEtOrQPFB1AP+vfXL
VP3zU0zLh1tzr8xWDDhM7yr70x9vGO8Oayqw1ZP5q90MVso8obMXf8Lf0CelrvvH
xrVa9XTciFsrZVgSuXC6b4GsHFna3c9lAyFcPN95K3hDa3DiCZgLgtgFpNYQOblO
83k6D0IjokDkzchZhgr+6Az90t49LrHHU9z04nrWNOZa6AtZrNDm6uguZuYeciBP
gPT6Qj5VqSc6oLdtJMKSaJc3jFaMw8svCGpBN7Z7jrcDpOupXzfMug==
=tWws
-----END PGP SIGNATURE-----

--=-iZY49gTjkeiSuUQuAC85--
