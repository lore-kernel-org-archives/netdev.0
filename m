From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH iproute] tc: man: matchall: Fix example indentation
Date: Tue, 31 Jan 2017 11:47:47 +0200
Message-ID: <1485856067-11529-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: stephen@networkplumber.org, netdev@vger.kernel.org,
        eladr@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48524 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751071AbdAaJpS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 04:45:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The man page contains two examples, which have different indentation. Fix
the indentation of the two examples to match.

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
---
 man/man8/tc-matchall.8 | 1 +
 1 file changed, 1 insertion(+)

diff --git a/man/man8/tc-matchall.8 b/man/man8/tc-matchall.8
index f920922..5aa11da 100644
--- a/man/man8/tc-matchall.8
+++ b/man/man8/tc-matchall.8
@@ -53,6 +53,7 @@ where the second command attaches a matchall filters on it that mirrors the
 packets to device eth2.
 
 To create egress mirroring from port eth1 to port eth2:
+.RS
 .EX
 
 tc qdisc add dev eth1 handle 1: root prio
-- 
2.4.11
