From: Jiri Benc <jbenc@suse.cz>
Subject: [3/6] ipw2100: fix after "ieee80211: cleanup"
Date: Tue, 24 May 2005 15:16:09 +0200
Message-ID: <20050524151609.1da09c2b@griffin.suse.cz>
References: <20050524150711.01632672@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pavel@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>
In-Reply-To: <20050524150711.01632672@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fixes ipw2100 after the ieee80211 header cleanup
(patch [1/5] ieee80211: cleanup).


Signed-off-by: Jiri Benc <jbenc@suse.cz>
Signed-off-by: Jirka Bohac <jbohac@suse.cz>

--- a/drivers/net/wireless/ipw2100.h	2005-05-19 16:23:00.000000000 +0200
+++ b/drivers/net/wireless/ipw2100.h	2005-05-19 16:37:14.000000000 +0200
@@ -798,7 +798,7 @@
 
 
 
-#define IPW_HEADER_802_11_SIZE		 sizeof(struct ieee80211_header_data)
+#define IPW_HEADER_802_11_SIZE		 sizeof(struct ieee80211_hdr_3addr)
 #define IPW_MAX_80211_PAYLOAD_SIZE              2304U
 #define IPW_MAX_802_11_PAYLOAD_LENGTH		2312
 #define IPW_MAX_ACCEPTABLE_TX_FRAME_LENGTH	1536


--
Jiri Benc
SUSE Labs
