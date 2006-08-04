From: Greg KH <gregkh@suse.de>
Subject: [patch 17/23] e1000: add forgotten PCI ID for supported device
Date: Thu, 3 Aug 2006 22:40:17 -0700
Message-ID: <20060804054017.GR769@kroah.com>
References: <20060804053258.391158155@quad.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>, torvalds@osdl.org,
	akpm@osdl.org, alan@lxorguk.ukuu.org.uk,
	Auke Kok <auke-jan.h.kok@intel.com>,
	NetDev <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:16304 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1030271AbWHDFoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 01:44:54 -0400
To: linux-kernel@vger.kernel.org, stable@kernel.org
Content-Disposition: inline; filename="e1000-add-forgotten-pci-id-for-supported-device.patch"
In-Reply-To: <20060804053807.GA769@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.

------------------
From: Auke Kok <auke-jan.h.kok@intel.com>

The Intel(R) PRO/1000 82572EI card is fully supported by 7.0.33-k2 and
onward.  Add the device ID so this card works with 2.6.17.y onward. This
device ID was accidentally omitted.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/e1000/e1000_hw.c |    1 +
 drivers/net/e1000/e1000_hw.h |    1 +
 2 files changed, 2 insertions(+)

--- linux-2.6.17.7.orig/drivers/net/e1000/e1000_hw.c
+++ linux-2.6.17.7/drivers/net/e1000/e1000_hw.c
@@ -353,6 +353,7 @@ e1000_set_mac_type(struct e1000_hw *hw)
     case E1000_DEV_ID_82572EI_COPPER:
     case E1000_DEV_ID_82572EI_FIBER:
     case E1000_DEV_ID_82572EI_SERDES:
+    case E1000_DEV_ID_82572EI:
         hw->mac_type = e1000_82572;
         break;
     case E1000_DEV_ID_82573E:
--- linux-2.6.17.7.orig/drivers/net/e1000/e1000_hw.h
+++ linux-2.6.17.7/drivers/net/e1000/e1000_hw.h
@@ -462,6 +462,7 @@ int32_t e1000_check_phy_reset_block(stru
 #define E1000_DEV_ID_82572EI_COPPER      0x107D
 #define E1000_DEV_ID_82572EI_FIBER       0x107E
 #define E1000_DEV_ID_82572EI_SERDES      0x107F
+#define E1000_DEV_ID_82572EI             0x10B9
 #define E1000_DEV_ID_82573E              0x108B
 #define E1000_DEV_ID_82573E_IAMT         0x108C
 #define E1000_DEV_ID_82573L              0x109A

--
