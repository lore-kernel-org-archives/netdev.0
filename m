From: Cong Wang <amwang@redhat.com>
Subject: [PATCH] iproute2: update usage info of bridge monitor
Date: Fri, 14 Dec 2012 13:59:32 +0800
Message-ID: <1355464772-17712-1-git-send-email-amwang@redhat.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	bridge@lists.linux-foundation.org, Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Cc: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/bridge/monitor.c b/bridge/monitor.c
index 44e14d8..29bb931 100644
--- a/bridge/monitor.c
+++ b/bridge/monitor.c
@@ -31,7 +31,7 @@ int prefix_banner;
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: bridge monitor\n");
+	fprintf(stderr, "Usage: bridge monitor [file | link | fdb | mdb | all]\n");
 	exit(-1);
 }
 
