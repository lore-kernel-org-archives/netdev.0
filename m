From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 5/8] iproute2: misc whitespace cleanup
Date: Sun, 15 Mar 2015 14:51:10 -0500
Message-ID: <87k2yinioh.fsf_-_@x220.int.ebiederm.org>
References: <87bnjwspek.fsf@x220.int.ebiederm.org>
	<c3ad7d77783046d38e5b23b5e1fe0f71@BRMWP-EXMB11.corp.brocade.com>
	<20150315123337.2694183a@urahara>
	<87lhiyoxnw.fsf@x220.int.ebiederm.org>
	<87bnjuoxe8.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:54282 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbbCOTyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 15:54:54 -0400
In-Reply-To: <87bnjuoxe8.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 15 Mar 2015 14:47:59 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


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
