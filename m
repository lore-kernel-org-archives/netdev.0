From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] bond: make slave_sysfs_ops static
Date: Sat, 18 Jan 2014 14:54:18 -0800
Message-ID: <20140118145418.4b439f15@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:63667 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493AbaARWyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 17:54:21 -0500
Received: by mail-pd0-f180.google.com with SMTP id x10so4121781pdj.11
        for <netdev@vger.kernel.org>; Sat, 18 Jan 2014 14:54:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/bonding/bond_sysfs_slave.c	2014-01-18 13:41:07.096564532 -0800
+++ b/drivers/net/bonding/bond_sysfs_slave.c	2014-01-18 13:52:28.927552881 -0800
@@ -102,7 +102,7 @@ static ssize_t slave_show(struct kobject
 	return slave_attr->show(slave, buf);
 }
 
-const struct sysfs_ops slave_sysfs_ops = {
+static const struct sysfs_ops slave_sysfs_ops = {
 	.show = slave_show,
 };
 
