From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 1/4] Documentation: net: phy: remove description of function pointers
Date: Sun, 27 Nov 2016 18:45:12 -0800
Message-ID: <20161128024515.13070-2-f.fainelli@gmail.com>
References: <20161128024515.13070-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, sf84@laposte.net,
        martin.blumenstingl@googlemail.com, mans@mansr.com,
        alexandre.torgue@st.com, peppe.cavallaro@st.com,
        timur@codeaurora.org, jbrunet@baylibre.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36009 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754091AbcK1CpW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 21:45:22 -0500
Received: by mail-oi0-f66.google.com with SMTP id u15so11794198oie.3
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 18:45:22 -0800 (PST)
In-Reply-To: <20161128024515.13070-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the function pointers documentation which duplicates information
found in include/linux/phy.h. Maintaining documentation about two
different locations just does not work, but the code is less likely to
be outdated.

Reviewed-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/networking/phy.txt | 35 ++---------------------------------
 1 file changed, 2 insertions(+), 33 deletions(-)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index 7ab9404a8412..4b25c0f24201 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -251,39 +251,8 @@ Writing a PHY driver
  PHY_BASIC_FEATURES, but you can look in include/mii.h for other
  features.
 
- Each driver consists of a number of function pointers:
-
-   soft_reset: perform a PHY software reset
-   config_init: configures PHY into a sane state after a reset.
-     For instance, a Davicom PHY requires descrambling disabled.
-   probe: Allocate phy->priv, optionally refuse to bind.
-   PHY may not have been reset or had fixups run yet.
-   suspend/resume: power management
-   config_aneg: Changes the speed/duplex/negotiation settings
-   aneg_done: Determines the auto-negotiation result
-   read_status: Reads the current speed/duplex/negotiation settings
-   ack_interrupt: Clear a pending interrupt
-   did_interrupt: Checks if the PHY generated an interrupt
-   config_intr: Enable or disable interrupts
-   remove: Does any driver take-down
-   ts_info: Queries about the HW timestamping status
-   match_phy_device: used for Clause 45 capable PHYs to match devices
-   in package and ensure they are compatible
-   hwtstamp: Set the PHY HW timestamping configuration
-   rxtstamp: Requests a receive timestamp at the PHY level for a 'skb'
-   txtsamp: Requests a transmit timestamp at the PHY level for a 'skb'
-   set_wol: Enable Wake-on-LAN at the PHY level
-   get_wol: Get the Wake-on-LAN status at the PHY level
-   link_change_notify: called to inform the core is about to change the
-   link state, can be used to work around bogus PHY between state changes
-   read_mmd_indirect: Read PHY MMD indirect register
-   write_mmd_indirect: Write PHY MMD indirect register
-   module_info: Get the size and type of an EEPROM contained in an plug-in
-   module
-   module_eeprom: Get EEPROM information of a plug-in module
-   get_sset_count: Get number of strings sets that get_strings will count
-   get_strings: Get strings from requested objects (statistics)
-   get_stats: Get the extended statistics from the PHY device
+ Each driver consists of a number of function pointers, documented
+ in include/linux/phy.h under the phy_driver structure.
 
  Of these, only config_aneg and read_status are required to be
  assigned by the driver code.  The rest are optional.  Also, it is
-- 
2.9.3
