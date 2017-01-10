From: Suman Anna <s-anna@ti.com>
Subject: [PATCH] net: add the AF_QIPCRTR entries to family name tables
Date: Mon, 9 Jan 2017 21:48:56 -0600
Message-ID: <20170110034856.49721-1-s-anna@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Suman Anna <s-anna@ti.com>,
        Courtney Cavin <courtney.cavin@sonymobile.com>,
        Bjorn Andersson <bjorn.andersson@linaro.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit bdabad3e363d ("net: Add Qualcomm IPC router") introduced a
new address family. Update the family name tables accordingly so
that the lockdep initialization can use the proper names for this
family.

Cc: Courtney Cavin <courtney.cavin@sonymobile.com>
Cc: Bjorn Andersson <bjorn.andersson@linaro.org>
Signed-off-by: Suman Anna <s-anna@ti.com>
---
 net/core/sock.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index f560e0826009..4eca27dc5c94 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -222,7 +222,7 @@ static const char *const af_family_key_strings[AF_MAX+1] = {
   "sk_lock-AF_RXRPC" , "sk_lock-AF_ISDN"     , "sk_lock-AF_PHONET"   ,
   "sk_lock-AF_IEEE802154", "sk_lock-AF_CAIF" , "sk_lock-AF_ALG"      ,
   "sk_lock-AF_NFC"   , "sk_lock-AF_VSOCK"    , "sk_lock-AF_KCM"      ,
-  "sk_lock-AF_MAX"
+  "sk_lock-AF_QIPCRTR", "sk_lock-AF_MAX"
 };
 static const char *const af_family_slock_key_strings[AF_MAX+1] = {
   "slock-AF_UNSPEC", "slock-AF_UNIX"     , "slock-AF_INET"     ,
@@ -239,7 +239,7 @@ static const char *const af_family_slock_key_strings[AF_MAX+1] = {
   "slock-AF_RXRPC" , "slock-AF_ISDN"     , "slock-AF_PHONET"   ,
   "slock-AF_IEEE802154", "slock-AF_CAIF" , "slock-AF_ALG"      ,
   "slock-AF_NFC"   , "slock-AF_VSOCK"    ,"slock-AF_KCM"       ,
-  "slock-AF_MAX"
+  "slock-AF_QIPCRTR", "slock-AF_MAX"
 };
 static const char *const af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_UNSPEC", "clock-AF_UNIX"     , "clock-AF_INET"     ,
@@ -256,7 +256,7 @@ static const char *const af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_RXRPC" , "clock-AF_ISDN"     , "clock-AF_PHONET"   ,
   "clock-AF_IEEE802154", "clock-AF_CAIF" , "clock-AF_ALG"      ,
   "clock-AF_NFC"   , "clock-AF_VSOCK"    , "clock-AF_KCM"      ,
-  "clock-AF_MAX"
+  "clock-AF_QIPCRTR", "clock-AF_MAX"
 };
 
 /*
-- 
2.10.2
