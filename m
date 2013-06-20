From: Asias He <asias@redhat.com>
Subject: [PATCH 3/4] VSOCK: Remove unnecessary label
Date: Thu, 20 Jun 2013 17:20:32 +0800
Message-ID: <1371720033-19714-4-git-send-email-asias@redhat.com>
References: <1371720033-19714-1-git-send-email-asias@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andy King <acking@vmware.com>,
	Dmitry Torokhov <dtor@vmware.com>,
	Reilly Grant <grantr@vmware.com>, Asias He <asias@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31063 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754841Ab3FTJVB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 05:21:01 -0400
In-Reply-To: <1371720033-19714-1-git-send-email-asias@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Asias He <asias@redhat.com>
---
 net/vmw_vsock/vmci_transport.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index 99b511d..ffc11df 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -940,10 +940,9 @@ static void vmci_transport_recv_pkt_work(struct work_struct *work)
 		 * reset to prevent that.
 		 */
 		vmci_transport_send_reset(sk, pkt);
-		goto out;
+		break;
 	}
 
-out:
 	release_sock(sk);
 	kfree(recv_pkt_info);
 	/* Release reference obtained in the stream callback when we fetched
-- 
1.8.1.4
