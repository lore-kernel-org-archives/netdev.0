From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH] MISDN: add missing lockdep strings
Date: Mon, 15 Sep 2008 17:04:50 +0300
Message-ID: <1221487490-26194-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:63672 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbYIOOFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 10:05:09 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8FE4nrK007764
	for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 17:05:07 +0300
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/core/sock.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 91f8bbc..d823978 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -154,7 +154,7 @@ static const char *af_family_key_strings[AF_MAX+1] =
=3D {
   "sk_lock-AF_PPPOX" , "sk_lock-AF_WANPIPE"  , "sk_lock-AF_LLC"      ,
   "sk_lock-27"       , "sk_lock-28"          , "sk_lock-AF_CAN"      ,
   "sk_lock-AF_TIPC"  , "sk_lock-AF_BLUETOOTH", "sk_lock-IUCV"        ,
-  "sk_lock-AF_RXRPC" , "sk_lock-AF_MAX"
+  "sk_lock-AF_RXRPC" , "sk_lock-AF_MISDN"    , "sk_lock-AF_MAX"
 };
 static const char *af_family_slock_key_strings[AF_MAX+1] =3D {
   "slock-AF_UNSPEC", "slock-AF_UNIX"     , "slock-AF_INET"     ,
@@ -168,7 +168,7 @@ static const char *af_family_slock_key_strings[AF_M=
AX+1] =3D {
   "slock-AF_PPPOX" , "slock-AF_WANPIPE"  , "slock-AF_LLC"      ,
   "slock-27"       , "slock-28"          , "slock-AF_CAN"      ,
   "slock-AF_TIPC"  , "slock-AF_BLUETOOTH", "slock-AF_IUCV"     ,
-  "slock-AF_RXRPC" , "slock-AF_MAX"
+  "slock-AF_RXRPC" , "slock-AF_MISDN"    , "slock-AF_MAX"
 };
 static const char *af_family_clock_key_strings[AF_MAX+1] =3D {
   "clock-AF_UNSPEC", "clock-AF_UNIX"     , "clock-AF_INET"     ,
@@ -182,7 +182,7 @@ static const char *af_family_clock_key_strings[AF_M=
AX+1] =3D {
   "clock-AF_PPPOX" , "clock-AF_WANPIPE"  , "clock-AF_LLC"      ,
   "clock-27"       , "clock-28"          , "clock-AF_CAN"      ,
   "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_IUCV"     ,
-  "clock-AF_RXRPC" , "clock-AF_MAX"
+  "clock-AF_RXRPC" , "clock-AF_MISDN"    , "clock-AF_MAX"
 };
 #endif
=20
--=20
1.5.4.3

