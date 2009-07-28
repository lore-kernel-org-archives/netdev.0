From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] netxen: fix build when CONFIG_INET=n
Date: Tue, 28 Jul 2009 11:21:03 -0700
Message-ID: <20090728112103.81f229d6.randy.dunlap@oracle.com>
References: <20090728174224.647cc3ba.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Dhananjay Phadke <dhananjay@netxen.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>, davem@davemloft.net
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090728174224.647cc3ba.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix netxen build errors when CONFIG_INET=n:

netxen_nic_main.c:(.text+0x1abb8a): undefined reference to `in_dev_finish_destroy'
netxen_nic_main.c:(.init.text+0xd86e): undefined reference to `register_inetaddr_notifier'
netxen_nic_main.c:(.exit.text+0x1b70): undefined reference to `unregister_inetaddr_notifier'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next-20090728.orig/drivers/net/Kconfig
+++ linux-next-20090728/drivers/net/Kconfig
@@ -2666,7 +2666,7 @@ config MYRI10GE_DCA
 
 config NETXEN_NIC
 	tristate "NetXen Multi port (1/10) Gigabit Ethernet NIC"
-	depends on PCI
+	depends on PCI && INET
 	help
 	  This enables the support for NetXen's Gigabit Ethernet card.
 



---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
