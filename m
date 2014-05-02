From: Masanari Iida <standby24x7@gmail.com>
Subject: [Patch] cfg80211/mac80211: Fix warning on make xmldocs caused by cfg80211.h
Date: Fri,  2 May 2014 23:39:56 +0900
Message-ID: <1399041597-27409-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: luciano.coelho@intel.com, johannes.berg@intel.com,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:51097 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbaEBOkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 10:40:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fix a warning on make xmldocs.
The symptom happened on linux-next as of 0502.
Not on Linus's tree.
Because a pach 2beb6dab2d799ee8934cb0801845e551ad8c70f2
which causes this symptom exist only on linux-next.

Masanari Iida (1):
  cfg80211/mac80211: Fix warning on make xmldocs caused by cfg80211.h

 include/net/cfg80211.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

-- 
2.0.0.rc1.15.g7e76a2f
