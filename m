From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: [PATCH] mv643xx_eth: remove repeated includes of linux/in.h and linux/ip.h
Date: Wed, 8 Feb 2006 05:28:21 -0700
Message-ID: <20060208122821.GA944@xyzzy.farnsworth.org>
References: <E1F6fqN-0006Ba-W6@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Al Viro <viro@ftp.linux.org.uk>, Olaf Hering <olh@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030365AbWBHM2X@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <E1F6fqN-0006Ba-W6@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dale Farnsworth <dale@farnsworth.org>

Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

---

These includes were added twice:
in commit 78a5e534758349fd3effc90ce1152b55368f52ee by Olaf Hering and
in commit b6298c22c5e9f698812e2520003ee178aad50c10 by Al Viro.
This patch reverts 78a5e534758349fd3effc90ce1152b55368f52ee.

They probably should have been included before linux/tcp.h in
the first place.

 drivers/net/mv643xx_eth.c |    2 --
 1 file changed, 2 deletions(-)

Index: linux-2.6-mv643xx_enet/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6-mv643xx_enet.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6-mv643xx_enet/drivers/net/mv643xx_eth.c
@@ -37,8 +37,6 @@
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/etherdevice.h>
-#include <linux/in.h>
-#include <linux/ip.h>
 
 #include <linux/bitops.h>
 #include <linux/delay.h>
