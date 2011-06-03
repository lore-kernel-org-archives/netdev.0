From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/3] net: Remove unnecessary semicolons
Date: Fri,  3 Jun 2011 14:51:19 -0700
Message-ID: <d1b27d535ee6100d83a2db8366b3b0083bcf11e9.1307137352.git.joe@perches.com>
References: <cover.1307137351.git.joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2500 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754156Ab1FCVvW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2011 17:51:22 -0400
Received: from Joe-Laptop.home (unknown [192.168.1.162])
	by mail.perches.com (Postfix) with ESMTP id 9D2D52436B
	for <netdev@vger.kernel.org>; Fri,  3 Jun 2011 14:51:19 -0700 (PDT)
In-Reply-To: <cover.1307137351.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Semicolons are not necessary after switch/while/for/if braces
so remove them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/batman-adv/hard-interface.c |    2 +-
 net/bluetooth/hci_core.c        |    4 ++--
 net/sunrpc/auth.c               |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index a3fbfb5..5719087 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -568,7 +568,7 @@ static int hard_if_event(struct notifier_block *this,
 		break;
 	default:
 		break;
-	};
+	}
 
 hardif_put:
 	hardif_free_ref(hard_iface);
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 815269b..e937ada 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -1519,7 +1519,7 @@ int hci_recv_fragment(struct hci_dev *hdev, int type, void *data, int count)
 
 		data += (count - rem);
 		count = rem;
-	};
+	}
 
 	return rem;
 }
@@ -1554,7 +1554,7 @@ int hci_recv_stream_fragment(struct hci_dev *hdev, void *data, int count)
 
 		data += (count - rem);
 		count = rem;
-	};
+	}
 
 	return rem;
 }
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index cd6e4aa..727e506 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -626,7 +626,7 @@ rpcauth_refreshcred(struct rpc_task *task)
 		if (err < 0)
 			goto out;
 		cred = task->tk_rqstp->rq_cred;
-	};
+	}
 	dprintk("RPC: %5u refreshing %s cred %p\n",
 		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
 
-- 
1.7.5.rc3.dirty

