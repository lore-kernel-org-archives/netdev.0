From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: [PATCH] NET: Add debugging names to __RW_LOCK_UNLOCKED macros.
Date: Sat, 15 Mar 2008 14:16:18 -0400 (EDT)
Message-ID: <alpine.LFD.1.00.0803151414400.24935@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from astoria.ccjclearline.com ([64.235.106.9]:60379 "EHLO
	astoria.ccjclearline.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbYCOSQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Mar 2008 14:16:25 -0400
Received: from cpe001d60ad7267-cm001225dbafb6.cpe.net.cable.rogers.com ([99.236.100.208] helo=crashcourse.ca)
	by astoria.ccjclearline.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.68)
	(envelope-from <rpjday@crashcourse.ca>)
	id 1Jaave-0001bj-K0
	for netdev@vger.kernel.org; Sat, 15 Mar 2008 14:16:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>

---

  not compile tested, but this is a fairly straightforward change.

 net/ipv4/raw.c |    2 +-
 net/ipv6/raw.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index a3002fe..e10ef6c 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -81,7 +81,7 @@
 #include <linux/netfilter_ipv4.h>

 static struct raw_hashinfo raw_v4_hashinfo = {
-	.lock = __RW_LOCK_UNLOCKED(),
+	.lock = __RW_LOCK_UNLOCKED(raw_v4_hashinfo.lock),
 };

 void raw_hash_sk(struct sock *sk, struct raw_hashinfo *h)
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 8897ccf..d6afa02 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -62,7 +62,7 @@
 #include <linux/seq_file.h>

 static struct raw_hashinfo raw_v6_hashinfo = {
-	.lock = __RW_LOCK_UNLOCKED(),
+	.lock = __RW_LOCK_UNLOCKED(raw_v6_hashinfo.lock),
 };

 static void raw_v6_hash(struct sock *sk)
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry:
    Have classroom, will lecture.

http://crashcourse.ca                          Waterloo, Ontario, CANADA
========================================================================
