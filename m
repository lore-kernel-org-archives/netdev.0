From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000: add forgotten PCI ID for supported device
Date: Fri, 28 Jul 2006 15:06:17 -0700
Message-ID: <44CA8A59.40002@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030907060207060602000806"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	NetDev <netdev@vger.kernel.org>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62490 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S1161336AbWG1WHZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 18:07:25 -0400
To: Greg KH <greg@kroah.com>, stable@kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030907060207060602000806
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


The Intel(R) PRO/1000 82572EI card is fully supported by 7.0.33-k2 and onward. 
Add the device ID so this card works with 2.6.17.y onward. This device ID was 
accidentally omitted.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

--------------030907060207060602000806
Content-Type: text/x-patch;
 name="e1000_stable_add_forgotten_pciid.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="e1000_stable_add_forgotten_pciid.patch"

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 523c2c9..c5e7023 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -353,6 +353,7 @@ e1000_set_mac_type(struct e1000_hw *hw)
     case E1000_DEV_ID_82572EI_COPPER:
     case E1000_DEV_ID_82572EI_FIBER:
     case E1000_DEV_ID_82572EI_SERDES:
+    case E1000_DEV_ID_82572EI:
         hw->mac_type = e1000_82572;
         break;
     case E1000_DEV_ID_82573E:
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 150e45e..c01e5d2 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -462,6 +462,7 @@ #define E1000_DEV_ID_82571EB_SERDES     
 #define E1000_DEV_ID_82572EI_COPPER      0x107D
 #define E1000_DEV_ID_82572EI_FIBER       0x107E
 #define E1000_DEV_ID_82572EI_SERDES      0x107F
+#define E1000_DEV_ID_82572EI             0x10B9
 #define E1000_DEV_ID_82573E              0x108B
 #define E1000_DEV_ID_82573E_IAMT         0x108C
 #define E1000_DEV_ID_82573L              0x109A

--------------030907060207060602000806--
