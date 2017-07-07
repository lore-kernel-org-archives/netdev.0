From: Matteo Croce <mcroce@redhat.com>
Subject: [PATCH iproute2] tc: fix typo in manpage
Date: Fri,  7 Jul 2017 15:08:33 +0200
Message-ID: <20170707130833.22395-1-mcroce@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Phil Sutter <phil@nwl.cc>, Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32856 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750878AbdGGNIi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Jul 2017 09:08:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a typo in the 'tc' manpage and reword some sentences.

Signed-off-by: Matteo Croce <mcroce@redhat.com>
---
 man/man8/tc-csum.8 | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/man8/tc-csum.8 b/man/man8/tc-csum.8
index 718301d..409ab71 100644
--- a/man/man8/tc-csum.8
+++ b/man/man8/tc-csum.8
@@ -29,9 +29,9 @@ csum - checksum update action
 The
 .B csum
 action triggers checksum recalculation of specified packet headers. It is
-commonly used after packet editing using the
+commonly used to fix incorrect checksums after the
 .B pedit
-action to fix for then incorrect checksums.
+action has modified the packet content.
 .SH OPTIONS
 .TP
 .I TARGET
-- 
2.9.4
