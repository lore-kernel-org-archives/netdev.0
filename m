From: David Miller <davem@davemloft.net>
Subject: [PATCH] Kill unused macros...
Date: Tue, 17 Jun 2008 00:43:24 -0700 (PDT)
Message-ID: <20080617.004324.162289618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46989
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753962AbYFQHnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 03:43:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I noticed this while working on something unrelated in the
net-next-2.6 tree, applied and pushed to kernel.org

sctp: Kill SCTP_SOCK_SLEEP_{PRE,POST}, unused.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sctp/sctp.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 5672d48..17b932b 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -220,8 +220,6 @@ extern struct kmem_cache *sctp_bucket_cachep __read_mostly;
 #define sctp_release_sock(sk)    release_sock(sk)
 #define sctp_bh_lock_sock(sk)    bh_lock_sock(sk)
 #define sctp_bh_unlock_sock(sk)  bh_unlock_sock(sk)
-#define SCTP_SOCK_SLEEP_PRE(sk)  SOCK_SLEEP_PRE(sk)
-#define SCTP_SOCK_SLEEP_POST(sk) SOCK_SLEEP_POST(sk)
 
 /* SCTP SNMP MIB stats handlers */
 DECLARE_SNMP_STAT(struct sctp_mib, sctp_statistics);
