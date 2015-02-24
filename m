From: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
Subject: [PATCH] Fix misspelling of defrag in ip-l2tp.8
Date: Tue, 24 Feb 2015 15:29:15 -0500
Message-ID: <20150224202915.GA32529@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, James Chapman <jchapman@katalix.com>
To: Len Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.csclub.uwaterloo.ca ([129.97.134.52]:35746 "EHLO
	mail.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248AbbBXUgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 15:36:32 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 man/man8/ip-l2tp.8 |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/man/man8/ip-l2tp.8 b/man/man8/ip-l2tp.8
index 2efda9f..1738035 100644
--- a/man/man8/ip-l2tp.8
+++ b/man/man8/ip-l2tp.8
@@ -356,16 +356,16 @@ the recipient expects to receive ethernet frames exactly as
 transmitted. In such cases, it is important that frames leaving the
 tunnel are reassembled back into a single frame before being
 forwarded on. To do so, enable netfilter connection tracking
-(conntrack) or manually load the Linux netfilter degrag modules at
+(conntrack) or manually load the Linux netfilter defrag modules at
 each tunnel endpoint.
 .PP
 .nf
-site-A:# modprobe nf_degrag_ipv4
+site-A:# modprobe nf_defrag_ipv4
 
-site-B:# modprobe nf_degrag_ipv4
+site-B:# modprobe nf_defrag_ipv4
 .fi
 .PP
-If L2TP is being used over IPv6, use the IPv6 degrag module.
+If L2TP is being used over IPv6, use the IPv6 defrag module.
 .SH INTEROPERABILITY
 .PP
 Unmanaged (static) L2TPv3 tunnels are supported by some network
-- 
1.7.10.4
 
