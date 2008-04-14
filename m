From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH] Expose netdevice dev_id through sysfs
Date: Mon, 14 Apr 2008 13:32:02 +0100
Message-ID: <1208176322.31695.73.camel@pmac.infradead.org>
References: <ftdb3v$tls$1@ger.gmane.org>
	 <20080407143805.GA9492@bongo.bofh.it>
	 <1208167737.31695.32.camel@pmac.infradead.org>
	 <1208171478.31695.58.camel@pmac.infradead.org>
	 <3ae72650804140455l4bb2afc2i4c54e58f3be1f931@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marco d'Itri <md@linux.it>, Harald Hoyer <harald@redhat.com>,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:50966 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759327AbYDNMck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 08:32:40 -0400
In-Reply-To: <3ae72650804140455l4bb2afc2i4c54e58f3be1f931@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Expose dev_id to userspace, because it helps to disambiguate between
interfaces where the MAC address is unique.

Signed-off-by: David Woodhouse <dwmw2@infradead.org>

--- ./linux-2.6.24.ppc/net/core/net-sysfs.c~	2008-04-13 13:38:24.000000000 +0100
+++ ./linux-2.6.24.ppc/net/core/net-sysfs.c	2008-04-14 10:58:32.000000000 +0100
@@ -87,6 +87,7 @@ static ssize_t netdev_store(struct devic
 	return ret;
 }
 
+NETDEVICE_SHOW(dev_id, fmt_hex);
 NETDEVICE_SHOW(addr_len, fmt_dec);
 NETDEVICE_SHOW(iflink, fmt_dec);
 NETDEVICE_SHOW(ifindex, fmt_dec);
@@ -210,6 +211,7 @@ static ssize_t store_tx_queue_len(struct
 
 static struct device_attribute net_class_attributes[] = {
 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
+	__ATTR(dev_id, S_IRUGO, show_dev_id, NULL),
 	__ATTR(iflink, S_IRUGO, show_iflink, NULL),
 	__ATTR(ifindex, S_IRUGO, show_ifindex, NULL),
 	__ATTR(features, S_IRUGO, show_features, NULL),


-- 
dwmw2

