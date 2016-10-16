From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCH] mac80211_hwsim: suggest nl80211 instead of wext driver in documentation
Date: Mon, 17 Oct 2016 00:39:33 +0200
Message-ID: <20161016223933.9484-1-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Jonathan Corbet <corbet@lwn.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
        =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
To: linux-wireless@vger.kernel.org,
        Johannes Berg <johannes@sipsolutions.net>,
        Jouni Malinen <j@w1.fi>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For mac80211_hwsim interfaces, suggest to use wpa_supplicant with the more
modern, netlink based driver instead of wext.

Signed-off-by: Linus Lüssing <linus.luessing@c0d3.blue>
---

Actually, I wasn't even able to make a connection with the configuration
files and information provided in
Documentation/networking/mac80211_hwsim/{README,hostapd.conf/wpa_supplicant.conf}

Changing -Dwext to -Dnl80211 helped and made the WPA-PSK connection with
mac80211_hwsim interfaces work for me.
---
 Documentation/networking/mac80211_hwsim/README | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/networking/mac80211_hwsim/README b/Documentation/networking/mac80211_hwsim/README
index 24ac91d..3566a72 100644
--- a/Documentation/networking/mac80211_hwsim/README
+++ b/Documentation/networking/mac80211_hwsim/README
@@ -60,7 +60,7 @@ modprobe mac80211_hwsim
 hostapd hostapd.conf
 
 # Run wpa_supplicant (station) for wlan1
-wpa_supplicant -Dwext -iwlan1 -c wpa_supplicant.conf
+wpa_supplicant -Dnl80211 -iwlan1 -c wpa_supplicant.conf
 
 
 More test cases are available in hostap.git:
-- 
2.1.4

