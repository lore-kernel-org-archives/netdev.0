From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2 net-next] iproute2: correct port in FOU/GRE example
Date: Wed,  1 Jun 2016 12:21:41 +0900
Message-ID: <1464751301-18709-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>,
	Tom Herbert <tom@herbertland.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35629 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756833AbcFADVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 23:21:52 -0400
Received: by mail-pf0-f172.google.com with SMTP id g64so5502050pfb.2
        for <netdev@vger.kernel.org>; Tue, 31 May 2016 20:21:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This resolves what appears to be a typo.

Cc: Tom Herbert <tom@herbertland.com>
Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 man/man8/ip-fou.8 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ip-fou.8 b/man/man8/ip-fou.8
index 0fa22ee61d63..0c8f0a4d6370 100644
--- a/man/man8/ip-fou.8
+++ b/man/man8/ip-fou.8
@@ -56,7 +56,7 @@ in the delete command.
 .PP
 .SS Configure a FOU receive port for GRE bound to 7777
 .nf
-# ip fou add port 8888 ipproto 47
+# ip fou add port 7777 ipproto 47
 .PP
 .SS Configure a FOU receive port for IPIP bound to 8888
 .nf
-- 
2.1.4
