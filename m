From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch] Fix type of prism2_hostapd_param crypt.alg
Date: Thu, 7 Sep 2006 09:15:54 -0700
Message-ID: <20060907161554.GA9120@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-9.dex002.intermedia.net ([64.78.21.63]:21273 "EHLO
	dhost002-9.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S932249AbWIGQP6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Sep 2006 12:15:58 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="crypt.alg_type.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

crypt.alg is a string, use the correct type.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/hostapd_ioctl.h
===================================================================
--- wireless-dev.orig/net/d80211/hostapd_ioctl.h
+++ wireless-dev/net/d80211/hostapd_ioctl.h
@@ -207,7 +207,7 @@ struct prism2_hostapd_param {
 			u32 last_ack_rssi;
 		} get_info_sta;
 		struct {
-			u8 alg[HOSTAP_CRYPT_ALG_NAME_LEN];
+			char alg[HOSTAP_CRYPT_ALG_NAME_LEN];
 			u32 flags;
 			u32 err;
 			u8 idx;

--
