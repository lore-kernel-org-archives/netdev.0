From: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Subject: [PATCH] socket.7: Correctly describe SO_SNDTIMEO for connect
Date: Thu,  8 Nov 2012 07:55:23 -0800
Message-ID: <1352390123-28658-1-git-send-email-andi@firstfloor.org>
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andi Kleen <ak-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

When SO_SNDTIMEO is set before connect() connect may return EWOULDBLOCK
when the timeout fires. Describe this correctly.

Signed-off-by: Andi Kleen <ak-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
---
 man7/socket.7 |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/man7/socket.7 b/man7/socket.7
index cd75746..9e05f48 100644
--- a/man7/socket.7
+++ b/man7/socket.7
@@ -434,6 +434,9 @@ set to
 .B EAGAIN
 or
 .B EWOULDBLOCK
+or
+.B EINPROGRESS
+(for connect)
 .\" in fact to EAGAIN
 just as if the socket was specified to be nonblocking.
 If the timeout is set to zero (the default)
@@ -442,6 +445,7 @@ Timeouts only have effect for system calls that perform socket I/O (e.g.,
 .BR read (2),
 .BR recvmsg (2),
 .BR send (2),
+.BR connect (2),
 .BR sendmsg (2));
 timeouts have no effect for
 .BR select (2),
-- 
1.7.7.6

--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
