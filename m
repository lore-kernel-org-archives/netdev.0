From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] ethtool: use "ops" name consistenty in ethtool_set_rxfh()
Date: Fri, 20 Feb 2015 13:54:05 +0300
Message-ID: <20150220105405.GC7895@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Amir Vadai <amirv@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>,
	Ed Swierk <eswierk@skyportsystems.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Eyal Perry <eyalpe@mellanox.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:21160 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753950AbbBTKyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 05:54:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"dev->ethtool_ops" and "ops" are the same, but we should use "ops"
everywhere to be consistent.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 91f74f3..eb0c3ac 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -789,7 +789,7 @@ static noinline_for_stack int ethtool_set_rxfh(struct net_device *dev,
 	if (ops->get_rxfh_indir_size)
 		dev_indir_size = ops->get_rxfh_indir_size(dev);
 	if (ops->get_rxfh_key_size)
-		dev_key_size = dev->ethtool_ops->get_rxfh_key_size(dev);
+		dev_key_size = ops->get_rxfh_key_size(dev);
 
 	if (copy_from_user(&rxfh, useraddr, sizeof(rxfh)))
 		return -EFAULT;
