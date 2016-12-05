From: Ozgur Karatas <ozgur@member.fsf.org>
Subject: [PATCH] Fixed to checkpatch.pl errors to vlan_dev.c
Date: Mon, 05 Dec 2016 17:34:01 +0200
Message-ID: <52561480952041@web13j.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: kaber@trash.net, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello all,

I will solve a checkpatch errors.

Signed-off-by: Ozgur Karatas <ozgur@member.fsf.org>

---
 net/8021q/vlan_dev.c                               |   2 +-
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index fbfacd5..2edb495 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -738,7 +738,7 @@ static int vlan_dev_netpoll_setup(struct net_device *dev, struct netpoll_info *n

 static void vlan_dev_netpoll_cleanup(struct net_device *dev)
 {
-       struct vlan_dev_priv *vlan= vlan_dev_priv(dev);
+       struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
        struct netpoll *netpoll = vlan->netpoll;

        if (!netpoll)
