From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/23) sk98: local variable can be constant
Date: Thu, 11 Nov 2004 15:53:36 -0800
Message-ID: <20041111155336.2c7a9b79@zqx3.pdx.osdl.net>
References: <4192C60A.1050205@designassembly.de>
	<20041111154225.5cf85567@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Heyse <mhk@designassembly.de>,
        Mirko Lindner
 <mlindner@syskonnect.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20041111154225.5cf85567@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


The table OnesHash is only used in this file, and should
be made a local constant.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skaddr.c b/drivers/net/sk98lin/skaddr.c
--- a/drivers/net/sk98lin/skaddr.c	2004-11-03 14:07:28 -08:00
+++ b/drivers/net/sk98lin/skaddr.c	2004-11-03 14:07:28 -08:00
@@ -79,7 +79,7 @@
 
 /* 64-bit hash values with all bits set. */
 
-SK_U16	OnesHash[4] = {0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF};
+static const SK_U16	OnesHash[4] = {0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF};
 
 /* local variables ************************************************************/
 
