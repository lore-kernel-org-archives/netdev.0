From: Stefan Schmidt <stefan@datenfreihafen.org>
Subject: [PATCH iproute2] ip: update link types to show 6lowpan and ieee802.15.4 monitor
Date: Fri, 28 Oct 2016 11:42:03 +0200
Message-ID: <1477647723-14641-1-git-send-email-stefan@datenfreihafen.org>
Cc: netdev@vger.kernel.org, linux-wpan@vger.kernel.org,
        Stefan Schmidt <stefan@datenfreihafen.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lasnet.de ([78.47.171.185]:59532 "EHLO
        proxima.lasnet.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936169AbcJ1Jr1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 05:47:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both types have been missing here and thus ip always showed
only the numbers.

Based on a suggestion from Alexander Aring.

Signed-off-by: Stefan Schmidt <stefan@datenfreihafen.org>
---
 lib/ll_types.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/lib/ll_types.c b/lib/ll_types.c
index 2c5bf8b..eca617f 100644
--- a/lib/ll_types.c
+++ b/lib/ll_types.c
@@ -100,11 +100,13 @@ __PF(IEEE80211,ieee802.11)
 __PF(IEEE80211_PRISM,ieee802.11/prism)
 __PF(IEEE80211_RADIOTAP,ieee802.11/radiotap)
 __PF(IEEE802154, ieee802.15.4)
+__PF(IEEE802154_MONITOR, ieee802.15.4/monitor)
 __PF(PHONET, phonet)
 __PF(PHONET_PIPE, phonet_pipe)
 __PF(CAIF, caif)
 __PF(IP6GRE, gre6)
 __PF(NETLINK, netlink)
+__PF(6LOWPAN, 6lowpan)
 
 __PF(NONE, none)
 __PF(VOID,void)
-- 
2.5.5
