From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/3]  net: bgmac: Misc improvements
Date: Tue,  7 Jun 2016 15:06:12 -0700
Message-ID: <1465337175-22368-1-git-send-email-f.fainelli@gmail.com>
Cc: ben@decadent.org.uk, zajec5@gmail.com, hauke@hauke-m.de,
	jon.mason@broadcom.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36650 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754247AbcFGWGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 18:06:25 -0400
Received: by mail-pf0-f179.google.com with SMTP id t190so7913297pfb.3
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 15:06:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Rafal, Hauke, Felix,

This patch series add minor changes to the bgmac driver:

- properly bind net_device with its backing device structure such that
  we can locate the device using common helper functions

- add support for ethtool statistics reading the HW MIB counters which
  is useful for debugging

- add netdev statistics throughout the TX/RX path to know what is going on

Thanks

Florian Fainelli (3):
  bgmac: Bind net_device with backing device structure
  bgmac: Add support for ethtool statistics
  bgmac: Maintain some netdev statistics

 drivers/net/ethernet/broadcom/bgmac.c | 135 ++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bgmac.h |   4 +-
 2 files changed, 137 insertions(+), 2 deletions(-)

-- 
2.7.4
