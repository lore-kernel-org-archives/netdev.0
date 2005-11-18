From: Yan Zheng <yanzheng@21cn.com>
Subject: [DEBUG INFO]IPv6: sleeping function called from invalid context.
Date: Fri, 18 Nov 2005 08:44:27 +0800
Message-ID: <437D23EB.4020204@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751091AbVKRAmA@vger.kernel.org>
To: netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I get follow message when switch to single user mode and the kernel version is 2.6.15-rc1-git5.

Regards

Nov 18 08:26:23 localhost kernel: Debug: sleeping function called from invalid context at mm/slab.c:2472
Nov 18 08:26:23 localhost kernel: in_atomic():1, irqs_disabled():0
Nov 18 08:26:23 localhost kernel:  [<c0149d5a>] kmem_cache_alloc+0x5a/0x70
Nov 18 08:26:23 localhost kernel:  [<e0f47336>] inet6_dump_fib+0xb6/0x110 [ipv6]
Nov 18 08:26:23 localhost kernel:  [<c02e129c>] netlink_dump+0x4c/0x1e0
Nov 18 08:26:23 localhost kernel:  [<c02e150a>] netlink_dump_start+0xda/0x170
Nov 18 08:26:23 localhost kernel:  [<c02d2d05>] rtnetlink_rcv_msg+0x1d5/0x250
Nov 18 08:26:23 localhost kernel:  [<e0f47280>] inet6_dump_fib+0x0/0x110 [ipv6]
Nov 18 08:26:23 localhost kernel:  [<c02d2b30>] rtnetlink_rcv_msg+0x0/0x250
Nov 18 08:26:23 localhost kernel:  [<c02e17ed>] netlink_rcv_skb+0x4d/0x90
Nov 18 08:26:23 localhost kernel:  [<c02d2b30>] rtnetlink_rcv_msg+0x0/0x250
Nov 18 08:26:23 localhost kernel:  [<c02e1860>] netlink_run_queue+0x30/0xc0
Nov 18 08:26:23 localhost kernel:  [<c02d2b03>] rtnetlink_rcv+0x23/0x50
Nov 18 08:26:23 localhost kernel:  [<c02e1092>] netlink_data_ready+0x12/0x60
Nov 18 08:26:23 localhost kernel:  [<c0335414>] _spin_unlock_irqrestore+0x14/0x30
Nov 18 08:26:23 localhost kernel:  [<c02e0284>] netlink_sendskb+0x24/0x50
Nov 18 08:26:23 localhost kernel:  [<c02e0d3c>] netlink_sendmsg+0x29c/0x350
Nov 18 08:26:23 localhost kernel:  [<c02be551>] sock_sendmsg+0x111/0x150
Nov 18 08:26:23 localhost kernel:  [<c01c56f0>] avc_lookup+0xc0/0x120
Nov 18 08:26:23 localhost kernel:  [<c0131f10>] autoremove_wake_function+0x0/0x50
Nov 18 08:26:23 localhost kernel:  [<c02bdfff>] move_addr_to_user+0x5f/0x70
Nov 18 08:26:23 localhost kernel:  [<c02c0628>] sys_recvmsg+0x1b8/0x230
Nov 18 08:26:23 localhost kernel:  [<c013ef94>] audit_sockaddr+0x54/0xc0
Nov 18 08:26:23 localhost kernel:  [<c02bfded>] sys_sendto+0x10d/0x150
Nov 18 08:26:23 localhost kernel:  [<c0141b6d>] filemap_nopage+0x30d/0x3e0
Nov 18 08:26:23 localhost kernel:  [<c0145424>] __alloc_pages+0x64/0x310
Nov 18 08:26:23 localhost kernel:  [<c013db8e>] audit_filter_syscall+0x4e/0x130
Nov 18 08:26:23 localhost kernel:  [<c013db8e>] audit_filter_syscall+0x4e/0x130
Nov 18 08:26:23 localhost kernel:  [<c02c0865>] sys_socketcall+0x1c5/0x2a0
Nov 18 08:26:23 localhost kernel:  [<c0103261>] syscall_call+0x7/0xb
Nov 18 08:26:23 localhost kernel: Removing netfilter NETLINK layer.
