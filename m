From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next v2 0/4] sfc: add MCDI tracing
Date: Wed, 20 May 2015 16:49:09 +0100
Message-ID: <555CACF5.9060803@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:37584 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932514AbbETPtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 11:49:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds support for logging MCDI (Management-Controller-to-
 Driver Interface) interactions between the sfc driver and a bound device,
 to aid in debugging.
Solarflare has a tool to decode the resulting traces and will look to
 open-source this if there is any external interest, but the protocol is
 already detailed in drivers/net/ethernet/sfc/mcdi_pcol.h.

--
v2: avoid long lines in cover letter; fix multiline comment style

Edward Cree (3):
  sfc: add tracing of MCDI commands
  sfc: add sysfs entry to control MCDI tracing
  sfc: add module parameter to enable MCDI logging on new functions

Jon Cooper (1):
  sfc: Initialise MCDI buffers to 0 on declaration.

 drivers/net/ethernet/sfc/Kconfig |   9 ++++
 drivers/net/ethernet/sfc/ef10.c  |  27 ++++++----
 drivers/net/ethernet/sfc/efx.c   |  49 +++++++++++++++---
 drivers/net/ethernet/sfc/mcdi.c  | 108 ++++++++++++++++++++++++++++++++++++---
 drivers/net/ethernet/sfc/mcdi.h  |  14 +++--
 drivers/net/ethernet/sfc/ptp.c   |   6 +--
 6 files changed, 181 insertions(+), 32 deletions(-)
