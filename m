From: <Nisar.Sayed@microchip.com>
Subject: [PATCH v2 net 0/3] lan78xx: Fixes to lan78xx driver
Date: Mon, 11 Sep 2017 18:51:30 +0000
Message-ID: <CE371C1263339941885964188A0225FA335C73@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa3.microchip.iphmx.com ([68.232.153.233]:56482 "EHLO
        esa3.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751076AbdIKSwR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 14:52:17 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nisar Sayed <Nisar.Sayed@microchip.com>

This series of patches are for lan78xx driver.

These patches fixes potential issues associated with lan78xx driver

v2
- Added patch version information
- Added fixes tag
- Updated patch description
- Updated changes as per comments

v1
- Spitted patches as per comments
- Dropped "fixed_phy device support" and "Fix for system suspend" changes

Nisar Sayed (3):
  Fix for eeprom read/write when device auto suspend
  Allow EEPROM write for less than MAX_EEPROM_SIZE
  Use default value loaded from EEPROM/OTP when resetting

 drivers/net/usb/lan78xx.c | 27 ++++++++++++++++++++-------
 1 file changed, 20 insertions(+), 7 deletions(-)

-- 
1.9.1
