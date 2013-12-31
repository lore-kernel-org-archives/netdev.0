From: Chen Weilong <chenweilong@huawei.com>
Subject: [PATCH 2/2] ipv4: switch and case should be at the same indent
Date: Tue, 31 Dec 2013 15:11:28 +0800
Message-ID: <1388473888-10860-2-git-send-email-chenweilong@huawei.com>
References: <1388473888-10860-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:34081 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811Ab3LaHMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 02:12:08 -0500
In-Reply-To: <1388473888-10860-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>


Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/ipv4/ip_options.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index dd9d90b..f4ab72e 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -275,7 +275,7 @@ int ip_options_compile(struct net *net,
 
 	for (l = opt->optlen; l > 0; ) {
 		switch (*optptr) {
-		      case IPOPT_END:
+		case IPOPT_END:
 			for (optptr++, l--; l > 0; optptr++, l--) {
 				if (*optptr != IPOPT_END) {
 					*optptr = IPOPT_END;
@@ -283,7 +283,7 @@ int ip_options_compile(struct net *net,
 				}
 			}
 			goto eol;
-		      case IPOPT_NOOP:
+		case IPOPT_NOOP:
 			l--;
 			optptr++;
 			continue;
@@ -294,8 +294,8 @@ int ip_options_compile(struct net *net,
 			goto error;
 		}
 		switch (*optptr) {
-		      case IPOPT_SSRR:
-		      case IPOPT_LSRR:
+		case IPOPT_SSRR:
+		case IPOPT_LSRR:
 			if (optlen < 3) {
 				pp_ptr = optptr + 1;
 				goto error;
@@ -321,7 +321,7 @@ int ip_options_compile(struct net *net,
 			opt->is_strictroute = (optptr[0] == IPOPT_SSRR);
 			opt->srr = optptr - iph;
 			break;
-		      case IPOPT_RR:
+		case IPOPT_RR:
 			if (opt->rr) {
 				pp_ptr = optptr;
 				goto error;
@@ -349,7 +349,7 @@ int ip_options_compile(struct net *net,
 			}
 			opt->rr = optptr - iph;
 			break;
-		      case IPOPT_TIMESTAMP:
+		case IPOPT_TIMESTAMP:
 			if (opt->ts) {
 				pp_ptr = optptr;
 				goto error;
@@ -369,13 +369,13 @@ int ip_options_compile(struct net *net,
 					goto error;
 				}
 				switch (optptr[3]&0xF) {
-				      case IPOPT_TS_TSONLY:
+				case IPOPT_TS_TSONLY:
 					if (skb)
 						timeptr = &optptr[optptr[2]-1];
 					opt->ts_needtime = 1;
 					optptr[2] += 4;
 					break;
-				      case IPOPT_TS_TSANDADDR:
+				case IPOPT_TS_TSANDADDR:
 					if (optptr[2]+7 > optptr[1]) {
 						pp_ptr = optptr + 2;
 						goto error;
@@ -389,7 +389,7 @@ int ip_options_compile(struct net *net,
 					opt->ts_needtime = 1;
 					optptr[2] += 8;
 					break;
-				      case IPOPT_TS_PRESPEC:
+				case IPOPT_TS_PRESPEC:
 					if (optptr[2]+7 > optptr[1]) {
 						pp_ptr = optptr + 2;
 						goto error;
@@ -405,7 +405,7 @@ int ip_options_compile(struct net *net,
 					opt->ts_needtime = 1;
 					optptr[2] += 8;
 					break;
-				      default:
+				default:
 					if (!skb && !ns_capable(net->user_ns, CAP_NET_RAW)) {
 						pp_ptr = optptr + 3;
 						goto error;
@@ -433,7 +433,7 @@ int ip_options_compile(struct net *net,
 			}
 			opt->ts = optptr - iph;
 			break;
-		      case IPOPT_RA:
+		case IPOPT_RA:
 			if (optlen < 4) {
 				pp_ptr = optptr + 1;
 				goto error;
@@ -441,7 +441,7 @@ int ip_options_compile(struct net *net,
 			if (optptr[2] == 0 && optptr[3] == 0)
 				opt->router_alert = optptr - iph;
 			break;
-		      case IPOPT_CIPSO:
+		case IPOPT_CIPSO:
 			if ((!skb && !ns_capable(net->user_ns, CAP_NET_RAW)) || opt->cipso) {
 				pp_ptr = optptr;
 				goto error;
@@ -452,9 +452,9 @@ int ip_options_compile(struct net *net,
 				goto error;
 			}
 			break;
-		      case IPOPT_SEC:
-		      case IPOPT_SID:
-		      default:
+		case IPOPT_SEC:
+		case IPOPT_SID:
+		default:
 			if (!skb && !ns_capable(net->user_ns, CAP_NET_RAW)) {
 				pp_ptr = optptr;
 				goto error;
-- 
1.7.12
