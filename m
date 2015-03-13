From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 5/8] iproute2: misc whitespace cleanup
Date: Fri, 13 Mar 2015 13:56:05 -0500
Message-ID: <87egosraka.fsf@x220.int.ebiederm.org>
References: <87bnjwspek.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:47578 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754352AbbCMS7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 14:59:47 -0400
In-Reply-To: <87bnjwspek.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 13 Mar 2015 13:50:11 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This removes an extra space and causes things to line up.

---
 ip/iptunnel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 29188c450370..be84b83ec673 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -342,7 +342,7 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 	printf("%s: %s/ip  remote %s  local %s ",
 	       p->name,
 	       tnl_strproto(p->iph.protocol),
-	       p->iph.daddr ? format_host(AF_INET, 4, &p->iph.daddr, s1, sizeof(s1))  : "any",
+	       p->iph.daddr ? format_host(AF_INET, 4, &p->iph.daddr, s1, sizeof(s1)) : "any",
 	       p->iph.saddr ? rt_addr_n2a(AF_INET, 4, &p->iph.saddr, s2, sizeof(s2)) : "any");
 
 	if (p->iph.protocol == IPPROTO_IPV6 && (p->i_flags & SIT_ISATAP)) {
-- 
2.2.1
