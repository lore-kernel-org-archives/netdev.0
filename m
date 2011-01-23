From: Stanislav Fomichev <kernel@fomichev.me>
Subject: [PATCH] netconsole: kbuild dependency fix
Date: Sun, 23 Jan 2011 22:51:16 +0300
Message-ID: <4d3c86b8.114ddf0a.7de4.ffffe043@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51840 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129Ab1AWTvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jan 2011 14:51:22 -0500
Received: by fxm20 with SMTP id 20so3372843fxm.19
        for <netdev@vger.kernel.org>; Sun, 23 Jan 2011 11:51:21 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,
I'm not sure if it's the right place to send this patch, but I didn't find a better one.

Here is a small fix for netconsole dependency (upon config fs) that I unintentionally found.

Hope you'll find it useful.

This patch is for 2.6.38-rc2.

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0382332..9733da1 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -3382,6 +3382,7 @@ config NET_FC
 	  "SCSI generic support".
 
 config NETCONSOLE
+	depends on CONFIGFS_FS
 	tristate "Network console logging support"
 	---help---
 	If you want to log kernel messages over the network, enable this.
