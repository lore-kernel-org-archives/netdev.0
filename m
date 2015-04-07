From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v4 1/3] Document AF_RDS, PF_RDS and SOL_RDS correctly.
Date: Tue,  7 Apr 2015 16:38:02 -0400
Message-ID: <b16dfaff3473b8bfc1f660dd7a27bcb7ff980c94.1428437150.git.sowmini.varadhan@oracle.com>
References: <cover.1428437150.git.sowmini.varadhan@oracle.com>
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, agrover@redhat.com, clm@fb.com,
	zab@zabbo.net, ajaykumar.hotchandani@oracle.com,
	sergei.shtylyov@cogentembedded.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1428437150.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1428437150.git.sowmini.varadhan@oracle.com>
References: <cover.1428437150.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

AF_RDS, PF_RDS and SOL_RDS are available in header files,
and there is no need to get their values from /proc. Document
this correctly.

Fixes: 0c5f9b8830aa ("RDS: Documentation")

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
v4: this change replaces the v3 modifications to sysctl.c

 Documentation/networking/rds.txt |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/rds.txt b/Documentation/networking/rds.txt
index c67077c..e1a3d59 100644
--- a/Documentation/networking/rds.txt
+++ b/Documentation/networking/rds.txt
@@ -62,11 +62,10 @@ Socket Interface
 ================
 
   AF_RDS, PF_RDS, SOL_RDS
-        These constants haven't been assigned yet, because RDS isn't in
-        mainline yet. Currently, the kernel module assigns some constant
-        and publishes it to user space through two sysctl files
-                /proc/sys/net/rds/pf_rds
-                /proc/sys/net/rds/sol_rds
+	AF_RDS and PF_RDS are the domain type to be used with socket(2)
+	to create RDS sockets. SOL_RDS is the socket-level to be used
+	with setsockopt(2) and getsockopt(2) for RDS specific socket
+	options.
 
   fd = socket(PF_RDS, SOCK_SEQPACKET, 0);
         This creates a new, unbound RDS socket.
-- 
1.7.1
