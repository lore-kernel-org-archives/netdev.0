From: Bart Van Assche <bart.vanassche@sandisk.com>
Subject: [PATCH] fcntl.h: Fix a typo
Date: Sun, 01 Feb 2015 13:07:21 +0100
Message-ID: <54CE16F9.7030706@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf2.bxl.stone.is ([5.134.1.239]:52704 "EHLO sf2.bxl.stone.is"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752779AbbBAMaX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Feb 2015 07:30:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the source file fs/fcntl.c and also in the fcntl() man page one
can see that the FD_CLOEXEC flag can be manipulated via F_GETFD
and F_SETFD. Update the comment in <fcntl.h> accordingly.

Signed-off-by: Bart Van Assche <bart.vanassche@sandisk.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
---
 include/uapi/asm-generic/fcntl.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/asm-generic/fcntl.h b/include/uapi/asm-generic/fcntl.h
index e063eff..584fa2b 100644
--- a/include/uapi/asm-generic/fcntl.h
+++ b/include/uapi/asm-generic/fcntl.h
@@ -157,7 +157,7 @@ struct f_owner_ex {
 	__kernel_pid_t	pid;
 };
 
-/* for F_[GET|SET]FL */
+/* for F_[GET|SET]FD */
 #define FD_CLOEXEC	1	/* actually anything with low bit set goes */
 
 /* for posix fcntl() and lockf() */
-- 
2.1.4
