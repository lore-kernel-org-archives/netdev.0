From: Urs Thuermann <urs@isnogud.escape.de>
Subject: [PATCH] Fix comment for skb_pull_rcsum
Date: 10 Feb 2008 10:48:07 +0100
Message-ID: <ygftzkh5ei0.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:57543 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751002AbYBJJuF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Feb 2008 04:50:05 -0500
Received: from oker.escape.de (localhost [127.0.0.1])
	(envelope-sender: urs@isnogud.escape.de)
	by oker.escape.de (8.13.4/8.13.4/$Revision: 1.72 $) with ESMTP id m1A9o3VS008673
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 10 Feb 2008 10:50:04 +0100
Received: (from uucp@localhost)
	by oker.escape.de (8.13.4/8.13.4/Submit) with UUCP id m1A9o3eK008630
	for netdev@vger.kernel.org; Sun, 10 Feb 2008 10:50:03 +0100
Received: from janus.isnogud.escape.de (localhost [127.0.0.1])
	by janus.isnogud.escape.de (8.13.8/8.13.8) with ESMTP id m1A9m7pC001591
	for <netdev@vger.kernel.org>; Sun, 10 Feb 2008 10:48:07 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix comment for skb_pull_rcsum

Signed-off-by: Urs Thuermann <urs@isnogud.escape.de>

---

Index: net-2.6/net/core/skbuff.c
===================================================================
--- net-2.6.orig/net/core/skbuff.c	2008-02-06 22:17:58.000000000 +0100
+++ net-2.6/net/core/skbuff.c	2008-02-08 11:05:00.000000000 +0100
@@ -2106,11 +2106,10 @@
 /**
  *	skb_pull_rcsum - pull skb and update receive checksum
  *	@skb: buffer to update
- *	@start: start of data before pull
  *	@len: length of data pulled
  *
  *	This function performs an skb_pull on the packet and updates
- *	update the CHECKSUM_COMPLETE checksum.  It should be used on
+ *	the CHECKSUM_COMPLETE checksum.  It should be used on
  *	receive path processing instead of skb_pull unless you know
  *	that the checksum difference is zero (e.g., a valid IP header)
  *	or you are setting ip_summed to CHECKSUM_NONE.
