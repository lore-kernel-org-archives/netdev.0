From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 13/13] e1000: cleanup unused prototype
Date: Fri, 25 Sep 2009 15:20:57 -0700
Message-ID: <20090925222056.26715.67379.stgit@localhost.localdomain>
References: <20090925221613.26715.66796.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:60011
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752793AbZIYWVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 18:21:10 -0400
In-Reply-To: <20090925221613.26715.66796.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The function e1000_enable_tx_pkt_filtering() was removed in
a previous cleanup patch.  this removes the no longer used
prototype.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_hw.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 2e42341..9acfddb 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -365,7 +365,6 @@ struct e1000_host_mng_dhcp_cookie {
 #endif
 
 bool e1000_check_mng_mode(struct e1000_hw *hw);
-bool e1000_enable_tx_pkt_filtering(struct e1000_hw *hw);
 s32 e1000_read_eeprom(struct e1000_hw *hw, u16 reg, u16 words, u16 * data);
 s32 e1000_validate_eeprom_checksum(struct e1000_hw *hw);
 s32 e1000_update_eeprom_checksum(struct e1000_hw *hw);

