From: Stephen Hemminger <shemminger@osdl.org>
Subject: crash in fib_hash_move
Date: Fri, 17 Sep 2004 11:42:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040917114249.7449b9ff@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Current 2.6 tree is crashing on bootup in fib code.
Looks like recent FIB changes problem.

--------------

Unable to handle kernel paging request at virtual address 00003232
 printing eip:
*pde = 00000000
Oops: 0002 [#1]
PREEMPT SMP
Modules linked in: ext3 jbd DAC960 aic7xxx sd_mod scsi_mod
CPU:    5
EIP:    0060:[<c0278f14>]    Not tainted VLI
EFLAGS: 00010206   (2.6.9-rc2)
EIP is at fib_hash_move+0x90/0x146
eax: 0000322e   ebx: c316b480   ecx: 00000004   edx: f6cc5630
esi: c316b380   edi: f6cc5620   ebp: 00000000   esp: f6e0cd94
ds: 007b   es: 007b   ss: 0068
Process ifconfig (pid: 1507, threadinfo=f6e0c000 task=f6db0550)
Stack: 00000000 00000004 f6cc82e0 00000008 f6cc82e0 00000020 f6cc5620 c0279062
       00000020 00000001 00000000 ffffff97 f6e0ce40 f6e0ce90 ffffffea f6e0ce40
       c314a980 f6cc6ec0 c027a8cd f6e0ce14 f6e0ce80 00000000 03ccf180 ffff14ac
Call Trace:
 [<c0279062>] fib_create_info+0x98/0x529
 [<c027a8cd>] fn_hash_insert+0xab/0x4d1
 [<c0278242>] fib_magic+0x104/0x129
 [<c02782f1>] fib_add_ifaddr+0x8a/0x12b
 [<c02785a7>] fib_inetaddr_event+0x47/0x53
 [<c0124da2>] notifier_call_chain+0x17/0x2b
 [<c02710a2>] inet_insert_ifa+0x8e/0x12b
 [<c0271950>] devinet_ioctl+0x317/0x60e
 [<c02738cb>] inet_ioctl+0x5b/0x8f
 [<c0230051>] sock_ioctl+0xdb/0x25b
 [<c014c55f>] fget+0x49/0x5e
 [<c015ba1c>] sys_ioctl+0xf5/0x24d
 [<c0105871>] sysenter_past_esp+0x52/0x71
