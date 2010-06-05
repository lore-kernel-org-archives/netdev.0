From: Alex Lorca <alex.lorca@gmail.com>
Subject: [PATCH net-next-2.6] net-caif: Added missing lock validator constants
Date: Sat,  5 Jun 2010 18:15:04 +0000
Message-ID: <1275761704-8758-1-git-send-email-alex.lorca@gmail.com>
Cc: netdev@vger.kernel.org, Alex Lorca <alex.lorca@gmail.com>
To: Sjur Braendeland <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:53203 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932711Ab0FEWRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 18:17:04 -0400
Received: by vws5 with SMTP id 5so1466986vws.19
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 15:17:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CAIF is using "xxx-AF_MAX" strings for the lock validator. It should use
its own strings.

Signed-off-by: Alex Lorca <alex.lorca@gmail.com>
---
 net/core/sock.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 2cf7f9f..f9ce0db 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -156,7 +156,7 @@ static const char *const af_family_key_strings[AF_MAX+1] = {
   "sk_lock-27"       , "sk_lock-28"          , "sk_lock-AF_CAN"      ,
   "sk_lock-AF_TIPC"  , "sk_lock-AF_BLUETOOTH", "sk_lock-IUCV"        ,
   "sk_lock-AF_RXRPC" , "sk_lock-AF_ISDN"     , "sk_lock-AF_PHONET"   ,
-  "sk_lock-AF_IEEE802154",
+  "sk_lock-AF_IEEE802154", "sk_lock-AF_CAIF" ,
   "sk_lock-AF_MAX"
 };
 static const char *const af_family_slock_key_strings[AF_MAX+1] = {
@@ -172,7 +172,7 @@ static const char *const af_family_slock_key_strings[AF_MAX+1] = {
   "slock-27"       , "slock-28"          , "slock-AF_CAN"      ,
   "slock-AF_TIPC"  , "slock-AF_BLUETOOTH", "slock-AF_IUCV"     ,
   "slock-AF_RXRPC" , "slock-AF_ISDN"     , "slock-AF_PHONET"   ,
-  "slock-AF_IEEE802154",
+  "slock-AF_IEEE802154", "slock-AF_CAIF" ,
   "slock-AF_MAX"
 };
 static const char *const af_family_clock_key_strings[AF_MAX+1] = {
@@ -188,7 +188,7 @@ static const char *const af_family_clock_key_strings[AF_MAX+1] = {
   "clock-27"       , "clock-28"          , "clock-AF_CAN"      ,
   "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_IUCV"     ,
   "clock-AF_RXRPC" , "clock-AF_ISDN"     , "clock-AF_PHONET"   ,
-  "clock-AF_IEEE802154",
+  "clock-AF_IEEE802154", "clock-AF_CAIF" ,
   "clock-AF_MAX"
 };
 
-- 
1.6.4

