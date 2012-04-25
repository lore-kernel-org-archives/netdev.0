From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] unix_diag: use netlink attribute MAX convention
Date: Wed, 25 Apr 2012 10:38:58 -0700
Message-ID: <20120425103858.04d149d8@nehalam.linuxnetplumber.net>
References: <4F97A484.2040300@gmail.com>
	<20120425092645.180ac196@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Shan Wei <shanwei88@gmail.com>, xemul@parallels.com,
	NetDev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45361 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756680Ab2DYRjB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 13:39:01 -0400
In-Reply-To: <20120425092645.180ac196@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the standard convention to define the number of elements
in unix diag attribute. This fixes future problems like the fact
the last element (MEMINFO) is not parsed by current iproute2 ss command.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/linux/unix_diag.h	2012-02-13 09:23:58.830508614 -0800
+++ b/include/linux/unix_diag.h	2012-04-25 09:36:20.752056963 -0700
@@ -37,9 +37,9 @@ enum {
 	UNIX_DIAG_ICONS,
 	UNIX_DIAG_RQLEN,
 	UNIX_DIAG_MEMINFO,
-
-	UNIX_DIAG_MAX,
+	__UNIX_DIAG_MAX
 };
+#define UNIX_DIAG_MAX (__UNIX_DIAG_MAX - 1)
 
 struct unix_diag_vfs {
 	__u32	udiag_vfs_ino;
