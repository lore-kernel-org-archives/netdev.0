From: akpm@linux-foundation.org
Subject: [patch 1/2] drivers-net-tulip-de4x5c-fix-copy-length-in-de4x5_ioctl-checkpatch-fixes
Date: Fri, 01 Oct 2010 14:17:12 -0700
Message-ID: <201010012117.o91LHCJt021158@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	dan.j.rosenberg@gmail.com, grundler@parisc-linux.org,
	jeffm@suse.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55983 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754851Ab0JAVRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 17:17:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

ERROR: trailing statements should be on next line
#23: FILE: drivers/net/tulip/de4x5.c:5477:
+	if (copy_to_user(ioc->data, tmp.lval, ioc->len)) return -EFAULT;

total: 1 errors, 0 warnings, 8 lines checked

./patches/drivers-net-tulip-de4x5c-fix-copy-length-in-de4x5_ioctl.patch has style problems, please review.  If any of these errors
are false positives report them to the maintainer, see
CHECKPATCH in MAINTAINERS.

Please run checkpatch prior to sending patches

Cc: Dan Rosenberg <dan.j.rosenberg@gmail.com>
Cc: Grant Grundler <grundler@parisc-linux.org>
Cc: Jeff Mahoney <jeffm@suse.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/tulip/de4x5.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN drivers/net/tulip/de4x5.c~drivers-net-tulip-de4x5c-fix-copy-length-in-de4x5_ioctl-checkpatch-fixes drivers/net/tulip/de4x5.c
--- a/drivers/net/tulip/de4x5.c~drivers-net-tulip-de4x5c-fix-copy-length-in-de4x5_ioctl-checkpatch-fixes
+++ a/drivers/net/tulip/de4x5.c
@@ -5474,7 +5474,8 @@ de4x5_ioctl(struct net_device *dev, stru
 	tmp.lval[6] = inl(DE4X5_STRR); j+=4;
 	tmp.lval[7] = inl(DE4X5_SIGR); j+=4;
 	ioc->len = j;
-	if (copy_to_user(ioc->data, tmp.lval, ioc->len)) return -EFAULT;
+	if (copy_to_user(ioc->data, tmp.lval, ioc->len))
+		return -EFAULT;
 	break;
 
 #define DE4X5_DUMP              0x0f /* Dump the DE4X5 Status */
_
