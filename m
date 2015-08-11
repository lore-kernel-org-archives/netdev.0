From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH] net: Document xfrm4_gc_thresh and xfrm6_gc_thresh
Date: Tue, 11 Aug 2015 13:35:01 -0700
Message-ID: <20150811203501.1914.86746.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34693 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932689AbbHKUfM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2015 16:35:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds documentation for xfrm4_gc_thresh and xfrm6_gc_thresh
based on the comments in commit eeb1b73378b56 ("xfrm: Increase the garbage
collector threshold").

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 Documentation/networking/ip-sysctl.txt |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 56db1efd7189..46e88ed7f41d 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1181,6 +1181,11 @@ tag - INTEGER
 	Allows you to write a number, which can be used as required.
 	Default value is 0.
 
+xfrm4_gc_thresh - INTEGER
+	The threshold at which we will start garbage collecting for IPv4
+	destination cache entries.  At twice this value the system will
+	refuse new allocations.
+
 Alexey Kuznetsov.
 kuznet@ms2.inr.ac.ru
 
@@ -1617,6 +1622,11 @@ ratelimit - INTEGER
 	otherwise the minimal space between responses in milliseconds.
 	Default: 1000
 
+xfrm6_gc_thresh - INTEGER
+	The threshold at which we will start garbage collecting for IPv6
+	destination cache entries.  At twice this value the system will
+	refuse new allocations.
+
 
 IPv6 Update by:
 Pekka Savola <pekkas@netcore.fi>
