From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: [PATCH iproute2] man: add examples to ip.8
Date: Sun, 12 Mar 2017 21:41:16 +0100
Message-ID: <20170312204116.11943-1-alexander@alemayhu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: stephen@networkplumber.org, dsa@cumulusnetworks.com,
        jidanni@jidanni.org, Alexander Alemayhu <alexander@alemayhu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:33773 "EHLO
        mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934692AbdCLUlV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 16:41:21 -0400
Received: by mail-lf0-f53.google.com with SMTP id a6so56894437lfa.0
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 13:41:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having some examples in the top level man page might make it a little bit easier
for new users to get started. Reused some words / sentences from the existing
man pages.

Suggested-by: 積丹尼 Dan Jacobson <jidanni@jidanni.org>
Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>
---
This is my first man page patch, hopefully I've done everything correctly.
If not please let me know, thanks.

 man/man8/ip.8 | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 8ecb1996da92..1c5a7419e4fc 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -319,6 +319,34 @@ or, if the objects of this class cannot be listed,
 Exit status is 0 if command was successful, and 1 if there is a syntax error.
 If an error was reported by the kernel exit status is 2.
 
+.SH "EXAMPLES"
+.PP
+ip addr
+.RS 4
+Shows addresses assigned to all network interfaces.
+.RE
+.PP
+ip neigh
+.RS 4
+Shows the current neighbour table in kernel.
+.RE
+.PP
+ip link set x up
+.RS 4
+Bring up interface x.
+.RE
+.PP
+ip link set x down
+.RE
+.RS 4
+Bring down interface x.
+.RE
+.PP
+ip route
+.RS 4
+Show table routes.
+.RE
+
 .SH HISTORY
 .B ip
 was written by Alexey N. Kuznetsov and added in Linux 2.2.
-- 
2.9.3
