From: Richard Weinberger <richard@nod.at>
Subject: [PATCH] Documentation: Update netlink_mmap.txt
Date: Fri, 30 Jan 2015 20:50:44 +0100
Message-ID: <1422647444-4004-1-git-send-email-richard@nod.at>
Cc: corbet@lwn.net, shemming@brocade.com, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Richard Weinberger <richard@nod.at>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update netlink_mmap.txt wrt. commit 4682a0358639b29cf
("netlink: Always copy on mmap TX.").

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 Documentation/networking/netlink_mmap.txt | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/Documentation/networking/netlink_mmap.txt b/Documentation/networking/netlink_mmap.txt
index c6af4ba..30a95fd 100644
--- a/Documentation/networking/netlink_mmap.txt
+++ b/Documentation/networking/netlink_mmap.txt
@@ -199,16 +199,9 @@ frame header.
 TX limitations
 --------------
 
-Kernel processing usually involves validation of the message received by
-user-space, then processing its contents. The kernel must assure that
-userspace is not able to modify the message contents after they have been
-validated. In order to do so, the message is copied from the ring frame
-to an allocated buffer if either of these conditions is false:
-
-- only a single mapping of the ring exists
-- the file descriptor is not shared between processes
-
-This means that for threaded programs, the kernel will fall back to copying.
+As of Jan 2015 the message is always copied from the ring frame to an
+allocated buffer due to unresolved security concerns.
+See commit 4682a0358639b29cf ("netlink: Always copy on mmap TX.").
 
 Example
 -------
-- 
2.2.2
