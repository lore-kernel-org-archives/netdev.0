From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9 2/2] via-velocity: get rid of unused global
Date: Mon, 18 Oct 2004 14:09:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018140913.4b00ec14@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Get rid of unused global variable, name the enum instead.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


diff -Nru a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
--- a/drivers/net/via-velocity.h	2004-10-18 14:04:11 -07:00
+++ b/drivers/net/via-velocity.h	2004-10-18 14:04:11 -07:00
@@ -291,10 +291,10 @@
 	dma_addr_t buf_dma;
 };
 
-enum {
+enum  velocity_owner {
 	OWNED_BY_HOST = 0,
 	OWNED_BY_NIC = 1
-} velocity_owner;
+};
 
 
 /*
