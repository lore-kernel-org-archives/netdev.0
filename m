From: Adrian Bunk <bunk@kernel.org>
Subject: [-mm patch] net/sctp/socket.c: make 3 variables static
Date: Sun, 9 Sep 2007 22:25:54 +0200
Message-ID: <20070909202554.GY3563@stusta.de>
References: <20070831215822.26e1432b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	vladislav.yasevich@hp.com, sri@us.ibm.com, davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760120AbXIIUa5@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070831215822.26e1432b.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 31, 2007 at 09:58:22PM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.23-rc3-mm1:
>...
>  git-net.patch
>...
>  git trees
>...

This patch makes the following needlessly globalvariables static:
- sctp_memory_pressure
- sctp_memory_allocated
- sctp_sockets_allocated

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
3c211ad074038414ebc156b1abbc3df78dc60cb2 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 37e7306..f53545a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -112,9 +112,9 @@ extern int sysctl_sctp_mem[3];
 extern int sysctl_sctp_rmem[3];
 extern int sysctl_sctp_wmem[3];
 
-int sctp_memory_pressure;
-atomic_t sctp_memory_allocated;
-atomic_t sctp_sockets_allocated;
+static int sctp_memory_pressure;
+static atomic_t sctp_memory_allocated;
+static atomic_t sctp_sockets_allocated;
 
 static void sctp_enter_memory_pressure(void)
 {
