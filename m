From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.9] hp100: use module_param and netdev_priv
Date: Mon, 18 Oct 2004 13:40:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018134002.695c347e@zqx3.pdx.osdl.net>
References: <20041018121527.053b3309@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Jean Tourrilhes <jt@bougret.hpl.hp.com>
In-Reply-To: <20041018121527.053b3309@zqx3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

One more module_param here.
Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/hp100.c b/drivers/net/hp100.c
--- a/drivers/net/hp100.c	2004-10-18 13:38:10 -07:00
+++ b/drivers/net/hp100.c	2004-10-18 13:38:10 -07:00
@@ -3003,7 +3003,8 @@
 #define HP100_DEVICES 5
 /* Parameters set by insmod */
 static int hp100_port[HP100_DEVICES] = { 0, [1 ... (HP100_DEVICES-1)] = -1 };
-MODULE_PARM(hp100_port, "1-" __MODULE_STRING(HP100_DEVICES) "i");
+static int nports;
+module_param_array(hp100_port, int, nports, 0);
 
 /* List of devices */
 static struct net_device *hp100_devlist[HP100_DEVICES];
