From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next] vxlan: include net/ip6_checksum.h for csum_ipv6_magic()
Date: Mon,  2 Sep 2013 10:06:52 +0800
Message-ID: <1378087613-15279-2-git-send-email-amwang@redhat.com>
References: <1378087613-15279-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21203 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756338Ab3IBCHB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Sep 2013 22:07:01 -0400
In-Reply-To: <1378087613-15279-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Fengguang reported a compile warning:

   drivers/net/vxlan.c: In function 'vxlan6_xmit_skb':
   drivers/net/vxlan.c:1352:3: error: implicit declaration of function 'csum_ipv6_magic' [-Werror=implicit-function-declaration]
   cc1: some warnings being treated as errors

this patch fixes it.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/vxlan.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 0fcf3f7..6b560f3 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -44,6 +44,7 @@
 #include <net/ipv6.h>
 #include <net/addrconf.h>
 #include <net/ip6_tunnel.h>
+#include <net/ip6_checksum.h>
 #endif
 
 #define VXLAN_VERSION	"0.1"
-- 
1.7.7.6
