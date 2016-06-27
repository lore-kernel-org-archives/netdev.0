From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 0/2] net: thunderx: Miscellaneous fixes
Date: Mon, 27 Jun 2016 15:30:01 +0530
Message-ID: <1467021603-26226-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	robert.richter@caviumnetworks.com, Naveen.Reddy@cavium.com,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32880 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbcF0KAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 06:00:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sunil Goutham <sgoutham@cavium.com>

This 2 patch series fixes issues w.r.t physical link status
reporting and transmit datapath configuration for
secondary qsets.

Changes from v1:
Fixed lmac disable sequence for interfaces of type SGMII.

Sunil Goutham (2):
  net: thunderx: Fix link status reporting
  net: thunderx: Fix TL4 configuration for secondary Qsets

 drivers/net/ethernet/cavium/thunder/nic_main.c    | 16 +++-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 91 +++++++++++++++--------
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h |  2 +
 3 files changed, 75 insertions(+), 34 deletions(-)

-- 
2.7.4
