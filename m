From: Kevin Brosius <cobra@compuserve.com>
Subject: Re: [PATCH] 2.6.0-test4 SEQ_START_TOKEN net/* (2/6)
Date: Tue, 09 Sep 2003 22:11:22 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F5E884A.E62D27EE@compuserve.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------49A81D5250D4DF80A629C1DE"
Cc: Joe@perches.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kernel <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------49A81D5250D4DF80A629C1DE
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

This patch to net/appletalk/aarp.c seemed fine, however it seems it
changed prior to hitting the bk tree.  The attached is needed to
compile.

-- 
Kevin
--------------49A81D5250D4DF80A629C1DE
Content-Type: text/plain; charset=us-ascii;
 name="patch_aarp_bk.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch_aarp_bk.diff"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1238  -> 1.1239 
#	net/appletalk/aarp.c	1.17    -> 1.18   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/09	cobra@sea.kevb.net	1.1239
# Fixup typo
# --------------------------------------------
#
diff -Nru a/net/appletalk/aarp.c b/net/appletalk/aarp.c
--- a/net/appletalk/aarp.c	Tue Sep  9 22:05:25 2003
+++ b/net/appletalk/aarp.c	Tue Sep  9 22:05:25 2003
@@ -941,7 +941,7 @@
 	iter->table     = resolved;
 	iter->bucket    = 0;
 
-	return *pos ? iter_next(iter, pos) : SEQ_START_TOKEN);
+	return *pos ? iter_next(iter, pos) : SEQ_START_TOKEN;
 }
 
 static void *aarp_seq_next(struct seq_file *seq, void *v, loff_t *pos)

--------------49A81D5250D4DF80A629C1DE--
