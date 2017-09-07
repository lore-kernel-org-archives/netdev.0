From: <Nisar.Sayed@microchip.com>
Subject: [PATCH net 0/3] lan78xx: Fixes to lan78xx driver
Date: Thu, 7 Sep 2017 07:10:51 +0000
Message-ID: <CE371C1263339941885964188A0225FA333A58@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa2.microchip.iphmx.com ([68.232.149.84]:40711 "EHLO
        esa2.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750742AbdIGHLh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 03:11:37 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nisar Sayed <Nisar.Sayed@microchip.com>

This series of patches are for lan78xx driver.

These patches fixes potential issues associated with lan78xx driver

Nisar Sayed (3):
  Fix for eeprom read/write when device autosuspend
  Allow EEPROM write for less than MAX_EEPROM_SIZE
  Use default value loaded from EEPROM/OTP when resetting

 drivers/net/usb/lan78xx.c | 27 ++++++++++++++++++++++-----
 1 file changed, 22 insertions(+), 5 deletions(-)

-- 
1.9.1
