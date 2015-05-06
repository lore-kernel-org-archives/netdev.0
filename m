From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 1/4] ip: document exit code
Date: Wed,  6 May 2015 09:58:00 -0700
Message-ID: <1430931483-28595-2-git-send-email-stephen@networkplumber.org>
References: <1430931483-28595-1-git-send-email-stephen@networkplumber.org>
Cc: Stephen Hemminger <shemming@brocade.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:36745 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753112AbbEFQ6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 12:58:02 -0400
Received: by pdea3 with SMTP id a3so15018269pde.3
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 09:58:02 -0700 (PDT)
In-Reply-To: <1430931483-28595-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemming@brocade.com>

The ip command has always had a consistent exit status
document it so that developers see it.
---
 man/man8/ip.8 | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 43ddac9..9574a50 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -275,6 +275,10 @@ Usually it is
 or, if the objects of this class cannot be listed,
 .BR "help" .
 
+.SH EXIT STATUS
+Exit statsis is 0 if command was sucessful, and 1 if there is a syntax error.
+If an error was reported by the kernel exit status is 2.
+
 .SH HISTORY
 .B ip
 was written by Alexey N. Kuznetsov and added in Linux 2.2.
-- 
2.1.4
