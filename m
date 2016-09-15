From: Alan <alan@linux.intel.com>
Subject: [PATCH] llc: switch type to bool as the timeout is only tested
 versus 0
Date: Thu, 15 Sep 2016 18:51:25 +0100
Message-ID: <147396186808.57417.10184810920101482487.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:54496 "EHLO
        lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751861AbcIORvd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 13:51:33 -0400
Received: from localhost.localdomain (proxy [81.2.110.250])
        by lxorguk.ukuu.org.uk (8.15.2/8.14.1) with ESMTP id u8FIelnO031320
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 19:40:53 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(As asked by Dave in Februrary)

Signed-off-by: Alan Cox <alan@linux.intel.com>

---
 net/llc/af_llc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 8ae3ed9..db916cf 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -38,7 +38,7 @@ static u16 llc_ui_sap_link_no_max[256];
 static struct sockaddr_llc llc_ui_addrnull;
 static const struct proto_ops llc_ui_ops;
 
-static long llc_ui_wait_for_conn(struct sock *sk, long timeout);
+static bool llc_ui_wait_for_conn(struct sock *sk, long timeout);
 static int llc_ui_wait_for_disc(struct sock *sk, long timeout);
 static int llc_ui_wait_for_busy_core(struct sock *sk, long timeout);
 
@@ -551,7 +551,7 @@ static int llc_ui_wait_for_disc(struct sock *sk, long timeout)
 	return rc;
 }
 
-static long llc_ui_wait_for_conn(struct sock *sk, long timeout)
+static bool llc_ui_wait_for_conn(struct sock *sk, long timeout)
 {
 	DEFINE_WAIT(wait);
 
