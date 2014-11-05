From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 0/3] sfc: Clean up Siena SR-IOV support in preparation
 for EF10 SR-IOV support
Date: Wed, 5 Nov 2014 12:15:09 +0000
Message-ID: <545A14CD.6040809@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:64938 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753888AbaKEMYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 07:24:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series provides a base and clean up for the upcoming
EF10 SRIOV patches.

Shradha Shah (3):
  sfc: Move the current VF state from efx_nic into siena_nic_data
  sfc: Rename implementations in siena_sriov.c to have a 'siena' prefix
  sfc: Add NIC type operations to replace direct calls from efx.c into
    siena_sriov.c

 drivers/net/ethernet/sfc/ef10.c        |   5 +
 drivers/net/ethernet/sfc/efx.c         |  22 +--
 drivers/net/ethernet/sfc/falcon.c      |  10 ++
 drivers/net/ethernet/sfc/farch.c       |  27 ++--
 drivers/net/ethernet/sfc/mcdi.c        |   2 +-
 drivers/net/ethernet/sfc/net_driver.h  |  19 +--
 drivers/net/ethernet/sfc/nic.h         | 112 +++++++++-----
 drivers/net/ethernet/sfc/siena.c       |   8 +-
 drivers/net/ethernet/sfc/siena_sriov.c | 269 ++++++++++++++++++---------------
 9 files changed, 281 insertions(+), 193 deletions(-)
