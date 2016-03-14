From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH] Documentation: networking: phy.txt: Add missing functions
Date: Mon, 14 Mar 2016 10:55:50 -0700
Message-ID: <1457978150-29568-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36433 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754021AbcCNR5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 13:57:46 -0400
Received: by mail-pf0-f175.google.com with SMTP id u190so111422543pfb.3
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 10:57:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some new development in PHYLIB added new function pointers to the struct
phy_driver, document these.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/networking/phy.txt | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index e839e7efc835..7ab9404a8412 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -267,13 +267,23 @@ Writing a PHY driver
    config_intr: Enable or disable interrupts
    remove: Does any driver take-down
    ts_info: Queries about the HW timestamping status
+   match_phy_device: used for Clause 45 capable PHYs to match devices
+   in package and ensure they are compatible
    hwtstamp: Set the PHY HW timestamping configuration
    rxtstamp: Requests a receive timestamp at the PHY level for a 'skb'
    txtsamp: Requests a transmit timestamp at the PHY level for a 'skb'
    set_wol: Enable Wake-on-LAN at the PHY level
    get_wol: Get the Wake-on-LAN status at the PHY level
+   link_change_notify: called to inform the core is about to change the
+   link state, can be used to work around bogus PHY between state changes
    read_mmd_indirect: Read PHY MMD indirect register
    write_mmd_indirect: Write PHY MMD indirect register
+   module_info: Get the size and type of an EEPROM contained in an plug-in
+   module
+   module_eeprom: Get EEPROM information of a plug-in module
+   get_sset_count: Get number of strings sets that get_strings will count
+   get_strings: Get strings from requested objects (statistics)
+   get_stats: Get the extended statistics from the PHY device
 
  Of these, only config_aneg and read_status are required to be
  assigned by the driver code.  The rest are optional.  Also, it is
-- 
2.1.0
