From: Joe Perches <joe@perches.com>
Subject: [PATCH 32/36] net/irda: Remove unnecessary casts of private_data
Date: Mon, 12 Jul 2010 13:50:24 -0700
Message-ID: <0f791bb0d02971908720f0d09b4d8ff9140bb6d0.1278967121.git.joe@perches.com>
References: <cover.1278967120.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org, Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1800 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755109Ab0GLUvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jul 2010 16:51:08 -0400
In-Reply-To: <cover.1278967120.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/irda/irnet/irnet_ppp.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/irda/irnet/irnet_ppp.c b/net/irda/irnet/irnet_ppp.c
index 6a1a202..800bc53 100644
--- a/net/irda/irnet/irnet_ppp.c
+++ b/net/irda/irnet/irnet_ppp.c
@@ -527,7 +527,7 @@ static int
 dev_irnet_close(struct inode *	inode,
 		struct file *	file)
 {
-  irnet_socket *	ap = (struct irnet_socket *) file->private_data;
+  irnet_socket *	ap = file->private_data;
 
   DENTER(FS_TRACE, "(file=0x%p, ap=0x%p)\n",
 	 file, ap);
@@ -564,7 +564,7 @@ dev_irnet_write(struct file *	file,
 		size_t		count,
 		loff_t *	ppos)
 {
-  irnet_socket *	ap = (struct irnet_socket *) file->private_data;
+  irnet_socket *	ap = file->private_data;
 
   DPASS(FS_TRACE, "(file=0x%p, ap=0x%p, count=%Zd)\n",
 	file, ap, count);
@@ -588,7 +588,7 @@ dev_irnet_read(struct file *	file,
 	       size_t		count,
 	       loff_t *		ppos)
 {
-  irnet_socket *	ap = (struct irnet_socket *) file->private_data;
+  irnet_socket *	ap = file->private_data;
 
   DPASS(FS_TRACE, "(file=0x%p, ap=0x%p, count=%Zd)\n",
 	file, ap, count);
@@ -609,7 +609,7 @@ static unsigned int
 dev_irnet_poll(struct file *	file,
 	       poll_table *	wait)
 {
-  irnet_socket *	ap = (struct irnet_socket *) file->private_data;
+  irnet_socket *	ap = file->private_data;
   unsigned int		mask;
 
   DENTER(FS_TRACE, "(file=0x%p, ap=0x%p)\n",
@@ -638,7 +638,7 @@ dev_irnet_ioctl(
 		unsigned int	cmd,
 		unsigned long	arg)
 {
-  irnet_socket *	ap = (struct irnet_socket *) file->private_data;
+  irnet_socket *	ap = file->private_data;
   int			err;
   int			val;
   void __user *argp = (void __user *)arg;
-- 
1.7.1.337.g6068.dirty

