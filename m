From: Federico Vaga <federico.vaga@gmail.com>
Subject: [PATCH] net/core/sock.c: add missing VSOCK string in af_family_*_key_strings
Date: Tue, 28 May 2013 17:02:44 +0200
Message-ID: <1369753364-10043-1-git-send-email-federico.vaga@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Federico Vaga <federico.vaga@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <edumazet@google.com>,
	Li Zefan <lizefan@huawei.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The three arrays of strings: af_family_kay_strings,
af_family_slock_key_strings and af_family_clock_key_strings have not
VSOCK's string

Signed-off-by: Federico Vaga <federico.vaga@gmail.com>
---
 net/core/sock.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 6ba327d..88868a9 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -210,7 +210,7 @@ static const char *const af_family_key_strings[AF_MAX+1] = {
   "sk_lock-AF_TIPC"  , "sk_lock-AF_BLUETOOTH", "sk_lock-IUCV"        ,
   "sk_lock-AF_RXRPC" , "sk_lock-AF_ISDN"     , "sk_lock-AF_PHONET"   ,
   "sk_lock-AF_IEEE802154", "sk_lock-AF_CAIF" , "sk_lock-AF_ALG"      ,
-  "sk_lock-AF_NFC"   , "sk_lock-AF_MAX"
+  "sk_lock-AF_NFC"   , "sk_lock-AF_VSOCK"    , "sk_lock-AF_MAX"
 };
 static const char *const af_family_slock_key_strings[AF_MAX+1] = {
   "slock-AF_UNSPEC", "slock-AF_UNIX"     , "slock-AF_INET"     ,
@@ -226,7 +226,7 @@ static const char *const af_family_slock_key_strings[AF_MAX+1] = {
   "slock-AF_TIPC"  , "slock-AF_BLUETOOTH", "slock-AF_IUCV"     ,
   "slock-AF_RXRPC" , "slock-AF_ISDN"     , "slock-AF_PHONET"   ,
   "slock-AF_IEEE802154", "slock-AF_CAIF" , "slock-AF_ALG"      ,
-  "slock-AF_NFC"   , "slock-AF_MAX"
+  "slock-AF_NFC"   , "slock-AF_VSOCK"    ,"slock-AF_MAX"
 };
 static const char *const af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_UNSPEC", "clock-AF_UNIX"     , "clock-AF_INET"     ,
@@ -242,7 +242,7 @@ static const char *const af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_IUCV"     ,
   "clock-AF_RXRPC" , "clock-AF_ISDN"     , "clock-AF_PHONET"   ,
   "clock-AF_IEEE802154", "clock-AF_CAIF" , "clock-AF_ALG"      ,
-  "clock-AF_NFC"   , "clock-AF_MAX"
+  "clock-AF_NFC"   , "clock-AF_VSOCK"    , "clock-AF_MAX"
 };
 
 /*
-- 
1.8.1.4
