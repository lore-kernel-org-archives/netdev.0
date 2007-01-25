From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH RFC 20/31] net: Implement CONFIG_NET_NS
Date: Thu, 25 Jan 2007 12:00:22 -0700
Message-ID: <1169751637792-git-send-email-ebiederm@xmission.com>
References: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
Cc: <containers@lists.osdl.org>, <openib-general@openib.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35819 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030490AbXAYTBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 14:01:41 -0500
In-Reply-To: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric W. Biederman <ebiederm@xmission.com> - unquoted

Add the config option to enable multiple network namespaces.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/Kconfig |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/Kconfig b/net/Kconfig
index 7dfc949..4671398 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -27,6 +27,13 @@ if NET
 
 menu "Networking options"
 
+config NET_NS
+	bool "Network namespace support"
+	depends on EXPERIMENTAL
+	help
+	  Support what appear to user space as multiple instances of the 
+ 	  network stack.
+
 config NETDEBUG
 	bool "Network packet debugging"
 	help
-- 
1.4.4.1.g278f

