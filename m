From: Nisar Sayed <Nisar.Sayed@microchip.com>
Subject: [PATCH v4 net 0/3] lan78xx: This series of patches are for lan78xx driver.
Date: Tue, 19 Sep 2017 03:32:22 +0530
Message-ID: <20170918220225.3767-1-Nisar.Sayed@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa5.microchip.iphmx.com ([216.71.150.166]:36006 "EHLO
        esa5.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755339AbdIRQjg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 12:39:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches are for lan78xx driver.

These patches fixes potential issues associated with lan78xx driver.

v4
- Updated changes to handle return values as per comments
- Updated EEPROM write handling as per comments

v3
- Updated chagnes as per comments

v2
- Added patch version information
- Added fixes tag
- Updated patch description
- Updated chagnes as per comments

v1
- Splitted patches as per comments
- Dropped "fixed_phy device support" and "Fix for system suspend" changes

Nisar Sayed (3):
  Fix for eeprom read/write when device auto suspend
  Allow EEPROM write for less than MAX_EEPROM_SIZE
  Use default values loaded from EEPROM/OTP after reset

 drivers/net/usb/lan78xx.c | 34 ++++++++++++++++++++++++----------
 1 file changed, 24 insertions(+), 10 deletions(-)

-- 
2.14.1
