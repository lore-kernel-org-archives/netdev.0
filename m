From: Tom Herbert <therbert@google.com>
Subject: [PATCH iproute2 3/4] iproute: Description of new options for VXLAN in ip-link man pages
Date: Thu, 29 Jan 2015 08:52:00 -0800
Message-ID: <1422550321-30901-4-git-send-email-therbert@google.com>
References: <1422550321-30901-1-git-send-email-therbert@google.com>
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:61085 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754876AbbA2Qx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 11:53:27 -0500
Received: by mail-ie0-f181.google.com with SMTP id rp18so35768003iec.12
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 08:53:27 -0800 (PST)
In-Reply-To: <1422550321-30901-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add description for UDP checksums and remote checksum offload.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 man/man8/ip-link.8.in | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 1209b55..a0be895 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -276,6 +276,12 @@ the following additional arguments are supported:
 .BI ageing " SECONDS "
 .R " ] [ "
 .BI maxaddress " NUMBER "
+.R " ] [ "
+.I "[no]udpcsum "
+.R " ] [ "
+.I "[no]remcsumtx "
+.R " ] [ "
+.I "[no]remcsumrx "
 .R " ]"
 
 .in +8
@@ -348,6 +354,18 @@ are entered into the VXLAN device forwarding database.
 .BI maxaddress " NUMBER"
 - specifies the maximum number of FDB entries.
 
+.sp
+.I [no]udpcsum
+- specifies if UDP checksum is enabled in the outer header.
+
+.sp
+.I [no]remcsumtx
+- specifies if remote checksum option is tranmitted.
+
+.sp
+.I [no]remcsumrx
+- specifies if remote checksum option is allowed to be received.
+
 .in -8
 
 .TP
-- 
2.2.0.rc0.207.ga3a616c
