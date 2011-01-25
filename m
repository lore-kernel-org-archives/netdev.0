From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] bonding: fix return value of
 bonding_store_slaves_active()
Date: Tue, 25 Jan 2011 19:53:15 +0100
Message-ID: <20110125185315.GB2932@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17131 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752856Ab1AYSxg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jan 2011 13:53:36 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

count is incorrectly returned even in case of fail. Return ret instead.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 8fd0174..f33155f 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1595,7 +1595,7 @@ static ssize_t bonding_store_slaves_active(struct device *d,
 		}
 	}
 out:
-	return count;
+	return ret;
 }
 static DEVICE_ATTR(all_slaves_active, S_IRUGO | S_IWUSR,
 		   bonding_show_slaves_active, bonding_store_slaves_active);
