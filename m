From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: Fix docbook warning for IFF_VRF_MASTER enum
Date: Sun, 16 Aug 2015 10:26:49 -0600
Message-ID: <1439742409-3482-1-git-send-email-dsa@cumulusnetworks.com>
References: <201508141519.mrm1TF6u%fengguang.wu@intel.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:33550 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244AbbHPQ05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Aug 2015 12:26:57 -0400
Received: by igfj19 with SMTP id j19so42011557igf.0
        for <netdev@vger.kernel.org>; Sun, 16 Aug 2015 09:26:56 -0700 (PDT)
In-Reply-To: <201508141519.mrm1TF6u%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kbuild test robot reported:
tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   d52736e24fe2e927c26817256f8d1a3c8b5d51a0
commit: 4e3c89920cd3a6cfce22c6f537690747c26128dd [751/762] net: Introduce VRF related flags and helpers
reproduce: make htmldocs

>> Warning(include/linux/netdevice.h:1293): Enum value 'IFF_VRF_MASTER' not described in enum 'netdev_priv_flags'

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2d3cd86c5618..aa8b79dd08d8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1262,6 +1262,7 @@ struct net_device_ops {
  * @IFF_LIVE_ADDR_CHANGE: device supports hardware address
  *	change when it's running
  * @IFF_MACVLAN: Macvlan device
+ * @IFF_VRF_MASTER: device is a VRF master
  */
 enum netdev_priv_flags {
 	IFF_802_1Q_VLAN			= 1<<0,
-- 
2.3.2 (Apple Git-55)
