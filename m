From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 4/8] [NET] sysctl: fix sparse warning: Should it be static?
Date: Wed, 25 Feb 2009 21:32:14 +0100
Message-ID: <20090225203208.6251.48572.stgit@vmbox.hanneseder.net>
References: <20090225203012.6251.32002.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760079AbZBYUiD@vger.kernel.org>
In-Reply-To: <20090225203012.6251.32002.stgit@vmbox.hanneseder.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Impact: Include header file.

Fix this sparse warning:
  net/core/sysctl_net_core.c:123:32: warning: symbol 'net_core_path' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 net/core/sysctl_net_core.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 83d3398..7db1de0 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -11,6 +11,7 @@
 #include <linux/socket.h>
 #include <linux/netdevice.h>
 #include <linux/init.h>
+#include <net/ip.h>
 #include <net/sock.h>
 
 static struct ctl_table net_core_table[] = {
