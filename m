From: Olaf Hering <olh@suse.de>
Subject: [PATCH] fix typo in include/linux/socket.h
Date: Mon, 14 Feb 2005 18:47:39 +0100
Message-ID: <20050214174739.GA23145@suse.de>
References: <20050212171521.GA3497@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050212171521.GA3497@suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I guess we have to reduce the patch to fix just the typo.

Signed-off-by: Olaf Hering <olh@suse.de>

diff -purN linux-2.6.11-rc3-bk8/include/linux/socket.h linux-2.6.11/include/linux/socket.h
--- linux-2.6.11-rc3-bk8/include/linux/socket.h	2005-02-03 02:56:33.000000000 +0100
+++ linux-2.6.11/include/linux/socket.h	2005-02-12 18:05:10.000000000 +0100
@@ -120,7 +108,7 @@ struct cmsghdr {
  *	Now it always returns valid, not truncated ancillary object
  *	HEADER. But caller still MUST check, that cmsg->cmsg_len is
  *	inside range, given by msg->msg_controllen before using
- *	ansillary object DATA.				--ANK (980731)
+ *	ancillary object DATA.				--ANK (980731)
  */
  
 __KINLINE struct cmsghdr * __cmsg_nxthdr(void *__ctl, __kernel_size_t __size,
