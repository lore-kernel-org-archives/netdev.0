From: Jiri Slaby <jirislaby@gmail.com>
Subject: IPv4: sysctl table check failed [was: mmotm 2010-10-07-14-08 uploaded]
Date: Fri, 08 Oct 2010 00:06:49 +0200
Message-ID: <4CAE4479.6010606@gmail.com>
References: <201010072140.o97Le69i025659@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org,
	ML netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54387 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521Ab0JGWJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 18:09:37 -0400
In-Reply-To: <201010072140.o97Le69i025659@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/2010 11:08 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2010-10-07-14-08 has been uploaded to

Hi, I got bunch of "sysctl table check failed" below. All seem to be
related to ipv4:

sysctl table check failed: /net/ipv4/tcp_mem  No min
Pid: 1, comm: swapper Not tainted 2.6.36-rc7-mm1_64+ #1285
Call Trace:
 [<ffffffff8108d444>] set_fail+0xa4/0xf0
 [<ffffffff8108d736>] sysctl_check_table+0x2a6/0x310
 [<ffffffff8108d4eb>] sysctl_check_table+0x5b/0x310
 [<ffffffff8108d4eb>] sysctl_check_table+0x5b/0x310
 [<ffffffff81072204>] __register_sysctl_paths+0xf4/0x320
 [<ffffffff815c1232>] ? printk+0x3c/0x42
 [<ffffffff8115d3bc>] ? sysfs_add_file+0xc/0x10
 [<ffffffff818b18bd>] ? sysctl_ipv4_init+0x0/0x87
 [<ffffffff81072456>] register_sysctl_paths+0x26/0x30
 [<ffffffff818b18fd>] sysctl_ipv4_init+0x40/0x87
 [<ffffffff810002df>] do_one_initcall+0x3f/0x170
 [<ffffffff81884d44>] kernel_init+0x158/0x1e2
 [<ffffffff8102fb54>] kernel_thread_helper+0x4/0x10
 [<ffffffff81884bec>] ? kernel_init+0x0/0x1e2
 [<ffffffff8102fb50>] ? kernel_thread_helper+0x0/0x10
sysctl table check failed: /net/ipv4/tcp_mem  No max
Pid: 1, comm: swapper Not tainted 2.6.36-rc7-mm1_64+ #1285
Call Trace:
 [<ffffffff8108d444>] set_fail+0xa4/0xf0
 [<ffffffff8108d4da>] sysctl_check_table+0x4a/0x310
 [<ffffffff8108d4eb>] sysctl_check_table+0x5b/0x310
 [<ffffffff8108d4eb>] sysctl_check_table+0x5b/0x310
 [<ffffffff81072204>] __register_sysctl_paths+0xf4/0x320
 [<ffffffff815c1232>] ? printk+0x3c/0x42
 [<ffffffff8115d3bc>] ? sysfs_add_file+0xc/0x10
 [<ffffffff818b18bd>] ? sysctl_ipv4_init+0x0/0x87
 [<ffffffff81072456>] register_sysctl_paths+0x26/0x30
 [<ffffffff818b18fd>] sysctl_ipv4_init+0x40/0x87
 [<ffffffff810002df>] do_one_initcall+0x3f/0x170
 [<ffffffff81884d44>] kernel_init+0x158/0x1e2
 [<ffffffff8102fb54>] kernel_thread_helper+0x4/0x10
 [<ffffffff81884bec>] ? kernel_init+0x0/0x1e2
 [<ffffffff8102fb50>] ? kernel_thread_helper+0x0/0x10
sysctl table check failed: /net/ipv4/udp_mem  No min
Pid: 1, comm: swapper Not tainted 2.6.36-rc7-mm1_64+ #1285
Call Trace:
 [<ffffffff8108d444>] set_fail+0xa4/0xf0
 [<ffffffff8108d736>] sysctl_check_table+0x2a6/0x310
 [<ffffffff8108d4eb>] sysctl_check_table+0x5b/0x310
 [<ffffffff8108d4eb>] sysctl_check_table+0x5b/0x310
 [<ffffffff81072204>] __register_sysctl_paths+0xf4/0x320
 [<ffffffff815c1232>] ? printk+0x3c/0x42
 [<ffffffff8115d3bc>] ? sysfs_add_file+0xc/0x10
 [<ffffffff818b18bd>] ? sysctl_ipv4_init+0x0/0x87
 [<ffffffff81072456>] register_sysctl_paths+0x26/0x30
 [<ffffffff818b18fd>] sysctl_ipv4_init+0x40/0x87
 [<ffffffff810002df>] do_one_initcall+0x3f/0x170
 [<ffffffff81884d44>] kernel_init+0x158/0x1e2
 [<ffffffff8102fb54>] kernel_thread_helper+0x4/0x10
 [<ffffffff81884bec>] ? kernel_init+0x0/0x1e2
 [<ffffffff8102fb50>] ? kernel_thread_helper+0x0/0x10
sysctl table check failed: /net/ipv4/udp_mem  No max
Pid: 1, comm: swapper Not tainted 2.6.36-rc7-mm1_64+ #1285
Call Trace:
 [<ffffffff8108d444>] set_fail+0xa4/0xf0
 [<ffffffff8108d4da>] sysctl_check_table+0x4a/0x310
 [<ffffffff8108d4eb>] sysctl_check_table+0x5b/0x310
 [<ffffffff8108d4eb>] sysctl_check_table+0x5b/0x310
 [<ffffffff81072204>] __register_sysctl_paths+0xf4/0x320
 [<ffffffff815c1232>] ? printk+0x3c/0x42
 [<ffffffff8115d3bc>] ? sysfs_add_file+0xc/0x10
 [<ffffffff818b18bd>] ? sysctl_ipv4_init+0x0/0x87
 [<ffffffff81072456>] register_sysctl_paths+0x26/0x30
 [<ffffffff818b18fd>] sysctl_ipv4_init+0x40/0x87
 [<ffffffff810002df>] do_one_initcall+0x3f/0x170
 [<ffffffff81884d44>] kernel_init+0x158/0x1e2
 [<ffffffff8102fb54>] kernel_thread_helper+0x4/0x10
 [<ffffffff81884bec>] ? kernel_init+0x0/0x1e2
 [<ffffffff8102fb50>] ? kernel_thread_helper+0x0/0x10

regards,
-- 
js
