From: Anders Gustafsson <andersg@0x63.nu>
Subject: OOPS in ip6_output2
Date: Thu, 17 Jul 2003 17:13:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030717151354.GA10640@h55p111.delphi.afb.lu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I don't follow netdev so maybe this is old stuff, but I got this oops when
trying to ssh to a ipv6-host.

The defaultroute seems garbled too: (or maybe that is what causes it)

andersg@laika:~$ ip -6 ro l default
default via 90a6:1840:c79a:1840:: dev eth1  proto kernel  metric 1024
expires 17643sec mtu 1500 advmss 1440

but I got the correct prefix from radvd.



Unable to handle kernel NULL pointer dereference at virtual address 00000000
 printing eip:
00000000
*pde = 00000000
Oops: 0000 [#1]
CPU:    0
EIP:    0060:[<00000000>]    Not tainted
EFLAGS: 00010282
EIP is at 0x0
eax: cc5fc004   ebx: ca581004   ecx: cc9d4004   edx: ca55e084
esi: ca581004   edi: 00000000   ebp: 00000000   esp: ca315ca8
ds: 007b   es: 007b   ss: 0068
Process ssh (pid: 1652, threadinfo=ca314000 task=ca3e1000)
Stack: c02ad9a2 ca581004 00000000 00000000 ca315d94 ca4d6004 00000000 00000000
       000005dc ca581004 00000000 00000028 c02adec1 ca581004 ca315d4c 00000010
       00000000 00000000 00000000 00000096 00000096 c119c8c8 00000000 cc0bf004
Call Trace:
 [<c02ad9a2>] ip6_output2+0x172/0x250
 [<c02adec1>] ip6_xmit+0x201/0x3a0
 [<c02d0818>] tcp_v6_xmit+0x118/0x250
 [<c0280c55>] tcp_transmit_skb+0x3e5/0x600
 [<c028361c>] tcp_connect+0x3bc/0x490
 [<c02cd63b>] tcp_v6_connect+0x3bb/0x7c0
 [<c0297ed4>] inet_stream_connect+0x114/0x260
 [<c0254095>] sys_connect+0x85/0xc0
 [<c0252a4a>] sock_map_fd+0xfa/0x130
 [<c0253c0d>] sys_socket+0x3d/0x60
 [<c0254c41>] sys_socketcall+0xd1/0x2a0
 [<c01092bb>] syscall_call+0x7/0xb



-- 
Anders Gustafsson - andersg@0x63.nu - http://0x63.nu/
