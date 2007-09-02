From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH 1/2] net/: all net/ cleanup with ARRAY_SIZE
Date: Sun,  2 Sep 2007 18:30:17 +0800
Message-ID: <11887290181154-git-send-email-crquan@gmail.com>
References: <Pine.LNX.4.64.0709020235420.22012@localhost.localdomain>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	cr_quan@163.com
To: "Robert P. J. Day" <rpjday@mindspring.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.188]:46459 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756346AbXIBKai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 06:30:38 -0400
Received: by rv-out-0910.google.com with SMTP id k20so721632rvb
        for <netdev@vger.kernel.org>; Sun, 02 Sep 2007 03:30:37 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0709020235420.22012@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Denis Cheng <crquan@gmail.com>
---
 net/atm/proc.c      |    2 +-
 net/decnet/dn_dev.c |    2 +-
 net/ipv4/af_inet.c  |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/atm/proc.c b/net/atm/proc.c
index 99fc1fe..a3e52ff 100644
--- a/net/atm/proc.c
+++ b/net/atm/proc.c
@@ -175,7 +175,7 @@ static void pvc_info(struct seq_file *seq, struct atm_vcc *vcc)
 
 	seq_printf(seq, "%3d %3d %5d %-3s %7d %-5s %7d %-6s",
 	    vcc->dev->number,vcc->vpi,vcc->vci,
-	    vcc->qos.aal >= sizeof(aal_name)/sizeof(aal_name[0]) ? "err" :
+	    vcc->qos.aal >= ARRAY_SIZE(aal_name) ? "err" :
 	    aal_name[vcc->qos.aal],vcc->qos.rxtp.min_pcr,
 	    class_name[vcc->qos.rxtp.traffic_class],vcc->qos.txtp.min_pcr,
 	    class_name[vcc->qos.txtp.traffic_class]);
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index fa6604f..9470cb9 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -149,7 +149,7 @@ static struct dn_dev_parms dn_dev_list[] =  {
 }
 };
 
-#define DN_DEV_LIST_SIZE (sizeof(dn_dev_list)/sizeof(struct dn_dev_parms))
+#define DN_DEV_LIST_SIZE ARRAY_SIZE(dn_dev_list)
 
 #define DN_DEV_PARMS_OFFSET(x) ((int) ((char *) &((struct dn_dev_parms *)0)->x))
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index e681034..d5e8b67 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -939,7 +939,7 @@ static struct inet_protosw inetsw_array[] =
        }
 };
 
-#define INETSW_ARRAY_LEN (sizeof(inetsw_array) / sizeof(struct inet_protosw))
+#define INETSW_ARRAY_LEN ARRAY_SIZE(inetsw_array)
 
 void inet_register_protosw(struct inet_protosw *p)
 {
-- 
1.5.3.rc7

