From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] export dev_get_flags
Date: Tue, 15 Mar 2005 23:31:12 +0100
Message-ID: <20050315223112.GX3189@stusta.de>
References: <200503151852.j2FIqr8t009525@clem.clem-digital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
        davem@davemloft.net, netdev@oss.sgi.com
To: Pete Clements <clem@clem.clem-digital.net>
Content-Disposition: inline
In-Reply-To: <200503151852.j2FIqr8t009525@clem.clem-digital.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 15, 2005 at 01:52:53PM -0500, Pete Clements wrote:

> Fyi:
>   2.6.11.3-bk1 net/ipv6/ipv6.ko missing symbol dev_get_flags

It seems this patch is required (untested).

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.11-mm3-full/net/core/dev.c.old	2005-03-15 20:13:52.000000000 +0100
+++ linux-2.6.11-mm3-full/net/core/dev.c	2005-03-15 20:14:32.000000000 +0100
@@ -2214,6 +2214,7 @@
 
 	return flags;
 }
+EXPORT_SYMBOL_GPL(dev_get_flags);
 
 int dev_change_flags(struct net_device *dev, unsigned flags)
 {
