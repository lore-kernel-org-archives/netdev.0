From: Matthias Andree <matthias.andree@gmx.de>
Subject: 2.6: net/core.c should export sysctl_optmem_max for modular IPV6
Date: Thu, 26 Feb 2004 02:59:07 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040226015907.GA10986@merlin.emma.line.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Linux-Kernel mailing list <linux-kernel@vger.kernel.org>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Hi,

IPv6 built as a module fails (in 2.6 BitKeeper tree) because it cannot
link to sysctl_optmem_max, trivial patch:

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/02/26 02:00:09+01:00 matthias.andree@gmx.de 
#   EXPORT_SYMBOL(sysctl_optmem_max) to make IPv6 happy.
# 
# net/core/sock.c
#   2004/02/26 01:58:51+01:00 matthias.andree@gmx.de +1 -0
#   EXPORT_SYMBOL(sysctl_optmem_max) to make IPv6 happy.
# 
diff -Nru a/net/core/sock.c b/net/core/sock.c
--- a/net/core/sock.c	Thu Feb 26 02:49:06 2004
+++ b/net/core/sock.c	Thu Feb 26 02:49:06 2004
@@ -1186,6 +1186,7 @@
 EXPORT_SYMBOL(sock_wfree);
 EXPORT_SYMBOL(sock_wmalloc);
 #ifdef CONFIG_SYSCTL
+EXPORT_SYMBOL(sysctl_optmem_max);
 EXPORT_SYMBOL(sysctl_rmem_max);
 EXPORT_SYMBOL(sysctl_wmem_max);
 #endif

-- 
Matthias Andree

Encrypt your mail: my GnuPG key ID is 0x052E7D95
