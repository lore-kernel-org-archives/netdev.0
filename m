From: Ozgur Karatas <okaratas@member.fsf.org>
Subject: [PATCH 1/2] net: wireless: fixed to checkpatch errors
Date: Thu, 22 Dec 2016 00:13:33 +0200
Message-ID: <577501482358413@web10g.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: johannes <johannes@sipsolutions.net>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward1o.cmail.yandex.net ([37.9.109.84]:39934 "EHLO
        forward1o.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754415AbcLUWNh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 17:13:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Fixed to checkpatch errors, Normally, comment's */ had to be finish on the next line.
The patch fix to readability and Coding Style.

Sİgned-off-by: Ozgur Karatas <okaratas@member.fsf.org>
---
 net/wireless/chan.c |  3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/wireless/chan.c b/net/wireless/chan.c
index 5497d022..8c7ac7f 100644
--- a/net/wireless/chan.c
+++ b/net/wireless/chan.c
@@ -891,7 +891,8 @@ cfg80211_get_chan_state(struct wireless_dev *wdev,
 				  : CHAN_MODE_EXCLUSIVE;
 
 			/* consider worst-case - IBSS can try to return to the
-			 * original user-specified channel as creator */
+			 * original user-specified channel as creator 
+			 */
 			if (wdev->ibss_dfs_possible)
 				*radar_detect |= BIT(wdev->chandef.width);
 			return;
-- 
2.1.4
