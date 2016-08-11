From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net-next 0/6] sfc: SFN8000 support improvements
Date: Thu, 11 Aug 2016 12:59:20 +0100
Message-ID: <78a8505b-8c63-b879-2cd2-d78d9890aa6c@solarflare.com>
References: <1137d3d8-0b1b-d5f5-149a-1771bbac7aa6@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:27086 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751148AbcHKMZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 08:25:47 -0400
In-Reply-To: <1137d3d8-0b1b-d5f5-149a-1771bbac7aa6@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series improves support for the recently released SFN8000 series
of adapters. Specifically, it retrieves interrupt moderation timer
settings directly from the adapter and uses those settings. It also
uses a new event queue initialisation interface, allowing specification
of a performance objective rather than enabling individual flags.

Bert Kenward (6):
  sfc: update MCDI protocol headers
  sfc: allow asynchronous MCDI without completion function
  sfc: retrieve second word of datapath capabilities
  sfc: use new performance based event queue init
  sfc: set interrupt moderation via MCDI
  sfc: get timer configuration from adapter

 drivers/net/ethernet/sfc/ef10.c        | 221 +++++++++++---
 drivers/net/ethernet/sfc/efx.c         |  96 +++---
 drivers/net/ethernet/sfc/efx.h         |   2 +
 drivers/net/ethernet/sfc/falcon.c      |   9 +-
 drivers/net/ethernet/sfc/mcdi.c        |   5 +-
 drivers/net/ethernet/sfc/mcdi_pcol.h   | 530 ++++++++++++++++++++++++++++++++-
 drivers/net/ethernet/sfc/net_driver.h  |  12 +-
 drivers/net/ethernet/sfc/nic.h         |   5 +
 drivers/net/ethernet/sfc/ptp.c         |   2 +-
 drivers/net/ethernet/sfc/siena.c       |  14 +-
 drivers/net/ethernet/sfc/workarounds.h |   4 +
 11 files changed, 782 insertions(+), 118 deletions(-)

-- 
2.7.4
