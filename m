From: Stephen Hemminger <shemminger@osdl.org>
Subject: oops when bringing up loopback device
Date: Mon, 28 Mar 2005 16:02:48 -0800
Message-ID: <20050328160248.595615a1@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am seeing this on one of my boxes with current net-2.6 tree.

Unable to handle kernel NULL pointer dereference at virtual address 00000000
 printing eip:
00000000
*pde = 00000000
Oops: 0000 [#1]
SMP
Modules linked in: evdev e100 skge mii
CPU:    1
EIP:    0060:[<00000000>]    Not tainted VLI
EFLAGS: 00010286   (2.6.12-rc1-tcp)
EIP is at 0x0
eax: c0413b6c   ebx: 00000001   ecx: 0000000f   edx: f6aa9000
esi: 000007d0   edi: fffc727d   ebp: f6aa9d14   esp: f6aa9d00
ds: 007b   es: 007b   ss: 0068
Process ip (pid: 1597, threadinfo=f6aa9000 task=f64d3020)
Stack: c02fb6ce 00000001 f60022d0 f5fdd740 f6fc1300 f6aa9d70 c0331765 f6aa9d5c
       c0000000 fffffff0 00000000 000000d0 f6aa9d44 00000246 0100007f 00aa9d88
       00000002 00000020 f7f7da80 00000000 f6fc1300 f6aa9dd8 f7f7d780 ffffff97
Call Trace:
 [<c0103ec6>] show_stack+0xa6/0xb0
 [<c0104042>] show_registers+0x152/0x1c0
 [<c010424d>] die+0xed/0x170
 [<c011593d>] do_page_fault+0x4fd/0x685
 [<c0103b33>] error_code+0x2b/0x30
 [<c0331765>] fn_hash_insert+0x205/0x420
 [<c032e9e6>] fib_magic+0x106/0x120
 [<c032ea66>] fib_add_ifaddr+0x66/0x160
 [<c032ed7c>] fib_inetaddr_event+0x1c/0x60
 [<c0129fa8>] notifier_call_chain+0x28/0x50
 [<c0326eb9>] inet_insert_ifa+0xd9/0x170
 [<c03280ec>] inetdev_event+0x1dc/0x1f0
 [<c0129fa8>] notifier_call_chain+0x28/0x50
 [<c02e7ecf>] dev_open+0x5f/0x90
 [<c02e94d2>] dev_change_flags+0x52/0x120
 [<c03279d0>] devinet_ioctl+0x520/0x5d0
 [<c0329968>] inet_ioctl+0x98/0xe0
 [<c02df470>] sock_ioctl+0x1a0/0x250
 [<c016dc36>] do_ioctl+0x76/0x90
 [<c016ddcd>] vfs_ioctl+0x5d/0x1e0
 [<c016df89>] sys_ioctl+0x39/0x60
 [<c0103033>] sysenter_past_esp+0x54/0x75
