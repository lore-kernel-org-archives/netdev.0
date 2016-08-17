From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ip: report IFLA_GSO_MAX_SIZE and IFLA_GSO_MAX_SEGS
Date: Wed, 17 Aug 2016 14:39:21 -0700
Message-ID: <1471469961.29842.42.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35073 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794AbcHQVjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 17:39:23 -0400
Received: by mail-pa0-f65.google.com with SMTP id cf3so44552pad.2
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 14:39:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

kernel support for these attributes was added in linux-4.6

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 ip/ipaddress.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index ab4b1b1..76bd7b3 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -901,6 +901,14 @@ int print_linkinfo(const struct sockaddr_nl *who,
 			fprintf(fp, "numrxqueues %u ",
 				rta_getattr_u32(tb[IFLA_NUM_RX_QUEUES]));
 
+		if (tb[IFLA_GSO_MAX_SIZE])
+			fprintf(fp, "gso_max_size %u ",
+				rta_getattr_u32(tb[IFLA_GSO_MAX_SIZE]));
+
+		if (tb[IFLA_GSO_MAX_SEGS])
+			fprintf(fp, "gso_max_segs %u ",
+				rta_getattr_u32(tb[IFLA_GSO_MAX_SEGS]));
+
 		if (tb[IFLA_PHYS_PORT_NAME])
 			fprintf(fp, "portname %s ",
 				rta_getattr_str(tb[IFLA_PHYS_PORT_NAME]));
