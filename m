From: Vladimir Zapolskiy <vladimir_zapolskiy@mentor.com>
Subject: [PATCH 3.14] net: sysctl_net_core: remove compiler warning about unused variable 'one'
Date: Tue, 11 Aug 2015 15:42:45 +0300
Message-ID: <1439296965-5181-1-git-send-email-vladimir_zapolskiy@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Dirk Behme <dirk.behme@de.bosch.com>, <netdev@vger.kernel.org>,
	<stable@vger.kernel.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dirk Behme <dirk.behme@de.bosch.com>

Remove the compiler warning

  net/core/sysctl_net_core.c:26:12: warning: 'one' defined but not used [-Wunused-variable]
     static int one = 1;

introduced by the 3.14.37 stable commit a1d55b36de6bf2 ("net: sysctl_net_core:
check SNDBUF and RCVBUF for min length") which made 'one' obsolete (in
contrast to recent mainline kernel, which still uses 'one').

Signed-off-by: Dirk Behme <dirk.behme@de.bosch.com>
Signed-off-by: Vladimir Zapolskiy <vladimir_zapolskiy@mentor.com>
Cc: <netdev@vger.kernel.org>
Cc: <stable@vger.kernel.org> # 3.14.x-
Fixes: a1d55b36de6b ("net: sysctl_net_core: check SNDBUF and RCVBUF for min length")
---
 net/core/sysctl_net_core.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index e731c96..8725b91 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -23,7 +23,6 @@
 #include <net/pkt_sched.h>
 
 static int zero = 0;
-static int one = 1;
 static int ushort_max = USHRT_MAX;
 static int min_sndbuf = SOCK_MIN_SNDBUF;
 static int min_rcvbuf = SOCK_MIN_RCVBUF;
-- 
2.1.4
