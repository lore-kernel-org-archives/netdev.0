From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: add missing include to netdevice.h
Date: Tue, 28 Jun 2005 15:47:03 +0200
Message-ID: <200506281547.04620.arnd@arndb.de>
References: <200506281528.08834.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linuxppc64-dev@ozlabs.org, Utz Bacher <utz.bacher@de.ibm.com>,
	linux-kernel@vger.kernel.org, Jens Osterkamp <Jens.Osterkamp@de.ibm.com>,
	netdev@vger.kernel.org
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
In-Reply-To: <200506281528.08834.arnd@arndb.de>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

linux/etherdevice.h can't be included standalone at the moment, which
is required in order to sort the header files in the recommended
alphabetic order. This patch fixes that and is needed to build spider_net.

Signed-off-by: Arnd Bergmann <arndb@de.ibm.com>

--- linux-cg.orig/include/linux/etherdevice.h	2005-05-31 07:48:50.044932320 -0400
+++ linux-cg/include/linux/etherdevice.h	2005-05-31 07:49:06.808914320 -0400
@@ -25,6 +25,7 @@
 #define _LINUX_ETHERDEVICE_H
 
 #include <linux/if_ether.h>
+#include <linux/netdevice.h>
 #include <linux/random.h>
 
 #ifdef __KERNEL__
