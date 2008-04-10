From: Joe Perches <joe@perches.com>
Subject: [PATCH net-2.6.26] drivers/net/bonding/bond_main.c - remove
	unnecessary #define
Date: Thu, 10 Apr 2008 14:39:30 -0700
Message-ID: <1207863571.1020.196.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David S Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Chad Tindel <ctindel@users.sourceforge.net>,
	Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:3703 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1756598AbYDJVq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 17:46:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bond_main.c already #includes <linux/seq_file.h>

Signed-off-by: Joe Perches <joe@perches.com>

 drivers/net/bonding/bond_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ecfaf14..6e91b4b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3065,8 +3065,6 @@ out:
 
 #ifdef CONFIG_PROC_FS
 
-#define SEQ_START_TOKEN ((void *)1)
-
 static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	struct bonding *bond = seq->private;


