From: Rakib Mullick <rakib.mullick@gmail.com>
Subject: [PATCH] net,bonding: Add return statement in bond_create_proc_entry.
Date: Sat, 10 Oct 2009 08:10:58 +0600
Message-ID: <b9df5fa10910091910u1b6bf14bg2781cb12c58b21f9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bonding-devel@lists.sourceforge.net
To: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f177.google.com ([209.85.222.177]:40573 "EHLO
	mail-pz0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934587AbZJJCLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 22:11:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function bond_create_proc_entry supposed to return int instead of void.
And fixes the following compilation warning.

drivers/net/bonding/bond_main.c: In function `bond_create_proc_entry':
drivers/net/bonding/bond_main.c:3393: warning: control reaches end of
non-void function

---
Signed-off-by: Rakib Mullick <rakib.mullick@gmail.com>

--- linus/drivers/net/bonding/bond_main.c	2009-10-09 17:38:35.000000000 +0600
+++ rakib/drivers/net/bonding/bond_main.c	2009-10-09 17:47:46.000000000 +0600
@@ -3391,6 +3391,7 @@ static void bond_destroy_proc_dir(void)

 static int bond_create_proc_entry(struct bonding *bond)
 {
+	return 0;
 }

 static void bond_remove_proc_entry(struct bonding *bond)
