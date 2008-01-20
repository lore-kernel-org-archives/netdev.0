From: Patrick McHardy <kaber@trash.net>
Subject: [ETHER 07/18]: Bring back MAC_FMT
Date: Sun, 20 Jan 2008 18:11:27 +0100 (MET)
Message-ID: <20080120171126.7980.38671.sendpatchset@localhost.localdomain>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62350 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754461AbYATRL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 12:11:28 -0500
In-Reply-To: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ETHER]: Bring back MAC_FMT

The print_mac function is not very suitable for debugging printks
in performance critical paths since without ifdefs it will always
get called. MAC_FMT can be used with pr_debug without any overhead
when debugging is disabled.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit ead4b3ca023de4d4f05d185e8111c01784ee08e2
tree d9616532b4fcc9137828d9ed9da941512bdc6841
parent 99c94d927602635ca0994a99bf75edc0d2f80871
author Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:28 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:28 +0100

 include/linux/if_ether.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 7a1e011..e157c13 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -130,6 +130,7 @@ extern ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len);
  *	Display a 6 byte device address (MAC) in a readable format.
  */
 extern char *print_mac(char *buf, const unsigned char *addr);
+#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
 #define MAC_BUF_SIZE	18
 #define DECLARE_MAC_BUF(var) char var[MAC_BUF_SIZE] __maybe_unused
 
