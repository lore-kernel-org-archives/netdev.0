From: Iskren Chernev <iskren@imo.im>
Subject: [PATCH bug-fix] iproute: fix documentation for ip rule scan order
Date: Tue, 30 Aug 2016 17:32:52 -0700
Message-ID: <CAN04xNR8SH4D57mfY0nVDSNWvZfaaOLci2yB0-8nKg=Hv9SEbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:34597 "EHLO
        mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752100AbcHaAdN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 20:33:13 -0400
Received: by mail-yw0-f173.google.com with SMTP id z8so21774389ywa.1
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 17:33:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 416f45b62f33017d19a9b14e7b0179807c993cbe Mon Sep 17 00:00:00 2001
From: Iskren Chernev <iskren@imo.im>
Date: Tue, 30 Aug 2016 17:08:54 -0700
Subject: [PATCH bug-fix] iproute: fix documentation for ip rule scan order

---
 man/man8/ip-rule.8 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ip-rule.8 b/man/man8/ip-rule.8
index 1774ae3..3508d80 100644
--- a/man/man8/ip-rule.8
+++ b/man/man8/ip-rule.8
@@ -93,7 +93,7 @@ Each policy routing rule consists of a
 .B selector
 and an
 .B action predicate.
-The RPDB is scanned in order of decreasing priority. The selector
+The RPDB is scanned in order of increasing priority. The selector
 of each rule is applied to {source address, destination address, incoming
 interface, tos, fwmark} and, if the selector matches the packet,
 the action is performed. The action predicate may return with success.
