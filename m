From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH] wimax: fix i2400m printk formats
Date: Tue, 10 Mar 2009 11:48:29 -0700
Message-ID: <1236710909-27528-1-git-send-email-inaky@linux.intel.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, netdev@vger.kernel.org
To: wimax@linuxwimax.org
Return-path: <wimax-bounces@linuxwimax.org>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix printk format warnings:

drivers/net/wimax/i2400m/netdev.c:523: warning: format '%zu' expects type 'size_t', but argument 7 has type 'unsigned int'
drivers/net/wimax/i2400m/netdev.c:548: warning: format '%zu' expects type 'size_t', but argument 7 has type 'unsigned int'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/netdev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index a98eb4b..6b1fe7a 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -520,7 +520,7 @@ void i2400m_net_erx(struct i2400m *i2400m, struct sk_buff *skb,
 	struct device *dev = i2400m_dev(i2400m);
 	int protocol;
 
-	d_fnstart(2, dev, "(i2400m %p skb %p [%zu] cs %d)\n",
+	d_fnstart(2, dev, "(i2400m %p skb %p [%u] cs %d)\n",
 		  i2400m, skb, skb->len, cs);
 	switch(cs) {
 	case I2400M_CS_IPV4_0:
@@ -545,7 +545,7 @@ void i2400m_net_erx(struct i2400m *i2400m, struct sk_buff *skb,
 	d_dump(4, dev, skb->data, skb->len);
 	netif_rx_ni(skb);	/* see notes in function header */
 error:
-	d_fnend(2, dev, "(i2400m %p skb %p [%zu] cs %d) = void\n",
+	d_fnend(2, dev, "(i2400m %p skb %p [%u] cs %d) = void\n",
 		i2400m, skb, skb->len, cs);
 }
 
-- 
1.5.6.5
