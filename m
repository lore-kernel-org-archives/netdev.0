From: Chris Caputo <ccaputo@alt.net>
Subject: [PATCH] net/core/sock.c - 2.4.18
Date: Mon, 20 May 2002 17:44:10 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <acc5a4$h7m$2@main.gmane.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, <linux-net@vger.kernel.org>
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch corrects a typo in net/core/sock.c.  The assignment to
sysctl_wmem_default was done twice in a row, rather than to
sysctl_wmem_default and sysctl_rmem_default.

This patch applies to 2.4.18.

Chris

--- net/core/sock.c.orig        Fri Dec 21 09:42:05 2001
+++ net/core/sock.c     Mon May 20 17:35:43 2002
@@ -626,7 +626,7 @@
                sysctl_wmem_max = 32767;
                sysctl_rmem_max = 32767;
                sysctl_wmem_default = 32767;
-               sysctl_wmem_default = 32767;
+               sysctl_rmem_default = 32767;
        } else if (num_physpages >= 131072) {
                sysctl_wmem_max = 131071;
                sysctl_rmem_max = 131071;
