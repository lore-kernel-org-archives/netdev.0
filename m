From: akpm@osdl.org
Subject: [patch 5/6] atm/mpc.c warning fix
Date: Sun, 25 Jun 2006 01:47:32 -0700
Message-ID: <200606250847.k5P8lWQq020909@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:21651 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751195AbWFYIrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2006 04:47:51 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Andrew Morton <akpm@osdl.org>

net/atm/mpc.c: In function 'MPOA_res_reply_rcvd':
net/atm/mpc.c:1116: warning: unused variable 'ip'

Cc: chas williams <chas@cmf.nrl.navy.mil>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/atm/mpc.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -puN net/atm/mpc.c~atm-mpcc-warning-fix net/atm/mpc.c
--- a/net/atm/mpc.c~atm-mpcc-warning-fix
+++ a/net/atm/mpc.c
@@ -1113,10 +1113,9 @@ static void check_qos_and_open_shortcut(
 
 static void MPOA_res_reply_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 {
-	unsigned char *ip;
-
 	uint32_t dst_ip = msg->content.in_info.in_dst_ip;
 	in_cache_entry *entry = mpc->in_ops->get(dst_ip, mpc);
+
 	dprintk("mpoa: (%s) MPOA_res_reply_rcvd: ip %u.%u.%u.%u\n", mpc->dev->name, NIPQUAD(dst_ip));
 	ddprintk("mpoa: (%s) MPOA_res_reply_rcvd() entry = %p", mpc->dev->name, entry);
 	if(entry == NULL){
_
