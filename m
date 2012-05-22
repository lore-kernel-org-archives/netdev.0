From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] if: restore token ring ARP type to header
Date: Tue, 22 May 2012 14:01:05 -0700
Message-ID: <20120522140105.284c28cd@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50432 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754933Ab2EVVBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2012 17:01:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent removal of Token Ring breaks the build of iproute2.

Even though Token Ring support is gone from the kernel, it is worth
keeping the the definition of the TR ARP type to avoid breaking
userspace programs that use this file.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/linux/if_arp.h	2012-05-22 08:24:26.816834997 -0700
+++ b/include/linux/if_arp.h	2012-05-22 13:57:24.037399528 -0700
@@ -82,7 +82,7 @@
 #define ARPHRD_FCPL	786		/* Fibrechannel public loop	*/
 #define ARPHRD_FCFABRIC	787		/* Fibrechannel fabric		*/
 	/* 787->799 reserved for fibrechannel media types */
-/* 800 used to be used for token ring */
+#define ARPHRD_IEEE802_TR 800		/* Magic type ident for TR	*/
 #define ARPHRD_IEEE80211 801		/* IEEE 802.11			*/
 #define ARPHRD_IEEE80211_PRISM 802	/* IEEE 802.11 + Prism2 header  */
 #define ARPHRD_IEEE80211_RADIOTAP 803	/* IEEE 802.11 + radiotap header */
