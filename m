From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4381] New: When i try to start a pppoe conn.,
 crash at net/core/skbuff.c:91
Date: Mon, 21 Mar 2005 20:11:50 -0800
Message-ID: <20050321201150.39ba3467.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: o.cornu@gmail.com
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Repeatable pppoe crash :(


Begin forwarded message:

Date: Mon, 21 Mar 2005 19:54:24 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4381] New: When i try to start a pppoe conn., crash at net/core/skbuff.c:91


http://bugme.osdl.org/show_bug.cgi?id=4381

           Summary: When i try to start a pppoe conn., crash at
                    net/core/skbuff.c:91
    Kernel Version: 2.6.11 (gentoo-dev-sources)
            Status: NEW
          Severity: blocking
             Owner: shemminger@osdl.org
         Submitter: o.cornu@gmail.com


Distribution: Gentoo
Hardware Environment: Intel P4 / Asus P4C800E
Software Environment:
Problem Description: When i try to start a pppoe conn., crash at
net/core/skbuff.c:91
Might be related to Bug 4279, but with ppp_generic (not tun).

Mar 21 21:27:59 Pai-mei adsl-connect: ADSL connection lost; attempting
re-connection.
Mar 21 21:28:04 Pai-mei pppd[6735]: pppd 2.4.2 started by root, uid 0
Mar 21 21:28:04 Pai-mei pppd[6735]: Using interface ppp0
Mar 21 21:28:04 Pai-mei pppd[6735]: Connect: ppp0 <--> /dev/pts/3
Mar 21 21:28:05 Pai-mei <6>skput:over: f89b2335:16 put:16
dev:<NULL>------------[ cut here ]------------
Mar 21 21:28:05 Pai-mei kernel BUG at net/core/skbuff.c:91!
Mar 21 21:28:05 Pai-mei invalid operand: 0000 [#5]
Mar 21 21:28:05 Pai-mei PREEMPT SMP
Mar 21 21:28:05 Pai-mei Modules linked in: usbcore slip ppp_synctty parport_pc
plip parport ppp_deflate zlib_deflate dummy pppoe pppox ppp_async crc_ccitt
bsd_comp ppp_generic slhc nvidia_agp agpgart sr_mod
Mar 21 21:28:05 Pai-mei CPU:    0
Mar 21 21:28:05 Pai-mei EIP:    0060:[<c031ab1b>]    Not tainted VLI
Mar 21 21:28:05 Pai-mei EFLAGS: 00210282   (2.6.11-gentoo-r4)
Mar 21 21:28:05 Pai-mei EIP is at skb_over_panic+0x3b/0x50
Mar 21 21:28:05 Pai-mei eax: 0000002c   ebx: f6a43e80   ecx: 000008fc   edx:
00000001
Mar 21 21:28:05 Pai-mei esi: f7f59680   edi: f6f36a80   ebp: 00000010   esp:
f6a07f3c
Mar 21 21:28:05 Pai-mei ds: 007b   es: 007b   ss: 0068
Mar 21 21:28:05 Pai-mei Process pppd (pid: 6735, threadinfo=f6a06000 task=f6ff8a80)
Mar 21 21:28:05 Pai-mei Stack: c03ee4a0 f89b2335 00000010 00000010 c03d008c
f89b2341 f6a43e80 00000010
Mar 21 21:28:05 Pai-mei f89b2335 fffffff2 00000010 00000000 f6fd0e80 08087f22
c0160909 f6fd0e80
Mar 21 21:28:05 Pai-mei 08087f22 00000010 f6a07fac f6fd0e80 fffffff7 00000007
f6a06000 c0160a91
Mar 21 21:28:05 Pai-mei Call Trace:
Mar 21 21:28:05 Pai-mei [<f89b2335>] ppp_write+0x115/0x140 [ppp_generic]
Mar 21 21:28:05 Pai-mei [<f89b2341>] ppp_write+0x121/0x140 [ppp_generic]
Mar 21 21:28:05 Pai-mei [<f89b2335>] ppp_write+0x115/0x140 [ppp_generic]
Mar 21 21:28:05 Pai-mei [<c0160909>] vfs_write+0xe9/0x1a0
Mar 21 21:28:05 Pai-mei [<c0160a91>] sys_write+0x51/0x80
Mar 21 21:28:05 Pai-mei [<c01032af>] syscall_call+0x7/0xb
Mar 21 21:28:05 Pai-mei Code: c0 0f 44 c2 89 44 24 10 8b 44 24 1c 89 44 24 0c 8b
41 60 c7 04 24 a0 e4 3e c0 89 44 24 08 8b 44 24 20 89 44 24 04 e8 55 34 e0 ff
<0f> 0b 5b 00 0b b9 3e c0 83 c4 14 c3 89 f6 8d bc 27 00 00 00 00
Mar 21 21:28:05 Pai-mei adsl-connect: ADSL connection lost; attempting
re-connection.

Steps to reproduce:

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
