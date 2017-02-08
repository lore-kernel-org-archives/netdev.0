From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2 net-next] man: ip-link.8: Document bridge_slave fdb_flush option
Date: Wed,  8 Feb 2017 16:02:20 +0800
Message-ID: <1486540940-23287-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:32831 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752061AbdBHIES (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 03:04:18 -0500
Received: by mail-pf0-f194.google.com with SMTP id e4so11128298pfg.0
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 00:02:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 man/man8/ip-link.8.in | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 469bb43..116034d 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -1429,6 +1429,8 @@ the following additional arguments are supported:
 
 .B "ip link set type bridge_slave"
 [
+.B fdb_flush
+] [
 .BI state " STATE"
 ] [
 .BI priority " PRIO"
@@ -1459,6 +1461,9 @@ the following additional arguments are supported:
 
 .in +8
 .sp
+.B fdb_flush
+- flush bridge slave's fdb dynamic entries
+
 .BI state " STATE"
 - Set port state.
 .I STATE
-- 
2.5.5
