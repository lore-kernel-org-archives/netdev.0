From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-2.6] cifs: Fix compile error without CONFIG_KEYS selected.
Date: Sun, 12 Oct 2008 19:41:03 +0800
Message-ID: <20081012113349.M10023@cooldavid.org>
References: <20081011.151153.223811080.davem@davemloft.net>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	samba-technical@lists.samba.org
To: Steve French <sfrench@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 220-133-139-86.HINET-IP.hinet.net ([220.133.139.86]:50967 "EHLO
	cooldavid.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752112AbYJLLli (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Oct 2008 07:41:38 -0400
In-Reply-To: <20081011.151153.223811080.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steve, David:

  I'm not sure where should this patch goes, since I see the error
in David's net-2.6 git, I submit it to netdev.

cifs: Fix compile error without CONFIG_KEYS selected.

fs/cifs/sess.c: In function "CIFS_SessSetup":
fs/cifs/sess.c:628: error: implicit declaration of function "key_revoke"

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index abccb5d..717245f 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1863,6 +1863,7 @@ config CIFS
 	tristate "CIFS support (advanced network filesystem, SMBFS successor)"
 	depends on INET
 	select NLS
+	select KEYS
 	help
 	  This is the client VFS module for the Common Internet File System
 	  (CIFS) protocol which is the successor to the Server Message Block 

