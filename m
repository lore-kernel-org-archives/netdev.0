From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6/udp:  report SndbufErrors and RcvbufErrors
Date: Wed, 27 Oct 2010 11:35:16 +0200
Message-ID: <1288172116.2709.81.camel@edumazet-laptop>
References: <8545971aec0612a0bca2801107d9493b.squirrel@imap.coplanar.net>
	 <1288124033.2652.24.camel@edumazet-laptop>
	 <a2ae895d871551a9b3ded9ce3874fe28.squirrel@imap.coplanar.net>
	 <1288124842.2652.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41555 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651Ab0J0JfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 05:35:21 -0400
Received: by wyf28 with SMTP id 28so467393wyf.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 02:35:20 -0700 (PDT)
In-Reply-To: <1288124842.2652.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit a18135eb9389 (Add UDP_MIB_{SND,RCV}BUFERRORS handling.)
forgot to make the necessary changes in net/ipv6/proc.c to report
additional counters in /proc/net/snmp6

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/proc.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index d082eae..24b3558 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -126,6 +126,8 @@ static const struct snmp_mib snmp6_udp6_list[] = {
 	SNMP_MIB_ITEM("Udp6NoPorts", UDP_MIB_NOPORTS),
 	SNMP_MIB_ITEM("Udp6InErrors", UDP_MIB_INERRORS),
 	SNMP_MIB_ITEM("Udp6OutDatagrams", UDP_MIB_OUTDATAGRAMS),
+	SNMP_MIB_ITEM("Udp6RcvbufErrors", UDP_MIB_RCVBUFERRORS),
+	SNMP_MIB_ITEM("Udp6SndbufErrors", UDP_MIB_SNDBUFERRORS),
 	SNMP_MIB_SENTINEL
 };
 
@@ -134,6 +136,8 @@ static const struct snmp_mib snmp6_udplite6_list[] = {
 	SNMP_MIB_ITEM("UdpLite6NoPorts", UDP_MIB_NOPORTS),
 	SNMP_MIB_ITEM("UdpLite6InErrors", UDP_MIB_INERRORS),
 	SNMP_MIB_ITEM("UdpLite6OutDatagrams", UDP_MIB_OUTDATAGRAMS),
+	SNMP_MIB_ITEM("UdpLite6RcvbufErrors", UDP_MIB_RCVBUFERRORS),
+	SNMP_MIB_ITEM("UdpLite6SndbufErrors", UDP_MIB_SNDBUFERRORS),
 	SNMP_MIB_SENTINEL
 };
 


