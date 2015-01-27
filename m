From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH net-next v1 01/18] net: ethtool: propagate get_settings error
Date: Mon, 26 Jan 2015 17:35:57 -0800
Message-ID: <1422322574-6188-2-git-send-email-ddecotig@gmail.com>
References: <1422322574-6188-1-git-send-email-ddecotig@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Joe Perches <joe@perches.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ed Swierk <eswierk@skyportsystems.com>,
	David Decotigny <decot@googlers.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Amir Vadai <amirv@mellanox.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-api@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:41109 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757590AbbA0Bgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 20:36:47 -0500
In-Reply-To: <1422322574-6188-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@googlers.com>

Signed-off-by: David Decotigny <decot@googlers.com>
---
 net/core/ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 91f74f3..52efb7e 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -364,7 +364,7 @@ static int ethtool_get_settings(struct net_device *dev, void __user *useraddr)
 
 	if (copy_to_user(useraddr, &cmd, sizeof(cmd)))
 		return -EFAULT;
-	return 0;
+	return err;
 }
 
 static int ethtool_set_settings(struct net_device *dev, void __user *useraddr)
-- 
2.2.0.rc0.207.ga3a616c
