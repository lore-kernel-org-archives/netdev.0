From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH] iproute: update dsfield file values
Date: Sun, 14 Sep 2014 20:43:53 -0700
Message-ID: <20140914204353.5a0579be@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:54546 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752289AbaIODn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2014 23:43:57 -0400
Received: by mail-pa0-f53.google.com with SMTP id rd3so5535580pab.40
        for <netdev@vger.kernel.org>; Sun, 14 Sep 2014 20:43:56 -0700 (PDT)
Received: from urahara (static-50-53-65-80.bvtn.or.frontiernet.net. [50.53.65.80])
        by mx.google.com with ESMTPSA id ps1sm10321766pac.41.2014.09.14.20.43.55
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Sep 2014 20:43:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Update the rt_dsfield file to contain values defined in current RFC.
The days of TOS precedence are gone, even Cisco doesn't refer
to these in the documents.
---
 etc/iproute2/rt_dsfield | 26 ++++++++++++--------------
 1 file changed, 12 insertions(+), 14 deletions(-)

diff --git a/etc/iproute2/rt_dsfield b/etc/iproute2/rt_dsfield
index 496ef66..c0f3679 100644
--- a/etc/iproute2/rt_dsfield
+++ b/etc/iproute2/rt_dsfield
@@ -1,17 +1,6 @@
-0x00	default
-0x10	lowdelay
-0x08	throughput
-0x04	reliability
-# This value overlap with ECT, do not use it!
-0x02	mincost
-# These values seems do not want to die, Cisco likes them by a strange reason.
-0x20	priority
-0x40	immediate
-0x60	flash
-0x80	flash-override
-0xa0	critical
-0xc0	internet
-0xe0	network
+# Differentiated field values
+# These include the DSCP and unused bits
+0x0	default
 # Newer RFC2597 values
 0x28	AF11
 0x30	AF12
@@ -25,3 +14,12 @@
 0x88	AF41
 0x90	AF42
 0x98	AF43
+# Older values RFC2474
+0x20	CS1
+0x40	CS2
+0x60	CS3
+0x80	CS4
+0xA0	CS5
+0xC0	CS6
+0xE0	CS7
+0x5C	EF
-- 
2.1.0
