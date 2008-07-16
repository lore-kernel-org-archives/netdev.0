From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH (resend) 7/20] mib: drop unused TCP MIB accounting macros
Date: Wed, 16 Jul 2008 12:43:54 +0400
Message-ID: <487DB4CA.60500@openvz.org>
References: <487DABB6.5080905@openvz.org> <487DAE95.4090608@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:53443 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751738AbYGPIoA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 04:44:00 -0400
In-Reply-To: <487DAE95.4090608@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vger rejected triple X in the first version subject, so I 
resend the patch.

Log:

TCP_INC_STATS_USER and TCP_ADD_STATS_BH are currently unused.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/tcp.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6b827cc..048f8de 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -268,9 +268,7 @@ extern struct proto tcp_prot;
 DECLARE_SNMP_STAT(struct tcp_mib, tcp_statistics);
 #define TCP_INC_STATS(field)		SNMP_INC_STATS(tcp_statistics, field)
 #define TCP_INC_STATS_BH(field)		SNMP_INC_STATS_BH(tcp_statistics, field)
-#define TCP_INC_STATS_USER(field) 	SNMP_INC_STATS_USER(tcp_statistics, field)
 #define TCP_DEC_STATS(field)		SNMP_DEC_STATS(tcp_statistics, field)
-#define TCP_ADD_STATS_BH(field, val)	SNMP_ADD_STATS_BH(tcp_statistics, field, val)
 #define TCP_ADD_STATS_USER(field, val)	SNMP_ADD_STATS_USER(tcp_statistics, field, val)
 
 extern void			tcp_v4_err(struct sk_buff *skb, u32);
-- 1.5.5.1 
