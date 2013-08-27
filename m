From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc-next 2013-08-27
Date: Tue, 27 Aug 2013 21:37:24 +0100
Message-ID: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:62479 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099Ab3H0Uh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:37:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit f76fe120d81c96fa2a17ae41f0647c963dbb43cd:

  sfc: Update and improve kernel-doc for efx_mcdi_state & efx_mcdi_iface (2013-08-21 20:20:41 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

for you to fetch changes up to b766630b351c68c0383831dba9b81a905e5e84c6:

  sfc: Eliminate struct efx_mtd (2013-08-22 19:26:04 +0100)

More refactoring and cleanup, particularly around filter management.

Ben.

----------------------------------------------------------------
Ben Hutchings (16):
      sfc: Get rid of per-NIC-type phys_addr_channels and mem_map_size
      sfc: EFX_WORKAROUND_ALWAYS is really specific to Falcon-architecture
      sfc: Do not assume efx_nic_type::ev_fini is idempotent
      sfc: Remove unused filter_flags variables and efx_farch_filter_id_flags()
      sfc: Rename Falcon-arch filter implementation types and functions
      sfc: Name the RX drop queue ID
      sfc: Extend and abstract efx_filter_spec to cover Huntington/EF10
      sfc: Split Falcon-arch-specific and common filter state
      sfc: Refactor Falcon-arch search limit reset
      sfc: Make most filter operations NIC-type-specific
      sfc: Refactor Falcon-arch filter removal
      sfc: Add flag for stack-owned RX MAC filters
      sfc: Define and use MCDI_POPULATE_DWORD_{1,2,3,4,5,6,7}
      sfc: Cleanup Falcon-arch simple MAC filter state
      sfc: Rename SPI stuff to show that it is Falcon-specific
      sfc: Eliminate struct efx_mtd

 drivers/net/ethernet/sfc/Makefile      |    1 -
 drivers/net/ethernet/sfc/efx.c         |   96 +--
 drivers/net/ethernet/sfc/efx.h         |  107 ++-
 drivers/net/ethernet/sfc/ethtool.c     |  215 +++---
 drivers/net/ethernet/sfc/falcon.c      |  131 ++--
 drivers/net/ethernet/sfc/farch.c       | 1171 ++++++++++++++++++++++++++++-
 drivers/net/ethernet/sfc/filter.c      | 1274 --------------------------------
 drivers/net/ethernet/sfc/filter.h      |  234 ++++--
 drivers/net/ethernet/sfc/mcdi.h        |   54 ++
 drivers/net/ethernet/sfc/mcdi_port.c   |   29 +-
 drivers/net/ethernet/sfc/mtd.c         |  307 ++++----
 drivers/net/ethernet/sfc/net_driver.h  |   79 +-
 drivers/net/ethernet/sfc/nic.h         |   33 +-
 drivers/net/ethernet/sfc/rx.c          |   94 +++
 drivers/net/ethernet/sfc/siena.c       |   32 +-
 drivers/net/ethernet/sfc/spi.h         |   18 +-
 drivers/net/ethernet/sfc/workarounds.h |   10 -
 17 files changed, 2118 insertions(+), 1767 deletions(-)
 delete mode 100644 drivers/net/ethernet/sfc/filter.c

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
