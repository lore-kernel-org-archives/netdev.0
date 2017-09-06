From: <Nisar.Sayed@microchip.com>
Subject: [PATCH net 0/4] lan78xx: Fixes and Enhancements to lan78xx driver
Date: Wed, 6 Sep 2017 10:49:39 +0000
Message-ID: <CE371C1263339941885964188A0225FA33335F@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <UNGLinuxDriver@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa1.microchip.iphmx.com ([68.232.147.91]:23169 "EHLO
        esa1.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752824AbdIFKt4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 06:49:56 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nisar Sayed <Nisar.Sayed@microchip.com>

This series of patches are for lan78xx driver.

These patches supports fixes and enhancements to lan78xx driver

Nisar Sayed (4):
  Fix for crash associated with System suspend
  Add fixed_phy device support for LAN7801 device
  Fix for eeprom read/write when device autosuspend
  Use default value loaded from EEPROM/OTP when resetting the chip

 drivers/net/usb/Kconfig   |  10 ++++
 drivers/net/usb/lan78xx.c | 130 ++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 118 insertions(+), 22 deletions(-)

-- 
1.9.1
