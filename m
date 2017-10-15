From: Petr Vorel <petr.vorel@gmail.com>
Subject: [PATCH iproute2 1/1] tests: Revert back /bin/sh in shebang
Date: Sun, 15 Oct 2017 11:59:45 +0200
Message-ID: <20171015095945.30878-1-petr.vorel@gmail.com>
Cc: Petr Vorel <petr.vorel@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:56302 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750753AbdJOJ7x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 05:59:53 -0400
Received: by mail-wm0-f54.google.com with SMTP id u138so28803778wmu.4
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 02:59:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was added by mistake in commit ecd44e68
("tests: Remove bashisms (s/source/.)")

Signed-off-by: Petr Vorel <petr.vorel@gmail.com>
---
 testsuite/tests/ip/route/add_default_route.t | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/testsuite/tests/ip/route/add_default_route.t b/testsuite/tests/ip/route/add_default_route.t
index 0b566f1f..569ba1f8 100755
--- a/testsuite/tests/ip/route/add_default_route.t
+++ b/testsuite/tests/ip/route/add_default_route.t
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/bin/sh
 
 . lib/generic.sh
 
-- 
2.14.2
