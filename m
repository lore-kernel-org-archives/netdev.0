From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH iproute2] man: Fix formatting of vrf parameter of ip-link show command
Date: Thu, 9 Mar 2017 12:56:14 +0000
Message-ID: <1489064174-29504-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Robert Shearman <rshearma@brocade.com>
To: <netdev@vger.kernel.org>, <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:58056 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932299AbdCINot (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 08:44:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing opening " [" for the vrf parameter.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 man/man8/ip-link.8.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 83ffb6357f7d..3f5d57c28885 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -164,7 +164,7 @@ ip-link \- network device configuration
 .B master
 .IR DEVICE " ] ["
 .B type
-.IR ETYPE " ]"
+.IR ETYPE " ] ["
 .B vrf
 .IR NAME " ]"
 
-- 
2.1.4
