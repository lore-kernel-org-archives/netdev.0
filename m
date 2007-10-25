From: David Howells <dhowells@redhat.com>
Subject: [PATCH] NET: Mark snmp4_icmp_list[] as being unused
Date: Thu, 25 Oct 2007 14:36:17 +0100
Message-ID: <20071025133617.31556.6211.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53151 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753501AbXJYNgU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 09:36:20 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id l9PDaJU9024122
	for <netdev@vger.kernel.org>; Thu, 25 Oct 2007 09:36:19 -0400
Received: from pobox.devel.redhat.com (pobox.devel.redhat.com [10.11.255.8])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l9PDaJed015676
	for <netdev@vger.kernel.org>; Thu, 25 Oct 2007 09:36:19 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark snmp4_icmp_list[] as being unused to avoid the warning it would otherwise
incur.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/ipv4/proc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index fd16cb8..1c0854d 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -121,7 +121,8 @@ static const struct snmp_mib snmp4_ipextstats_list[] = {
 	SNMP_MIB_SENTINEL
 };
 
-static const struct snmp_mib snmp4_icmp_list[] = {
+static __attribute__((unused))
+const struct snmp_mib snmp4_icmp_list[] = {
 	SNMP_MIB_ITEM("InMsgs", ICMP_MIB_INMSGS),
 	SNMP_MIB_ITEM("InErrors", ICMP_MIB_INERRORS),
 	SNMP_MIB_ITEM("OutMsgs", ICMP_MIB_OUTMSGS),

