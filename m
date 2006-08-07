From: Jouni Malinen <jkm@devicescape.com>
Subject: [PATCH wireless-dev 3/6] d80211: Fix PLCP header length comment
Date: Mon, 07 Aug 2006 16:16:11 -0700
Message-ID: <20060807231938.049085926@localhost>
References: <20060807231608.888744720@localhost>
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	jkm@devicescape.com, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-32.dex002.intermedia.net ([64.78.21.117]:22277 "EHLO
	dhost002-32.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751195AbWHGXX7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 19:23:59 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline; filename=plcp_hdr_len.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed a typo in a comment: PLCP header length is in microseconds, not
milliseconds.

Signed-off-by: Jouni Malinen <jkm@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -637,7 +637,7 @@ static int ieee80211_frame_duration(stru
 		 * 802.11 (DS): 15.3.3, 802.11b: 18.3.4
 		 * aSIFSTime = 10 usec
 		 * aPreambleLength = 144 usec or 72 usec with short preamble
-		 * aPLCPHeaderLength = 48 ms or 24 ms with short preamble
+		 * aPLCPHeaderLength = 48 usec or 24 usec with short preamble
 		 */
 		dur = 10; /* aSIFSTime = 10 usec */
 		dur += short_preamble ? (72 + 24) : (144 + 48);

--
-- 
Jouni Malinen                                            PGP id EFC895FA
