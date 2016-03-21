From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH net-next 3/3] net: add the AF_HYPERV entries to family name
 tables
Date: Mon, 21 Mar 2016 02:53:08 -0700
Message-ID: <1458553988-26830-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: gregkh@linuxfoundation.org, davem@davemloft.net, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de,
 apw@canonical.com, jasowang@redhat.com, kys@microsoft.com,
 haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

This is for the hv_sock driver, which introduces AF_HYPERV(42).

Signed-off-by: Dexuan Cui <decui@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
Cc: Haiyang Zhang <haiyangz@microsoft.com>
---
 net/core/sock.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 7e73c26..51ffc54 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -222,7 +222,7 @@ static const char *const af_family_key_strings[AF_MAX+1] = {
   "sk_lock-AF_RXRPC" , "sk_lock-AF_ISDN"     , "sk_lock-AF_PHONET"   ,
   "sk_lock-AF_IEEE802154", "sk_lock-AF_CAIF" , "sk_lock-AF_ALG"      ,
   "sk_lock-AF_NFC"   , "sk_lock-AF_VSOCK"    , "sk_lock-AF_KCM"      ,
-  "sk_lock-AF_MAX"
+  "sk_lock-AF_HYPERV", "sk_lock-AF_MAX"
 };
 static const char *const af_family_slock_key_strings[AF_MAX+1] = {
   "slock-AF_UNSPEC", "slock-AF_UNIX"     , "slock-AF_INET"     ,
@@ -239,7 +239,7 @@ static const char *const af_family_slock_key_strings[AF_MAX+1] = {
   "slock-AF_RXRPC" , "slock-AF_ISDN"     , "slock-AF_PHONET"   ,
   "slock-AF_IEEE802154", "slock-AF_CAIF" , "slock-AF_ALG"      ,
   "slock-AF_NFC"   , "slock-AF_VSOCK"    ,"slock-AF_KCM"       ,
-  "slock-AF_MAX"
+  "slock-AF_HYPERV", "slock-AF_MAX"
 };
 static const char *const af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_UNSPEC", "clock-AF_UNIX"     , "clock-AF_INET"     ,
@@ -256,7 +256,7 @@ static const char *const af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_RXRPC" , "clock-AF_ISDN"     , "clock-AF_PHONET"   ,
   "clock-AF_IEEE802154", "clock-AF_CAIF" , "clock-AF_ALG"      ,
   "clock-AF_NFC"   , "clock-AF_VSOCK"    , "clock-AF_KCM"      ,
-  "clock-AF_MAX"
+  "clock-AF_HYPERV", "clock-AF_MAX"
 };
 
 /*
-- 
2.1.0
