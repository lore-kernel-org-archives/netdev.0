From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man ip-link: Add short info about 'dynamic' flag
Date: Thu, 26 Feb 2015 03:12:08 +0200
Message-ID: <1424913128-14679-1-git-send-email-vadim4j@gmail.com>
Cc: netdev@vger.kernel.org, Vadim Kochan <vadim4j@gmail.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:36280 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752919AbbBZBX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 20:23:29 -0500
Received: by lbvp9 with SMTP id p9so7779042lbv.3
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 17:23:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ip-link.8.in | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 057125b..398348a 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -625,7 +625,9 @@ flag on the device.
 .BR "dynamic on " or " dynamic off"
 change the
 .B DYNAMIC
-flag on the device.
+flag on the device. Indicates that address can change when interface goes down (currently
+.B NOT
+used by the Linux).
 
 .TP
 .BI name " NAME"
-- 
2.2.2
