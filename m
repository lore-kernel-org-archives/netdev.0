From: Luis de Bethencourt <luisbg@osg.samsung.com>
Subject: [PATCH] mac80211: add doc for RX_FLAG_DUP_VALIDATED flag
Date: Fri, 18 Mar 2016 16:09:29 +0000
Message-ID: <1458317369-28185-1-git-send-email-luisbg@osg.samsung.com>
Cc: johannes@sipsolutions.net, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Luis de Bethencourt <luisbg@osg.samsung.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add documentation for the flag for duplication check.

Fixes the following warning when running make htmldocs:
warning: Enum value 'RX_FLAG_DUP_VALIDATED' not described in enum 'mac80211_rx_flags'

Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
---
Hi,

While running make htmldocs I noticed a warning about RX_FLAG_DUP_VALIDATED
missing a description. This patch fixes this.

I have noticed the order of the descriptions of the mac80211_rx_flags doesn't
match the order in the enum. I am happy to fix this if it would be of interest.

Thanks,
Luis

 include/net/mac80211.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index a53333c..42c8cde 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -1001,6 +1001,8 @@ ieee80211_tx_info_clear_status(struct ieee80211_tx_info *info)
  *	flag indicates that the PN was verified for replay protection.
  *	Note that this flag is also currently only supported when a frame
  *	is also decrypted (ie. @RX_FLAG_DECRYPTED must be set)
+ * @RX_FLAG_DUP_VALIDATED: Set this flag for the driver to check for packet
+ *	duplication by itself.
  * @RX_FLAG_FAILED_FCS_CRC: Set this flag if the FCS check failed on
  *	the frame.
  * @RX_FLAG_FAILED_PLCP_CRC: Set this flag if the PCLP check failed on
-- 
2.5.1
