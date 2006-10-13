From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch] d80211: remove initialization of unused xr structure members
Date: Fri, 13 Oct 2006 12:34:57 -0700
Message-ID: <20061013193457.GA24280@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:21229 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1751821AbWJMTe6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 15:34:58 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="drivers-xr-removal.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The structure member xr_end was removed from d80211.h.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -2704,11 +2704,6 @@ static int rt2400pci_init_hw_modes(struc
 	rt2400pci_init_hw_channels(rt2x00dev, hw->modes->channels);
 	rt2400pci_init_hw_rates(rt2x00dev, hw->modes->rates);
 
-	/*
-	 * xr_end is only used on Atheros cards.
-	 */
-	hw->modes->xr_end = 0;
-
 	return ieee80211_update_hw(net_dev, hw);
 
 exit_free_channels:
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -2989,11 +2989,6 @@ static int rt2500pci_init_hw_modes(struc
 	rt2500pci_init_hw_channels(rt2x00dev, hw->modes[0].channels);
 	rt2500pci_init_hw_rates(rt2x00dev, hw->modes[0].rates);
 
-	/*
-	 * xr_end is only used on Atheros cards.
-	 */
-	hw->modes->xr_end = 0;
-
 	return ieee80211_update_hw(net_dev, hw);
 
 exit_free_channels:
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -3501,11 +3501,6 @@ static int rt61pci_init_hw_modes(struct 
 	rt61pci_init_hw_channels(rt2x00dev, hw->modes[0].channels);
 	rt61pci_init_hw_rates(rt2x00dev, hw->modes[0].rates);
 
-	/*
-	 * xr_end is only used on Atheros cards.
-	 */
-	hw->modes->xr_end = 0;
-
 	return ieee80211_update_hw(net_dev, hw);
 
 exit_free_channels:

--
