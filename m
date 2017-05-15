From: linzhang <xiaolou4617@gmail.com>
Subject: [PATCH] net: socket: mark socket protocol handler structs as const
Date: Mon, 15 May 2017 10:26:47 +0800
Message-ID: <1494815207-9378-1-git-send-email-xiaolou4617@gmail.com>
Cc: dmitry.tarnyagin@lockless.no, sameo@linux.intel.com,
        nhorman@tuxdriver.com, linux-bluetooth@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org, linzhang <xiaolou4617@gmail.com>
To: marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34029 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751166AbdEOC1M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 14 May 2017 22:27:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: linzhang <xiaolou4617@gmail.com>
---
 net/bluetooth/af_bluetooth.c | 2 +-
 net/caif/caif_socket.c       | 2 +-
 net/kcm/kcmsock.c            | 2 +-
 net/nfc/af_nfc.c             | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index 42d0997..8a8f77a 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -733,7 +733,7 @@ void bt_procfs_cleanup(struct net *net, const char *name)
 EXPORT_SYMBOL(bt_procfs_init);
 EXPORT_SYMBOL(bt_procfs_cleanup);
 
-static struct net_proto_family bt_sock_family_ops = {
+static const struct net_proto_family bt_sock_family_ops = {
 	.owner	= THIS_MODULE,
 	.family	= PF_BLUETOOTH,
 	.create	= bt_sock_create,
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index adcad34..4674d17 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -1099,7 +1099,7 @@ static int caif_create(struct net *net, struct socket *sock, int protocol,
 }
 
 
-static struct net_proto_family caif_family_ops = {
+static const struct net_proto_family caif_family_ops = {
 	.family = PF_CAIF,
 	.create = caif_create,
 	.owner = THIS_MODULE,
diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
index deca20f..da49191 100644
--- a/net/kcm/kcmsock.c
+++ b/net/kcm/kcmsock.c
@@ -1985,7 +1985,7 @@ static int kcm_create(struct net *net, struct socket *sock,
 	return 0;
 }
 
-static struct net_proto_family kcm_family_ops = {
+static const struct net_proto_family kcm_family_ops = {
 	.family = PF_KCM,
 	.create = kcm_create,
 	.owner  = THIS_MODULE,
diff --git a/net/nfc/af_nfc.c b/net/nfc/af_nfc.c
index 54e40fa..d3e594e 100644
--- a/net/nfc/af_nfc.c
+++ b/net/nfc/af_nfc.c
@@ -48,7 +48,7 @@ static int nfc_sock_create(struct net *net, struct socket *sock, int proto,
 	return rc;
 }
 
-static struct net_proto_family nfc_sock_family_ops = {
+static const struct net_proto_family nfc_sock_family_ops = {
 	.owner  = THIS_MODULE,
 	.family = PF_NFC,
 	.create = nfc_sock_create,
-- 
1.8.3.1
