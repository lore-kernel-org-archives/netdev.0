From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 2/3] Bluetooth: Select Basic Mode as default for SOCK_SEQPACKET
Date: Mon, 16 Nov 2009 01:48:22 +0100
Message-ID: <a0e55a32afc2130e5ae506755e4b8eb42a23b568.1258331614.git.marcel@holtmann.org>
References: <cover.1258331614.git.marcel@holtmann.org>
 <93f19c9fc8c98bb6d2e9825115989603ffd5cd1f.1258331614.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:46539 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184AbZKPAs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2009 19:48:26 -0500
In-Reply-To: <93f19c9fc8c98bb6d2e9825115989603ffd5cd1f.1258331614.git.marcel@holtmann.org>
In-Reply-To: <cover.1258331614.git.marcel@holtmann.org>
References: <cover.1258331614.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>

The default mode for SOCK_SEQPACKET is Basic Mode. So when no
mode has been specified, Basic Mode shall be used.

This is important for current application to keep working as
expected and not cause a regression.

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 77e9fb1..076caa1 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -2205,7 +2205,7 @@ static int l2cap_build_conf_req(struct sock *sk, void *data)
 {
 	struct l2cap_pinfo *pi = l2cap_pi(sk);
 	struct l2cap_conf_req *req = data;
-	struct l2cap_conf_rfc rfc = { .mode = L2CAP_MODE_ERTM };
+	struct l2cap_conf_rfc rfc = { .mode = L2CAP_MODE_BASIC };
 	void *ptr = req->data;
 
 	BT_DBG("sk %p", sk);
-- 
1.6.2.5

