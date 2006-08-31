From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] change somaxconn sysctl  to __read_mostly
Date: Thu, 31 Aug 2006 16:35:33 -0400
Message-ID: <44F74815.5030006@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010607040205050301050306"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:26776 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1750818AbWHaUfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 16:35:37 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010607040205050301050306
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Change sysctl_somaxconn to __read_mostly.

Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------010607040205050301050306
Content-Type: text/x-patch;
 name="socket.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="socket.patch"

diff --git a/net/socket.c b/net/socket.c
index f4d143c..e3d67fe 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1336,7 +1336,7 @@ asmlinkage long sys_bind(int fd, struct 
  *	ready for listening.
  */
 
-int sysctl_somaxconn = SOMAXCONN;
+int sysctl_somaxconn __read_mostly = SOMAXCONN;
 
 asmlinkage long sys_listen(int fd, int backlog)
 {

--------------010607040205050301050306--
