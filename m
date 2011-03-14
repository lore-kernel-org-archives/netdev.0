From: Sangtae Ha <sangtae.ha@gmail.com>
Subject: [PATCH 2/3] tcp_cubic: make the delay threshold of HyStart less sensitive
Date: Sun, 13 Mar 2011 20:04:02 -0400
Message-ID: <1300061042-24180-1-git-send-email-sangtae.ha@gmail.com>
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Injong Rhee <rhee@ncsu.edu>,
	Bill Fink <billfink@mindspring.com>, <netdev@vger.kernel.org>,
	Sangtae Ha <sangtae.ha@gmail.com>
To: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:49734 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756605Ab1CNAEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 20:04:10 -0400
Received: by qwk3 with SMTP id 3so909937qwk.19
        for <netdev@vger.kernel.org>; Sun, 13 Mar 2011 17:04:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make HyStart less sensitive to abrupt delay variations due to buffer bloat.

Signed-off-by: Sangtae Ha <sangtae.ha@gmail.com>
---
 net/ipv4/tcp_cubic.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index ab9f888..b758db1 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -39,7 +39,7 @@
 
 /* Number of delay samples for detecting the increase of delay */
 #define HYSTART_MIN_SAMPLES	8
-#define HYSTART_DELAY_MIN	(2U<<3)
+#define HYSTART_DELAY_MIN	(4U<<3)
 #define HYSTART_DELAY_MAX	(16U<<3)
 #define HYSTART_DELAY_THRESH(x)	clamp(x, HYSTART_DELAY_MIN, HYSTART_DELAY_MAX)
 
-- 
1.7.0.4

