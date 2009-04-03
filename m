From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] vxge: should include tcp.h
Date: Fri, 3 Apr 2009 13:34:40 +0400
Message-ID: <a4423d670904030234l3734ad45t49009e8ede2e1d2d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ramkrishna Vepa <ram.vepa@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f165.google.com ([209.85.219.165]:62970 "EHLO
	mail-ew0-f165.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751893AbZDCJen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2009 05:34:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this build error:

drivers/net/vxge/vxge-main.c: In function 'vxge_get_vpath_no':
drivers/net/vxge/vxge-main.c:695: error: dereferencing pointer to
incomplete type
...

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/vxge/vxge-main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 61ef161..b7f08f3 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -43,6 +43,7 @@

 #include <linux/if_vlan.h>
 #include <linux/pci.h>
+#include <linux/tcp.h>
 #include <net/ip.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
