From: Stephen Hemminger <shemminger@osdl.org>
Subject: Crash with e100 and ethtool on 2.6.0-test4 latest
Date: Fri, 5 Sep 2003 11:24:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030905112446.00ba4e32.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Scott Feldman <scott.feldman@intel.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


#  ethtool -K eth0 rx off

Unable to handle kernel paging request at virtual address f8875000
 printing eip:
f8874fff
*pde = 0389e067
*pte = 00000000
Oops: 0000 [#1]
CPU:    7
EIP:    0060:[<f8874fff>]    Not tainted
EFLAGS: 00010282
EIP is at 0xf8874fff
eax: f68243a0   ebx: f68243a0   ecx: f6824184   edx: 00000000
esi: 00000000   edi: 00000000   ebp: f5fefda8   esp: f5fefd90
ds: 007b   es: 007b   ss: 0068
Process ethtool (pid: 1815, threadinfo=f5fee000 task=f6820d00)
Stack: f885f6b9 f68243a0 f885f2ea f68243a0 f6824184 f68242a8 f5fefed4 f8861f9e 
       f68243a0 bffff020 00000008 f68243a0 c0328800 c0328b80 00000015 00000000 
       c0142acf c35dc5a8 00000000 f5fefe08 c014e6f3 00000286 00000246 00000000 
Call Trace:
 [<f885f6b9>] e100_hw_init+0x14/0x106 [e100]
 [<f885f2ea>] e100_close+0x67/0x7a [e100]
 [<f8861f9e>] e100_do_ethtool_ioctl+0x533/0x88a [e100]
 [<c0142acf>] buffered_rmqueue+0xc0/0x193
 [<c014e6f3>] zap_pte_range+0x71/0x208
 [<c0142c2c>] __alloc_pages+0x8a/0x324
 [<c013e92e>] find_get_page+0x37/0x94
 [<c013facc>] filemap_nopage+0x239/0x315
 [<c01556b1>] pte_chain_alloc+0x64/0x67
 [<c0150558>] do_no_page+0x1f5/0x410
 [<c014e02e>] pte_alloc_map+0xd9/0x12e
 [<c028315c>] dev_ethtool+0x95/0x2f9
 [<c02880e6>] rtnl_lock+0x22/0x38
 [<c02809a1>] dev_ioctl+0x1a0/0x34f
 [<c02c32f4>] inet_ioctl+0x102/0x112
 [<c0277253>] sock_ioctl+0x154/0x34a
 [<c0278afc>] sys_socketcall+0xb7/0x29a
 [<c01742f8>] sys_ioctl+0x147/0x305
 [<c0152eb7>] sys_munmap+0x58/0x77
 [<c010b301>] sysenter_past_esp+0x52/0x71

Code: 00  Bad EIP value.
 Segmentation fault
