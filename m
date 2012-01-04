From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 0/6] r6040: cleanups
Date: Wed,  4 Jan 2012 19:59:32 +0100
Message-ID: <1325703578-17275-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:60751 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754854Ab2ADS7u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 13:59:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series cleanups the r6040 driver by:
- using appropriate definitions instead of bits values
- fixing checkpatch errors and warnings

Florian Fainelli (6):
  r6040: remove unused variables and definitions
  r6040: define more MCR0 register bits
  r6040: use MAC_RST bit definition with MCR1 read/writes
  r6040: use definitions for MAC_SM register read/writes
  r6040: use __aligned(size)
  r6040: place comments before code

 drivers/net/ethernet/rdc/r6040.c |   39 +++++++++++++++----------------------
 1 files changed, 16 insertions(+), 23 deletions(-)

-- 
1.7.5.4
