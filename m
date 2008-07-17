From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 13/16] proc: show per-net ip_devconf.forwarding in /proc/net/snmp
Date: Thu, 17 Jul 2008 17:38:26 +0400
Message-ID: <487F4B52.6040002@openvz.org>
References: <487F46CD.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:38211 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754972AbYGQNib (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 09:38:31 -0400
In-Reply-To: <487F46CD.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This one has become per-net long ago, but the appropriate file
is per-net only now.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/ipv4/proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 367b81f..120e1f7 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -342,7 +342,7 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 		seq_printf(seq, " %s", snmp4_ipstats_list[i].name);
 
 	seq_printf(seq, "\nIp: %d %d",
-		   IPV4_DEVCONF_ALL(&init_net, FORWARDING) ? 1 : 2,
+		   IPV4_DEVCONF_ALL(net, FORWARDING) ? 1 : 2,
 		   sysctl_ip_default_ttl);
 
 	for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
-- 
1.5.5.1

