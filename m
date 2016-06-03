From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: bgmac: Misc improvements
Date: Fri,  3 Jun 2016 10:06:59 -0700
Message-ID: <1464973621-14794-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, zajec5@gmail.com, nbd@nbd.name,
	hauke@hauke-m.de, jon.mason@broadcom.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34615 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932216AbcFCRHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 13:07:06 -0400
Received: by mail-pf0-f194.google.com with SMTP id c84so11950531pfc.1
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 10:07:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Rafal, Hauke, Felix,

This patch series add minor changes to the bgmac driver:

- properly bind net_device with its backing device structure such that
  we can locate the device using common helper functions

- add support for ethtool statistics reading the HW MIB counters which
  is useful for debugging

Thanks

Florian Fainelli (2):
  bgmac: Bind net_device with backing device structure
  bgmac: Add support for ethtool statistics

 drivers/net/ethernet/broadcom/bgmac.c | 126 ++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bgmac.h |   4 +-
 2 files changed, 128 insertions(+), 2 deletions(-)

-- 
2.7.4
