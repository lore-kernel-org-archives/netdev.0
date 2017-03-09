From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] man: ss.8: Add missing protocols to description of -A
Date: Thu,  9 Mar 2017 17:07:33 +0100
Message-ID: <20170309160733.9171-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58803 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753861AbdCIQI2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 11:08:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The list was missing dccp and sctp protocols.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ss.8 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ss.8 b/man/man8/ss.8
index 4ef11523b4268..81de69de8042e 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -132,7 +132,7 @@ Currently the following families are supported: unix, inet, inet6, link, netlink
 .B \-A QUERY, \-\-query=QUERY, \-\-socket=QUERY
 List of socket tables to dump, separated by commas. The following identifiers
 are understood: all, inet, tcp, udp, raw, unix, packet, netlink, unix_dgram,
-unix_stream, unix_seqpacket, packet_raw, packet_dgram.
+unix_stream, unix_seqpacket, packet_raw, packet_dgram, dccp, sctp.
 .TP
 .B \-D FILE, \-\-diag=FILE
 Do not display anything, just dump raw information about TCP sockets to FILE after applying filters. If FILE is - stdout is used.
-- 
2.11.0
