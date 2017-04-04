From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] man: ip-link: Specify min/max values for bridge slave priority and cost
Date: Tue,  4 Apr 2017 17:08:43 +0200
Message-ID: <20170404150843.20241-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:33337 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754467AbdDDPIz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 11:08:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The values are parsed as u16/u32, but kernel limits allowed values.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-link.8.in | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 3f5d57c28885f..12ec330a9c38e 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -1485,10 +1485,10 @@ is a number representing the following states:
 .BR 4 " (blocking)."
 
 .BI priority " PRIO"
-- set port priority (a 16bit unsigned value).
+- set port priority (allowed values are between 0 and 63, inclusively).
 
 .BI cost " COST"
-- set port cost (a 32bit unsigned value).
+- set port cost (allowed values are between 1 and 65535, inclusively).
 
 .BR guard " { " on " | " off " }"
 - block incoming BPDU packets on this port.
-- 
2.11.0
