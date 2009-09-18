From: akpm@linux-foundation.org
Subject: [patch 1/1] net: fix CONFIG_NET=n build on sparc64
Date: Fri, 18 Sep 2009 12:52:13 -0700
Message-ID: <200909181952.n8IJqEdD024614@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48048 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752802AbZIRTxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2009 15:53:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

sparc64 allnoconfig:

arch/sparc/kernel/built-in.o(.text+0x134e0): In function `sys32_recvfrom':
: undefined reference to `compat_sys_recvfrom'
arch/sparc/kernel/built-in.o(.text+0x134e4): In function `sys32_recvfrom':
: undefined reference to `compat_sys_recvfrom'

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 kernel/sys_ni.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN kernel/sys_ni.c~net-fix-config_net=n-build-on-sparc64 kernel/sys_ni.c
--- a/kernel/sys_ni.c~net-fix-config_net=n-build-on-sparc64
+++ a/kernel/sys_ni.c
@@ -49,6 +49,7 @@ cond_syscall(sys_sendmsg);
 cond_syscall(compat_sys_sendmsg);
 cond_syscall(sys_recvmsg);
 cond_syscall(compat_sys_recvmsg);
+cond_syscall(compat_sys_recvfrom);
 cond_syscall(sys_socketcall);
 cond_syscall(sys_futex);
 cond_syscall(compat_sys_futex);
_
