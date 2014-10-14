From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man ip-link: Fixed missing 'up' option in 'ip link show' synopsis
Date: Tue, 14 Oct 2014 18:01:34 +0300
Message-ID: <1413298894-5157-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:39659 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932185AbaJNPKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 11:10:23 -0400
Received: by mail-lb0-f176.google.com with SMTP id p9so8231815lbv.21
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 08:10:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ip-link.8.in | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 383917a..464009d 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -144,7 +144,9 @@ ip-link \- network device configuration
 .B ip link show
 .RI "[ " DEVICE " | "
 .B group
-.IR GROUP " ]"
+.IR GROUP " |"
+.B up
+]
 
 .SH "DESCRIPTION"
 .SS ip link add - add virtual link
-- 
2.1.0
