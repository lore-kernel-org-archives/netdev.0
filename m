From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] trivial -- remove unused prototype from Space.c
Date: Wed, 15 Oct 2003 12:21:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031015122121.658d652e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The prototype for iph5526_probe is no longer used, it is a left over
from when fiber channel probed in Space.c

Jeff, you may just want to put this in net-2.5-exp

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Wed Oct 15 12:19:11 2003
+++ b/drivers/net/Space.c	Wed Oct 15 12:19:11 2003
@@ -98,9 +98,6 @@
 /* Detachable devices ("pocket adaptors") */
 extern int de620_probe(struct net_device *);
 
-/* Fibre Channel adapters */
-extern int iph5526_probe(struct net_device *dev);
-
 /* SBNI adapters */
 extern int sbni_probe(int unit);
 
