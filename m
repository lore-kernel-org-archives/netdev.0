From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc-next 2013-08-25
Date: Sun, 25 Aug 2013 23:56:03 +0100
Message-ID: <1377471363.2586.69.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="=-yzMlA1ZaNOAk+W1ribbq"
Cc: netdev <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56235 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756646Ab3HYW4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Aug 2013 18:56:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-yzMlA1ZaNOAk+W1ribbq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit f073dde03b3e8d11050d82f52caaf75fd924e069=
:

  sfc: Make efx_mcdi_init() call efx_mcdi_handle_assertion() (2013-08-21 19=
:43:09 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

for you to fetch changes up to f76fe120d81c96fa2a17ae41f0647c963dbb43cd:

  sfc: Update and improve kernel-doc for efx_mcdi_state & efx_mcdi_iface (2=
013-08-21 20:20:41 +0100)

1. Refactoring and cleanup in preparation for new hardware support.
2. Some bug fixes for firmware completion handling.  (They're not known
to cause real problems, otherwise I'd be submitting these for net and
stable.)
3. Update to the firmware protocol (MCDI) definitions.

Ben.

Ben Hutchings (16):
      sfc: Make MCDI independent of Siena
      sfc: Add GFP flags to efx_nic_alloc_buffer() and make most callers al=
low blocking
      sfc: Make struct efx_special_buffer less special
      sfc: Rename Falcon-architecture register definitions
      sfc: Remove efx_process_channel_now()
      sfc: Rework IRQ enable/disable
      sfc: Limit scope of a Falcon A1 IRQ workaround
      sfc: Stop RX refill before flushing RX queues
      sfc: Remove bogus call to efx_release_tx_buffers()
      sfc: Refactor queue teardown sequence to allow for EF10 flush behavio=
ur
      sfc: Move and rename Falcon/Siena common NIC operations
      sfc: Translate MCDI error numbers received in events
      sfc: Update MCDI protocol definitions for EF10
      sfc: Add support for MCDI v2
      sfc: Fix race in completion handling
      sfc: Update and improve kernel-doc for efx_mcdi_state & efx_mcdi_ifac=
e

 drivers/net/ethernet/sfc/Makefile                 |    3 +-
 drivers/net/ethernet/sfc/efx.c                    |  216 +-
 drivers/net/ethernet/sfc/efx.h                    |    3 -
 drivers/net/ethernet/sfc/falcon.c                 |   76 +-
 drivers/net/ethernet/sfc/farch.c                  | 1781 +++++++
 drivers/net/ethernet/sfc/{regs.h =3D> farch_regs.h} |    6 +-
 drivers/net/ethernet/sfc/filter.c                 |    2 +-
 drivers/net/ethernet/sfc/mcdi.c                   |  299 +-
 drivers/net/ethernet/sfc/mcdi.h                   |   55 +-
 drivers/net/ethernet/sfc/mcdi_mon.c               |    2 +-
 drivers/net/ethernet/sfc/mcdi_pcol.h              | 5534 +++++++++++++++++=
++--
 drivers/net/ethernet/sfc/mcdi_port.c              |    5 +-
 drivers/net/ethernet/sfc/net_driver.h             |  155 +-
 drivers/net/ethernet/sfc/nic.c                    | 1812 +-------
 drivers/net/ethernet/sfc/nic.h                    |  219 +-
 drivers/net/ethernet/sfc/ptp.c                    |    9 +-
 drivers/net/ethernet/sfc/rx.c                     |    9 +-
 drivers/net/ethernet/sfc/selftest.c               |   11 -
 drivers/net/ethernet/sfc/siena.c                  |  131 +-
 drivers/net/ethernet/sfc/siena_sriov.c            |   17 +-
 drivers/net/ethernet/sfc/tx.c                     |   24 +-
 21 files changed, 7788 insertions(+), 2581 deletions(-)
 create mode 100644 drivers/net/ethernet/sfc/farch.c
 rename drivers/net/ethernet/sfc/{regs.h =3D> farch_regs.h} (99%)

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-yzMlA1ZaNOAk+W1ribbq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQEVAwUAUhqLg2kILBsOca60AQqx2Qf/cRmgPzLweYV9njb83C+TXk+N4OtL9xNI
5LvarMcyz2qnWOY/L6WlDrTAOPgn9awvPCgDAZq6ntFmfBa3s65k9IqFuTp/RSt/
iXfCAaF1toTbANU39u0OyKhe50TcxH15uLBCDT/P7S5Q9iu7Lgd2/3X0LYFO68Op
WQmq2NeGsye7c4Nkg9AGo057xNWz7hw2ZeTgEURuttPDG79Jm7y6uqK0vz0vTlKM
8ET0863pXhHgsG2FQxDtXmxdNnV3R+pHNDTjMRgVnB6tjPu0XYBT/KYI7LH0EOQO
uEEkC7zs3eS5JLl0jrffbhWN9Ae7C6ATk/zaFuaUxvVTZr6m97+WPQ==
=aEfh
-----END PGP SIGNATURE-----

--=-yzMlA1ZaNOAk+W1ribbq--
