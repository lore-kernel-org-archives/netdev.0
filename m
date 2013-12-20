From: Chen Weilong <chenweilong@huawei.com>
Subject: [PATCH 2/2] llc: fix checkpatch errors with space
Date: Fri, 20 Dec 2013 11:15:00 +0800
Message-ID: <1387509300-11940-2-git-send-email-chenweilong@huawei.com>
References: <1387509300-11940-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <acme@ghostprotocols.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:42005 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689Ab3LTDPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 22:15:19 -0500
In-Reply-To: <1387509300-11940-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>


Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/llc/af_llc.c   | 2 +-
 net/llc/llc_c_ac.c | 2 +-
 net/llc/llc_pdu.c  | 2 +-
 net/llc/llc_proc.c | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 7b01b9f..0335407 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -980,7 +980,7 @@ static int llc_ui_getname(struct socket *sock, struct sockaddr *uaddr,
 		rc = -ENOTCONN;
 		if (sk->sk_state != TCP_ESTABLISHED)
 			goto out;
-		if(llc->dev)
+		if (llc->dev)
 			sllc.sllc_arphrd = llc->dev->type;
 		sllc.sllc_sap = llc->daddr.lsap;
 		memcpy(&sllc.sllc_mac, &llc->daddr.mac, IFHWADDRLEN);
diff --git a/net/llc/llc_c_ac.c b/net/llc/llc_c_ac.c
index ea225bd..91dba83 100644
--- a/net/llc/llc_c_ac.c
+++ b/net/llc/llc_c_ac.c
@@ -1024,7 +1024,7 @@ int llc_conn_ac_adjust_npta_by_rr(struct sock *sk, struct sk_buff *skb)
 				if (llc->npta > 0)
 					llc->npta = llc->npta - 1;
 			} else
-				llc->dec_cntr -=1;
+				llc->dec_cntr -= 1;
 		}
 	} else
 		llc->connect_step = 0 ;
diff --git a/net/llc/llc_pdu.c b/net/llc/llc_pdu.c
index 2e6cb79..dea9b43 100644
--- a/net/llc/llc_pdu.c
+++ b/net/llc/llc_pdu.c
@@ -231,7 +231,7 @@ void llc_pdu_init_as_frmr_rsp(struct sk_buff *skb, struct llc_pdu_sn *prev_pdu,
 
 	frmr_info = (struct llc_frmr_info *)&pdu->ctrl_2;
 	ctrl = (u8 *)&prev_pdu->ctrl_1;
-	FRMR_INFO_SET_REJ_CNTRL(frmr_info,ctrl);
+	FRMR_INFO_SET_REJ_CNTRL(frmr_info, ctrl);
 	FRMR_INFO_SET_Vs(frmr_info, vs);
 	FRMR_INFO_SET_Vr(frmr_info, vr);
 	prev_pf = llc_pdu_get_pf_bit(prev_pdu);
diff --git a/net/llc/llc_proc.c b/net/llc/llc_proc.c
index 1a3c7e0..abf28eb 100644
--- a/net/llc/llc_proc.c
+++ b/net/llc/llc_proc.c
@@ -142,7 +142,7 @@ static int llc_seq_socket_show(struct seq_file *seq, void *v)
 	if (llc->dev)
 		llc_ui_format_mac(seq, llc->dev->dev_addr);
 	else {
-		u8 addr[6] = {0,0,0,0,0,0};
+		u8 addr[6] = {0, 0, 0, 0, 0, 0};
 		llc_ui_format_mac(seq, addr);
 	}
 	seq_printf(seq, "@%02X ", llc->sap->laddr.lsap);
-- 
1.7.12
