From: Ben Greear <greearb@candelatech.com>
Subject: [net-next] ipv6:  Export in6addr_any for use by modules.
Date: Tue, 31 Aug 2010 10:08:15 -0700
Message-ID: <1283274495-12416-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:42906 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754364Ab0HaRIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 13:08:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some upcoming cifs code, could make use of this, at least.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 ab70a3f... 735989a... M	net/ipv6/addrconf.c
 net/ipv6/addrconf.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ab70a3f..735989a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -230,6 +230,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 
 /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
 const struct in6_addr in6addr_any = IN6ADDR_ANY_INIT;
+EXPORT_SYMBOL(in6addr_any);
 const struct in6_addr in6addr_loopback = IN6ADDR_LOOPBACK_INIT;
 const struct in6_addr in6addr_linklocal_allnodes = IN6ADDR_LINKLOCAL_ALLNODES_INIT;
 const struct in6_addr in6addr_linklocal_allrouters = IN6ADDR_LINKLOCAL_ALLROUTERS_INIT;
-- 
1.6.2.5

