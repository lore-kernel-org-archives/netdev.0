From: Baruch Even <baruch@ev-en.org>
Subject: Re: ixgb problem
Date: Sun, 06 Mar 2005 20:55:41 +0000
Message-ID: <422B6E4D.7040402@ev-en.org>
References: <422B54AF.4060401@ev-en.org> <20050306191527.GA9610@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070500030203030802020608"
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20050306191527.GA9610@havoc.gtf.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070500030203030802020608
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Jeff Garzik wrote:
> On Sun, Mar 06, 2005 at 07:06:23PM +0000, Baruch Even wrote:
> 
>>I'm running a test of iperf with a window of 16MB, at first the 
>>performance shows about 3.2Gbps rate (which sucks by itself, but that's 
>>another issue), after some time, usually 30-40 seconds, but sometimes 
>>100 seconds, the performance drops to almost nothing, about 60Kbps.
> 
> If you could get sysrq-p and sysrq-t output, that would be useful.

Attached. sysrq-p seems to be empty though.
sysrq.log is from s1 - sender
sysrq2.log is from s2 - receiver

> Also, check and see what your CPU load is, at the time.

It goes from 60% system to 0% system when the problem appears. user is 
around 2-3% most of the time, it's just iperf generating packets.

Baruch

--------------070500030203030802020608
Content-Type: text/x-log;
 name="sysrq.log"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="sysrq.log"

=FF=FD=03=FF=FB=03=FF=FB=01
Debian GNU/Linux 3.1 source1ng ttyS0

source1ng login: SysRq : Show State


=00                                               sibling

=00  task             PC      pid father child younger older

=00init          S C04FE040  5016     1      0     2               (NOTLB=
)

=00dffa1e80 00000082 c14f2aa0 c04fe040 00000246 c0151c95 00000246 0000000=
0=20

=00       c04485a0 00000246 c04485a0 dffa1e94 c044a61c c044a374 00000000 =
f737bc80=20

=00       000f42ec c14f2c08 000b696a dffa1e94 0000000b 00000000 c03d9bde =
dffa1e94=20

=00Call Trace:

=00 [<c0151c95>] cache_grow+0x175/0x350

=00 [<c03d9bde>] schedule_timeout+0x8e/0xe0

=00 [<c012a490>] process_timeout+0x0/0x10

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00ksoftirqd/0   S C04FE040  6736     2      1             3       (L-TLB=
)

=00dffa3fb0 00000046 c14f2550 c04fe040 dff84114 dff84000 000b0034 c0124d7=
0=20

=00       dc538700 000f42e7 def0daa0 004dd1e0 dc538700 000f42e7 00000000 =
df6cfc00=20

=00       000f42e7 c14f26b8 dffa2000 dffa1f50 00000000 c0124d70 c0124df3 =
c14f2550=20

=00Call Trace:

=00 [<c0124d70>] ksoftirqd+0x0/0xa0

=00 [<c0124d70>] ksoftirqd+0x0/0xa0

=00 [<c0124df3>] ksoftirqd+0x83/0xa0

=00 [<c013c25a>] kthread+0xaa/0xb0

=00 [<c013c1b0>] kthread+0x0/0xb0

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00events/0      S C04FE040  6732     3      1             4     2 (L-TLB=
)

=00dffa7f38 00000046 c14f2000 c04fe040 c14da6e0 c14da6c8 00000001 0000000=
3=20

=00       dffa7f38 00000086 c14da6c8 00000246 00000001 00000000 00000000 =
f6eb7140=20

=00       000f42ec c14f2168 00000000 c14da680 c14da6a8 dffa7f94 c0135825 =
00000000=20

=00Call Trace:

=00 [<c0135825>] worker_thread+0x435/0x460

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c01353f0>] worker_thread+0x0/0x460

=00 [<c013c25a>] kthread+0xaa/0xb0

=00 [<c013c1b0>] kthread+0x0/0xb0

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00khelper       S C04FE040  7192     4      1             9     3 (L-TLB=
)

=00dffadf38 00000046 c14f8aa0 c04fe040 c14da5e0 c14da5c8 00000001 0000000=
3=20

=00       dffadf38 00000086 c14da5c8 00000246 00000001 deb07aa0 00000000 =
6d152880=20

=00       000f4206 c14f8c08 dea7dd64 c14da580 c14da5a8 dffadf94 c0135825 =
00000000=20

=00Call Trace:

=00 [<c0135825>] worker_thread+0x435/0x460

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c01353f0>] worker_thread+0x0/0x460

=00 [<c013c25a>] kthread+0xaa/0xb0

=00 [<c013c1b0>] kthread+0x0/0xb0

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00kthread       S C04FE040  7240     9      1    17     173     4 (L-TLB=
)

=00dffaff38 00000046 c14f8550 c04fe040 dff82de0 dff82dc8 00000001 0000000=
3=20

=00       dffaff38 00000086 dff82dc8 00000246 00000001 c1596aa0 00000000 =
45e62540=20

=00       000f41fa c14f86b8 dffa1ed4 dff82d80 dff82da8 dffaff94 c0135825 =
00000000=20

=00Call Trace:

=00 [<c0135825>] worker_thread+0x435/0x460

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c01353f0>] worker_thread+0x0/0x460

=00 [<c013c25a>] kthread+0xaa/0xb0

=00 [<c013c1b0>] kthread+0x0/0xb0

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00kacpid        S C04FE040  7828    17      9           106       (L-TLB=
)

=00dff09f38 00000046 c14f8000 c04fe040 00000000 dff08000 dff08000 c14f800=
0=20

=00       00010000 c0130e30 00010000 00000246 00000296 dff4aaa0 00000000 =
36b32780=20

=00       000f41fa c14f8168 dff08000 dff82280 dff822a8 dff09f94 c0135825 =
00000011=20

=00Call Trace:

=00 [<c0130e30>] do_sigaction+0x2e0/0x690

=00 [<c0135825>] worker_thread+0x435/0x460

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c01353f0>] worker_thread+0x0/0x460

=00 [<c013c25a>] kthread+0xaa/0xb0

=00 [<c013c1b0>] kthread+0x0/0xb0

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00kblockd/0     S C04FE040  7368   106      9           171    17 (L-TLB=
)

=00c1563f38 00000046 dff4aaa0 c04fe040 dff514e0 dff514c8 00000001 0000000=
3=20

=00       c1563f38 00000086 dff514c8 00000246 00000001 00000000 00000000 =
d3413280=20

=00       000f42e1 dff4ac08 dfc4b988 dff51480 dff514a8 c1563f94 c0135825 =
00000000=20

=00Call Trace:

=00 [<c0135825>] worker_thread+0x435/0x460

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c01353f0>] worker_thread+0x0/0x460

=00 [<c013c25a>] kthread+0xaa/0xb0

=00 [<c013c1b0>] kthread+0x0/0xb0

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00pdflush       S C04FE040  7876   171      9           172   106 (L-TLB=
)

=00c15b7f68 00000046 dff4a550 c04fe040 c04fe088 000f41fa c04fe040 c14f855=
0=20

=00       c15b7f58 c15b7f68 00000086 00000286 c04fe040 dff4a000 00000000 =
45e62540=20

=00       000f41fa dff4a6b8 c15b7fb0 c15b7fa4 c15b6000 c014f760 c014f279 =
c04fe088=20

=00Call Trace:

=00 [<c014f760>] pdflush+0x0/0x30

=00 [<c014f279>] __pdflush+0x139/0x620

=00 [<c014f786>] pdflush+0x26/0x30

=00 [<c014f760>] pdflush+0x0/0x30

=00 [<c013c25a>] kthread+0xaa/0xb0

=00 [<c013c1b0>] kthread+0x0/0xb0

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00pdflush       S C04FE040  6440   172      9           174   171 (L-TLB=
)

=00c15b9f68 00000046 dff4a000 c04fe040 00000000 c15b9f1c 00000400 0000000=
0=20

=00       00000000 00000000 00000000 00000000 00000005 c15b9fa4 00000000 =
4db3bd80=20

=00       000f42ec dff4a168 c15b9fb0 c15b9fa4 c15b8000 c014f760 c014f279 =
00000000=20

=00Call Trace:

=00 [<c014f760>] pdflush+0x0/0x30

=00 [<c014f279>] __pdflush+0x139/0x620

=00 [<c014f786>] pdflush+0x26/0x30

=00 [<c014f760>] pdflush+0x0/0x30

=00 [<c013c25a>] kthread+0xaa/0xb0

=00 [<c013c1b0>] kthread+0x0/0xb0

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00aio/0         S C04FE088  7828   174      9                 172 (L-TLB=
)

=00c15cdf38 00000046 c14f8aa0 c04fe088 000f41fa c15cc000 c15cc000 c159655=
0=20

=00       00010000 c0130e30 00010000 469d4040 000f41fa c14f8aa0 00000000 =
469d4040=20

=00       000f41fa c15966b8 c15cc000 c1589980 c15899a8 c15cdf94 c0135825 =
00000011=20

=00Call Trace:

=00 [<c0130e30>] do_sigaction+0x2e0/0x690

=00 [<c0135825>] worker_thread+0x435/0x460

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c01353f0>] worker_thread+0x0/0x460

=00 [<c013c25a>] kthread+0xaa/0xb0

=00 [<c013c1b0>] kthread+0x0/0xb0

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00kswapd0       S C04FE040  7824   173      1           761     9 (L-TLB=
)

=00c15cbf88 00000046 c1596aa0 c04fe040 00000296 c14f40ac c15ca000 c15ca00=
0=20

=00       c011fb20 c0449640 00000246 00000068 c15ca000 c14f2aa0 00000000 =
45e62540=20

=00       000f41fa c1596c08 c15ca000 00000000 c044a66c c044a220 c0157685 =
c03f19dd=20

=00Call Trace:

=00 [<c011fb20>] reparent_to_init+0x100/0x170

=00 [<c0157685>] kswapd+0xf5/0x110

=00 [<c013cdc0>] autoremove_wake_function+0x0/0x60

=00 [<c013cdc0>] autoremove_wake_function+0x0/0x60

=00 [<c0157590>] kswapd+0x0/0x110

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00kseriod       S C04FE040  7912   761      1           802   173 (L-TLB=
)

=00c15dff8c 00000046 c1596000 c04fe040 00000292 c1599cac c15de000 c15de00=
0=20

=00       00000296 00000000 00000246 c011fd3a c15de000 c14f2aa0 00000000 =
5dcceb80=20

=00       000f41fa c1596168 c15dffc0 ffffe000 c15de000 c15dffcc c02a268e =
0000000f=20

=00Call Trace:

=00 [<c011fd3a>] allow_signal+0xea/0x210

=00 [<c02a268e>] serio_thread+0xce/0x130

=00 [<c013cdc0>] autoremove_wake_function+0x0/0x60

=00 [<c01039c2>] ret_from_fork+0x6/0x14

=00 [<c013cdc0>] autoremove_wake_function+0x0/0x60

=00 [<c02a25c0>] serio_thread+0x0/0x130

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00scsi_eh_0     S C04FE040  7812   802      1           819   761 (L-TLB=
)

=00dfc71f28 00000046 dfc46aa0 c04fe040 c0117ac2 c14f2aa0 c04fe088 000f41f=
b=20

=00       c04fe040 c14f2aa0 dfc71f20 dfc71f30 00000082 c14f2aa0 00000000 =
d3d1d240=20

=00       000f41fb dfc46c08 dfc71fb8 dfc71fc0 00000246 dfc46aa0 c03d7b1c =
dfc71f58=20

=00Call Trace:

=00 [<c0117ac2>] activate_task+0x62/0x80

=00 [<c03d7b1c>] __down_interruptible+0x13c/0x334

=00 [<c0118961>] __wake_up_common+0x41/0x70

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c03d7d27>] __down_failed_interruptible+0x7/0xc

=00 [<c0319338>] .text.lock.scsi_error+0x3b/0x43

=00 [<c0318cc0>] scsi_error_handler+0x0/0x150

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00kjournald     S C04FE040  6528   819      1          1779   802 (L-TLB=
)

=00dfc93f34 00000046 dfc46550 c04fe040 dfc8acbc dfc8aca4 00000001 0000000=
3=20

=00       dfc93f34 00000282 00000246 00000003 00000001 00000000 00000000 =
0ab35d40=20

=00       000f42e9 dfc466b8 dfc8ac00 00000000 00000001 dfc8ace4 c020e2de =
00000000=20

=00Call Trace:

=00 [<c020e2de>] kjournald+0x4de/0x6c0

=00 [<c013cdc0>] autoremove_wake_function+0x0/0x60

=00 [<c013cdc0>] autoremove_wake_function+0x0/0x60

=00 [<c020dde0>] commit_timeout+0x0/0x10

=00 [<c020de00>] kjournald+0x0/0x6c0

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00dhclient      S C04FE040  6576  1779      1          1790   819 (NOTLB=
)

=00dfb2de80 00000082 dfb2b000 c04fe040 00000000 00000001 00000000 0000000=
0=20

=00       c04485a0 00000246 c04485a0 dfb2de94 00000246 dfb2baa0 00000000 =
1159e1c0=20

=00       000f4206 dfb2b168 028f5f41 dfb2de94 00000007 00000000 c03d9bde =
dfb2de94=20

=00Call Trace:

=00 [<c03d9bde>] schedule_timeout+0x8e/0xe0

=00 [<c012a490>] process_timeout+0x0/0x10

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c011614c>] do_page_fault+0x1bc/0x5e9

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00portmap       S C04FE040  6556  1790      1          1848  1779 (NOTLB=
)

=00df40def0 00000082 dfb2baa0 c04fe040 c025064c 00000246 df9da080 df40dfa=
0=20

=00       df7df918 c014cc3f 00000246 c018c29c df781080 dfba6000 00000000 =
5e8a0380=20

=00       000f4206 dfb2bc08 00000000 7fffffff df40df68 7fffffff c03d9c2a =
df7df718=20

=00Call Trace:

=00 [<c025064c>] copy_to_user+0x6c/0x80

=00 [<c014cc3f>] __get_free_pages+0x1f/0x40

=00 [<c018c29c>] __pollwait+0x8c/0xd0

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c03485bb>] sock_destroy_inode+0x1b/0x20

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018ce9b>] do_pollfd+0x5b/0xa0

=00 [<c018cf88>] do_poll+0xa8/0xd0

=00 [<c018d111>] sys_poll+0x161/0x240

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00syslogd       S C04FE040  6228  1848      1          1851  1790 (NOTLB=
)

=00df3bbe80 00000082 dfd75550 c04fe040 00000246 c044a374 00000000 0000000=
0=20

=00       000000d0 c014cac3 c044a61c c044a374 000000d0 00000001 00000000 =
af55a300=20

=00       000f42ec dfd756b8 00000000 7fffffff 00000001 00000000 c03d9c2a =
00000246=20

=00Call Trace:

=00 [<c014cac3>] __alloc_pages+0x2f3/0x450

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c014cc3f>] __get_free_pages+0x1f/0x40

=00 [<c018c29c>] __pollwait+0x8c/0xd0

=00 [<c03503eb>] datagram_poll+0x2b/0xd0

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c0103919>] do_signal+0xc9/0x130

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00klogd         R running  6576  1851      1          1880  1848 (NOTLB)=


=00acpid         S C04FE040  6608  1880      1          1910  1851 (NOTLB=
)

=00df421ef0 00000082 dfb2b550 c04fe040 c044a374 00000000 00000000 000000d=
0=20

=00       c014cac3 c044a61c c044a374 000000d0 00000001 00000000 00000000 =
2e8eb040=20

=00       000f4206 dfb2b6b8 00000000 7fffffff df421f68 7fffffff c03d9c2a =
dfb53800=20

=00Call Trace:

=00 [<c014cac3>] __alloc_pages+0x2f3/0x450

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c03bb48b>] unix_poll+0x2b/0xb0

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018ce9b>] do_pollfd+0x5b/0xa0

=00 [<c018cf88>] do_poll+0xa8/0xd0

=00 [<c018d111>] sys_poll+0x161/0x240

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00exim4         S C04FE040  6576  1910      1          1915  1880 (NOTLB=
)

=00ded1de80 00000082 dfd75000 c04fe040 c044a61c c044a374 000000d0 0000000=
1=20

=00       00000000 00000000 00000001 00000000 dfd75000 00000010 00000000 =
44ca3780=20

=00       000f4206 dfd75168 00000000 7fffffff 00000001 00000000 c03d9c2a =
c018c29c=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c018c29c>] __pollwait+0x8c/0xd0

=00 [<c03896dd>] tcp_poll+0x2d/0x190

=00 [<c011f64c>] release_task+0x17c/0x260

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c011614c>] do_page_fault+0x1bc/0x5e9

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c01235b5>] sys_waitpid+0x25/0x29

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00inetd         S C04FE040  6576  1915      1          1919  1910 (NOTLB=
)

=00dfbebe80 00000082 dfba6550 c04fe040 c044a61c c044a374 000000d0 0000000=
1=20

=00       00000000 00000000 00000001 00000000 00000246 00000010 0003d090 =
4182fbc0=20

=00       000f4206 dfba66b8 00000000 7fffffff 00000009 00000000 c03d9c2a =
c03503eb=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c03503eb>] datagram_poll+0x2b/0xd0

=00 [<c03896dd>] tcp_poll+0x2d/0x190

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c011614c>] do_page_fault+0x1bc/0x5e9

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00lpd           S C04FE040  6576  1919      1          1927  1915 (NOTLB=
)

=00dedf3e80 00000082 dfba6aa0 c04fe040 00000246 c044a374 00000000 0000000=
0=20

=00       000000d0 c014cac3 c044a61c c044a374 000000d0 00000001 00000000 =
46fecac0=20

=00       000f4206 dfba6c08 00000000 7fffffff 00000006 00000000 c03d9c2a =
00000246=20

=00Call Trace:

=00 [<c014cac3>] __alloc_pages+0x2f3/0x450

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c014cc3f>] __get_free_pages+0x1f/0x40

=00 [<c018c29c>] __pollwait+0x8c/0xd0

=00 [<c03bb48b>] unix_poll+0x2b/0xb0

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c0199a6f>] notify_change+0x19f/0x25a

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00sshd          S C04FE040  6576  1927      1  2017    1933  1919 (NOTLB=
)

=00ded91e80 00000082 c17a7000 c04fe040 c044a61c c044a374 000000d0 0000000=
1=20

=00       00000000 00000000 00000001 00000000 c17a7000 deaa2aa0 00000000 =
5efcddc0=20

=00       000f42af c17a7168 00000000 7fffffff 00000004 00000000 c03d9c2a =
c018c29c=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c018c29c>] __pollwait+0x8c/0xd0

=00 [<c03896dd>] tcp_poll+0x2d/0x190

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c01962ef>] clear_inode+0x5f/0xf0

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00rpc.statd     S C04FE040  6364  1933      1          1936  1927 (NOTLB=
)

=00def75e80 00000082 dfba6000 c04fe040 00000000 00000001 00000000 dfba600=
0=20

=00       00000010 c044a61c 00000000 00000000 00000246 def26080 00000000 =
5e8a0380=20

=00       000f4206 dfba6168 00000000 7fffffff 00000007 00000000 c03d9c2a =
c03503eb=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c03503eb>] datagram_poll+0x2b/0xd0

=00 [<c03896dd>] tcp_poll+0x2d/0x190

=00 [<c034a0d2>] sys_recvfrom+0x102/0x120

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c01962ef>] clear_inode+0x5f/0xf0

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00ntpd          S C04FE040  6092  1936      1          1941  1933 (NOTLB=
)

=00de8e7e80 00000082 def0daa0 c04fe040 00000000 00000001 00000000 def0daa=
0=20

=00       00000010 c044a61c 00000000 bffffa10 00000246 de9ea680 00000000 =
fc0bb2c0=20

=00       000f42ec def0dc08 00000000 7fffffff 00000009 00000000 c03d9c2a =
c03503eb=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c03503eb>] datagram_poll+0x2b/0xd0

=00 [<c03a6ae2>] udp_poll+0x22/0x230

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c0103919>] do_signal+0xc9/0x130

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00atd           S C04FE040  6576  1941      1          1944  1936 (NOTLB=
)

=00dea2bf30 00000082 def0d550 c04fe040 c011614c dfa28c80 df9bcb1c 0000000=
0=20

=00       c04485a0 00000246 c04485a0 dea2bf44 dea2bfc4 00000000 00000000 =
61572d40=20

=00       000f4206 def0d6b8 003329f2 dea2bf44 000f41a7 00000e10 c03d9bde =
dea2bf44=20

=00Call Trace:

=00 [<c011614c>] do_page_fault+0x1bc/0x5e9

=00 [<c03d9bde>] schedule_timeout+0x8e/0xe0

=00 [<c012a490>] process_timeout+0x0/0x10

=00 [<c012a58e>] sys_nanosleep+0xde/0x170

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00cron          S C04FE040  6712  1944      1          1950  1941 (NOTLB=
)

=00dea2df30 00000082 def0d000 c04fe040 00000060 00000803 00000000 0000000=
0=20

=00       c04485a0 00000246 c04485a0 dea2df44 00000000 00000000 00000000 =
afb9f600=20

=00       000f42df def0d168 000b6183 dea2df44 000f41a7 0000003c c03d9bde =
dea2df44=20

=00Call Trace:

=00 [<c03d9bde>] schedule_timeout+0x8e/0xe0

=00 [<c012a490>] process_timeout+0x0/0x10

=00 [<c012a58e>] sys_nanosleep+0xde/0x170

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00getty         S C04FE040  6608  1950      1          1951  1944 (NOTLB=
)

=00df8bde4c 00000082 c17a7aa0 c04fe040 00000000 00000001 0000001c 0000000=
0=20

=00       deb78220 00000000 00000008 00000202 00000203 c17a7550 00000000 =
a6c7aa80=20

=00       000f4206 c17a7c08 df6be000 7fffffff 7fffffff 00000000 c03d9c2a =
00001961=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c025af9d>] vgacon_cursor+0x16d/0x400

=00 [<c0299cfa>] set_cursor+0x6a/0x90

=00 [<c02917ab>] read_chan+0xd0b/0xe40

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c02893c3>] tty_write+0xb3/0x280

=00 [<c02892ec>] tty_read+0xec/0x110

=00 [<c017219e>] vfs_read+0xae/0x130

=00 [<c0172491>] sys_read+0x51/0x80

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00getty         S C04FE040  6980  1951      1          1952  1950 (NOTLB=
)

=00df8cfe4c 00000082 c17a7550 c04fe040 00000000 00000001 0000001c 0000000=
0=20

=00       deb78220 00000000 00000008 00000202 00000203 dfc46000 00000000 =
a6c7aa80=20

=00       000f4206 c17a76b8 de8ea000 7fffffff 7fffffff 00000000 c03d9c2a =
00000008=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c029cc76>] do_con_write+0x266/0x680

=00 [<c011e2da>] acquire_console_sem+0x2a/0x50

=00 [<c02917ab>] read_chan+0xd0b/0xe40

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c02893c3>] tty_write+0xb3/0x280

=00 [<c02892ec>] tty_read+0xec/0x110

=00 [<c017219e>] vfs_read+0xae/0x130

=00 [<c0172491>] sys_read+0x51/0x80

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00getty         S C04FE040  6980  1952      1          1953  1951 (NOTLB=
)

=00ded2fe4c 00000082 dfc46000 c04fe040 00000000 00000001 0000001c 0000000=
0=20

=00       deb78220 00000000 00000008 00000202 00000203 dea4b550 00000000 =
a6c7aa80=20

=00       000f4206 dfc46168 df6ac000 7fffffff 7fffffff 00000000 c03d9c2a =
00000008=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c029cc76>] do_con_write+0x266/0x680

=00 [<c011e2da>] acquire_console_sem+0x2a/0x50

=00 [<c02917ab>] read_chan+0xd0b/0xe40

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c02893c3>] tty_write+0xb3/0x280

=00 [<c02892ec>] tty_read+0xec/0x110

=00 [<c017219e>] vfs_read+0xae/0x130

=00 [<c0172491>] sys_read+0x51/0x80

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00getty         S C04FE088  6980  1953      1          1954  1952 (NOTLB=
)

=00dea7fe4c 00000082 dea4b000 c04fe088 000f4206 00000001 0000001c 0000000=
0=20

=00       deb78220 00000000 00000008 a957cb40 000f4206 dea4b000 00000000 =
a957cb40=20

=00       000f4206 dea4bc08 deb79000 7fffffff 7fffffff 00000000 c03d9c2a =
00000008=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c029cc76>] do_con_write+0x266/0x680

=00 [<c011e2da>] acquire_console_sem+0x2a/0x50

=00 [<c02917ab>] read_chan+0xd0b/0xe40

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c02893c3>] tty_write+0xb3/0x280

=00 [<c02892ec>] tty_read+0xec/0x110

=00 [<c017219e>] vfs_read+0xae/0x130

=00 [<c0172491>] sys_read+0x51/0x80

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00getty         S C04FE040  6980  1954      1          1955  1953 (NOTLB=
)

=00de9c3e4c 00000082 dea4b550 c04fe040 00000000 00000001 0000001c 0000000=
0=20

=00       deb78220 00000000 00000008 00000202 00000203 dea22aa0 00000000 =
a6c7aa80=20

=00       000f4206 dea4b6b8 deaa3000 7fffffff 7fffffff 00000000 c03d9c2a =
00000008=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c029cc76>] do_con_write+0x266/0x680

=00 [<c011e2da>] acquire_console_sem+0x2a/0x50

=00 [<c02917ab>] read_chan+0xd0b/0xe40

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c02893c3>] tty_write+0xb3/0x280

=00 [<c02892ec>] tty_read+0xec/0x110

=00 [<c017219e>] vfs_read+0xae/0x130

=00 [<c0172491>] sys_read+0x51/0x80

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00getty         S C04FE040  6980  1955      1          1956  1954 (NOTLB=
)

=00dea7de4c 00000082 dea4b000 c04fe040 00000000 00000001 0000001c 0000000=
0=20

=00       deb78220 00000000 00000008 00000202 00000203 00000034 00000000 =
a957cb40=20

=00       000f4206 dea4b168 deb2e000 7fffffff 7fffffff 00000000 c03d9c2a =
00000008=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c029cc76>] do_con_write+0x266/0x680

=00 [<c011e2da>] acquire_console_sem+0x2a/0x50

=00 [<c02917ab>] read_chan+0xd0b/0xe40

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c02893c3>] tty_write+0xb3/0x280

=00 [<c02892ec>] tty_read+0xec/0x110

=00 [<c017219e>] vfs_read+0xae/0x130

=00 [<c0172491>] sys_read+0x51/0x80

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00getty         S C04FE040  6964  1956      1                1955 (NOTLB=
)

=00dea87e4c 00000082 dea22aa0 c04fe040 00100100 00200200 000aa653 1d244b3=
c=20

=00       00000000 00000005 c03eed36 00000202 00000203 00000034 00000000 =
8067fac0=20

=00       000f42e2 dea22c08 dfc6b000 7fffffff 7fffffff 00000000 c03d9c2a =
00000001=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c0159b83>] zap_pmd_range+0x53/0x70

=00 [<c02a705c>] uart_write+0x15c/0x1e0

=00 [<c02917ab>] read_chan+0xd0b/0xe40

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c02893c3>] tty_write+0xb3/0x280

=00 [<c02892ec>] tty_read+0xec/0x110

=00 [<c017219e>] vfs_read+0xae/0x130

=00 [<c0172491>] sys_read+0x51/0x80

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00sshd          S C04FE040  6400  2017   1927  2019    2021       (NOTLB=
)

=00deb2de80 00000082 dea22000 c04fe040 00000282 de434080 00000246 c0488cf=
8=20

=00       c0488ce0 00000001 00000003 deb2de8c 00000086 de524550 00000000 =
8866a740=20

=00       000f42e6 dea22168 00000000 7fffffff 00000008 00000000 c03d9c2a =
deafca80=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c0291c2c>] normal_poll+0x11c/0x16b

=00 [<c028b309>] tty_poll+0x89/0xc0

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c010597b>] do_IRQ+0x3b/0x70

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00bash          S C04FE040  6496  2019   2017  2025               (NOTLB=
)

=00deb69f1c 00000082 dea22550 c04fe040 01200011 c17a9680 c17a96ac deb6364=
c=20

=00       dea22550 c011614c c17a9680 00000246 080e8080 00000001 00000000 =
d13c6500=20

=00       000f42e5 dea226b8 dea225f0 dea22550 fffffe00 dea225f0 c0123157 =
ffffffff=20

=00Call Trace:

=00 [<c011614c>] do_page_fault+0x1bc/0x5e9

=00 [<c0123157>] do_wait+0x197/0x4f0

=00 [<c011f8de>] session_of_pgrp+0x1e/0x90

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c018b7b8>] do_ioctl+0x58/0x80

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c012f92a>] sys_rt_sigprocmask+0xaa/0x2a0

=00 [<c012357d>] sys_wait4+0x3d/0x50

=00 [<c01235b5>] sys_waitpid+0x25/0x29

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00sshd          S C04FE088  6176  2021   1927  2023          2017 (NOTLB=
)

=00debfde80 00000082 deaa2550 c04fe088 000f42ed 00000030 00000246 c0488cf=
8=20

=00       c0488ce0 00000001 00000003 10e84640 000f42ed deaa2550 00000000 =
10e84640=20

=00       000f42ed deaa2c08 00000000 7fffffff 00000008 00000000 c03d9c2a =
deb74080=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c0291c2c>] normal_poll+0x11c/0x16b

=00 [<c028b309>] tty_poll+0x89/0xc0

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00bash          R running  6520  2023   2021                     (NOTLB)=


=00iperf         S C04FE040  6224  2025   2019          2026       (NOTLB=
)

=00de523e60 00000082 deaa2000 c04fe040 c14dd180 df376f80 000000d0 c0151c9=
5=20

=00       c14dd180 df376f80 00000001 000000d0 004fa025 de524aa0 00000000 =
d5870700=20

=00       000f42e5 deaa2168 00000000 7fffffff de522000 08056158 c03d9c2a =
08056000=20

=00Call Trace:

=00 [<c0151c95>] cache_grow+0x175/0x350

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c01600c9>] find_extend_vma+0x29/0x90

=00 [<c013de2f>] queue_me+0x8f/0x1c0

=00 [<c013d2c5>] get_futex_key+0x45/0x360

=00 [<c013e2e1>] futex_wait+0x171/0x1f0

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c011cb59>] do_fork+0x199/0x1ef

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0161460>] mprotect_fixup+0x180/0x1e0

=00 [<c013e628>] do_futex+0x48/0xa0

=00 [<c013e76e>] sys_futex+0xee/0x100

=00 [<c0101afc>] sys_clone+0x3c/0x40

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00iperf         S C04FE040  6860  2026   2019          2027  2025 (NOTLB=
)

=00de625e60 00000082 de524aa0 c04fe040 000f42e6 df376f00 000000d0 c0151c9=
5=20

=00       c14dd180 df376f00 00000001 8866a740 000f42e6 de524550 00000000 =
8866a740=20

=00       000f42e6 de524c08 00000000 7fffffff de624000 08058298 c03d9c2a =
08058000=20

=00Call Trace:

=00 [<c0151c95>] cache_grow+0x175/0x350

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c01600c9>] find_extend_vma+0x29/0x90

=00 [<c013de2f>] queue_me+0x8f/0x1c0

=00 [<c013d2c5>] get_futex_key+0x45/0x360

=00 [<c013e2e1>] futex_wait+0x171/0x1f0

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c013e628>] do_futex+0x48/0xa0

=00 [<c013e76e>] sys_futex+0xee/0x100

=00 [<c0101afc>] sys_clone+0x3c/0x40

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00iperf         S C04FE040  6296  2027   2019                2026 (NOTLB=
)

=00de627d20 00000082 de524550 c04fe040 00000000 00000000 00000246 0000000=
0=20

=00       de524550 00000010 c044a61c 00000000 000000d0 def0daa0 000f4240 =
df6cfc00=20

=00       000f42e7 de5246b8 de434080 7fffffff de627da4 00000000 c03d9c2a =
000000d0=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c0151c95>] cache_grow+0x175/0x350

=00 [<c0124a1b>] __do_softirq+0x7b/0x90

=00 [<c015206d>] cache_alloc_refill+0x1fd/0x320

=00 [<c03508ff>] sk_stream_wait_memory+0x16f/0x1e0

=00 [<c013cdc0>] autoremove_wake_function+0x0/0x60

=00 [<c013cdc0>] autoremove_wake_function+0x0/0x60

=00 [<c02506cc>] copy_from_user+0x6c/0xa0

=00 [<c038b600>] tcp_sendmsg+0xbf0/0x1080

=00 [<c03ad14d>] inet_sendmsg+0x4d/0x60

=00 [<c0348e06>] sock_aio_write+0xf6/0x120

=00 [<c011860d>] scheduler_tick+0xfd/0x3f0

=00 [<c01722d7>] do_sync_write+0xb7/0xf0

=00 [<c0124a1b>] __do_softirq+0x7b/0x90

=00 [<c010597b>] do_IRQ+0x3b/0x70

=00 [<c013cdc0>] autoremove_wake_function+0x0/0x60

=00 [<c0172428>] vfs_write+0x118/0x130

=00 [<c0172511>] sys_write+0x51/0x80

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00SysRq : Show Regs

=00
Debian GNU/Linux 3.1 source1ng ttyS0

source1ng login: SysRq : Show Regs


--------------070500030203030802020608
Content-Type: text/x-log;
 name="sysrq2.log"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="sysrq2.log"

=FF=FD=03=FF=FB=03=FF=FB=01SysRq : Show Regs

=00SysRq : Show State


=00                                               sibling

=00  task             PC      pid father child younger older

=00init          S C04FE040  5016     1      0     2               (NOTLB=
)

=00dffa1e80 00000082 c14f2aa0 c04fe040 00000246 c0151c95 00000246 0000000=
0=20

=00       c04485a0 00000246 c04485a0 dffa1e94 c044a61c c044a374 00000000 =
e6b479c0=20

=00       000f4328 c14f2c08 000f56f7 dffa1e94 0000000b 00000000 c03d9bde =
dffa1e94=20

=00Call Trace:

=00 [<c0151c95>] cache_grow+0x175/0x350

=00 [<c03d9bde>] schedule_timeout+0x8e/0xe0

=00 [<c012a490>] process_timeout+0x0/0x10

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00ksoftirqd/0   S C04FE040  7856     2      1             3       (L-TLB=
)

=00dffa3fb0 00000046 c14f2550 c04fe040 dfa9a970 00000000 c050f448 0000000=
7=20

=00       c01371ff c0449948 c0449970 c050ffc0 c0124c60 00000000 00000000 =
cfa63480=20

=00       000f41fc c14f26b8 dffa2000 dffa1f50 00000000 c0124d70 c0124df3 =
c14f2550=20

=00Call Trace:

=00 [<c01371ff>] rcu_process_callbacks+0x3f/0x50

=00 [<c0124c60>] tasklet_action+0x40/0x60

=00 [<c0124d70>] ksoftirqd+0x0/0xa0

=00 [<c0124df3>] ksoftirqd+0x83/0xa0

=00 [<c013c25a>] kthread+0xaa/0xb0

=00 [<c013c1b0>] kthread+0x0/0xb0

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00events/0      S C04FE088  6724     3      1             4     2 (L-TLB=
)

=00dffa7f38 00000046 dff4a000 c04fe088 000f4328 c14da6c8 00000001 0000000=
3=20

=00       dffa7f38 00000086 c14da6c8 e6b479c0 000f4328 dff4a000 00000000 =
e6b479c0=20

=00       000f4328 c14f2168 00000000 c14da680 c14da6a8 dffa7f94 c0135825 =
00000000=20

=00Call Trace:

=00 [<c0135825>] worker_thread+0x435/0x460

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c01353f0>] worker_thread+0x0/0x460

=00 [<c013c25a>] kthread+0xaa/0xb0

=00 [<c013c1b0>] kthread+0x0/0xb0

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00khelper       S C04FE040  7192     4      1             9     3 (L-TLB=
)

=00dffadf38 00000046 c14f8aa0 c04fe040 c14da5e0 c14da5c8 00000001 0000000=
3=20

=00       dffadf38 00000086 c14da5c8 00000246 00000001 de6f4aa0 00000000 =
499dae00=20

=00       000f4205 c14f8c08 de5c3d64 c14da580 c14da5a8 dffadf94 c0135825 =
00000000=20

=00Call Trace:

=00 [<c0135825>] worker_thread+0x435/0x460

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c01353f0>] worker_thread+0x0/0x460

=00 [<c013c25a>] kthread+0xaa/0xb0

=00 [<c013c1b0>] kthread+0x0/0xb0

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00kthread       S C04FE040  7240     9      1    17     173     4 (L-TLB=
)

=00dffaff38 00000046 c14f8550 c04fe040 dff82de0 dff82dc8 00000001 0000000=
3=20

=00       dffaff38 00000086 dff82dc8 00000246 00000001 c1596aa0 00000000 =
4599da00=20

=00       000f41fa c14f86b8 dffa1ed4 dff82d80 dff82da8 dffaff94 c0135825 =
00000000=20

=00Call Trace:

=00 [<c0135825>] worker_thread+0x435/0x460

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c01353f0>] worker_thread+0x0/0x460

=00 [<c013c25a>] kthread+0xaa/0xb0

=00 [<c013c1b0>] kthread+0x0/0xb0

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00kacpid        S C04FE040  7828    17      9           106       (L-TLB=
)

=00dff09f38 00000046 c14f8000 c04fe040 00000000 dff08000 dff08000 c14f800=
0=20

=00       00010000 c0130e30 00010000 00000246 00000296 c14f2aa0 00000000 =
3666dc40=20

=00       000f41fa c14f8168 dff08000 dff82280 dff822a8 dff09f94 c0135825 =
00000011=20

=00Call Trace:

=00 [<c0130e30>] do_sigaction+0x2e0/0x690

=00 [<c0135825>] worker_thread+0x435/0x460

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c01353f0>] worker_thread+0x0/0x460

=00 [<c013c25a>] kthread+0xaa/0xb0

=00 [<c013c1b0>] kthread+0x0/0xb0

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00kblockd/0     S C04FE040  7164   106      9           171    17 (L-TLB=
)

=00c1563f38 00000046 dff4aaa0 c04fe040 dff514e0 dff514c8 00000001 0000000=
3=20

=00       c1563f38 00000086 dff514c8 00000246 00000001 00000000 00000000 =
92d65c80=20

=00       000f4326 dff4ac08 dfc4a988 dff51480 dff514a8 c1563f94 c0135825 =
00000000=20

=00Call Trace:

=00 [<c0135825>] worker_thread+0x435/0x460

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c01353f0>] worker_thread+0x0/0x460

=00 [<c013c25a>] kthread+0xaa/0xb0

=00 [<c013c1b0>] kthread+0x0/0xb0

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00pdflush       S C04FE040  7876   171      9           172   106 (L-TLB=
)

=00c15b7f68 00000046 dff4a550 c04fe040 c04fe088 000f41fa c04fe040 c14f855=
0=20

=00       c15b7f58 c15b7f68 00000086 00000286 c04fe040 dff4a000 00000000 =
4599da00=20

=00       000f41fa dff4a6b8 c15b7fb0 c15b7fa4 c15b6000 c014f760 c014f279 =
c04fe088=20

=00Call Trace:

=00 [<c014f760>] pdflush+0x0/0x30

=00 [<c014f279>] __pdflush+0x139/0x620

=00 [<c014f786>] pdflush+0x26/0x30

=00 [<c014f760>] pdflush+0x0/0x30

=00 [<c013c25a>] kthread+0xaa/0xb0

=00 [<c013c1b0>] kthread+0x0/0xb0

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00pdflush       S C04FE088  6440   172      9           174   171 (L-TLB=
)

=00c15b9f68 00000046 c14f2aa0 c04fe088 000f4328 c15b9f1c 000003f2 0000000=
e=20

=00       00000000 00000000 00000000 e6b479c0 000f4328 c14f2aa0 00000000 =
e6b479c0=20

=00       000f4328 dff4a168 c15b9fb0 c15b9fa4 c15b8000 c014f760 c014f279 =
00000000=20

=00Call Trace:

=00 [<c014f760>] pdflush+0x0/0x30

=00 [<c014f279>] __pdflush+0x139/0x620

=00 [<c014f786>] pdflush+0x26/0x30

=00 [<c014f760>] pdflush+0x0/0x30

=00 [<c013c25a>] kthread+0xaa/0xb0

=00 [<c013c1b0>] kthread+0x0/0xb0

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00aio/0         S C04FE088  7828   174      9                 172 (L-TLB=
)

=00c15cdf38 00000046 c14f8aa0 c04fe088 000f41fa c15cc000 c15cc000 c159655=
0=20

=00       00010000 c0130e30 00010000 4641b2c0 000f41fa c14f8aa0 00000000 =
4641b2c0=20

=00       000f41fa c15966b8 c15cc000 c1589980 c15899a8 c15cdf94 c0135825 =
00000011=20

=00Call Trace:

=00 [<c0130e30>] do_sigaction+0x2e0/0x690

=00 [<c0135825>] worker_thread+0x435/0x460

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c01353f0>] worker_thread+0x0/0x460

=00 [<c013c25a>] kthread+0xaa/0xb0

=00 [<c013c1b0>] kthread+0x0/0xb0

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00kswapd0       S C04FE040  7824   173      1           761     9 (L-TLB=
)

=00c15cbf88 00000046 c1596aa0 c04fe040 00000296 c14f40ac c15ca000 c15ca00=
0=20

=00       c011fb20 c0449640 00000246 00000068 c15ca000 c14f2aa0 00000000 =
4599da00=20

=00       000f41fa c1596c08 c15ca000 00000000 c044a66c c044a220 c0157685 =
c03f19dd=20

=00Call Trace:

=00 [<c011fb20>] reparent_to_init+0x100/0x170

=00 [<c0157685>] kswapd+0xf5/0x110

=00 [<c013cdc0>] autoremove_wake_function+0x0/0x60

=00 [<c013cdc0>] autoremove_wake_function+0x0/0x60

=00 [<c0157590>] kswapd+0x0/0x110

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00kseriod       S C04FE040  7912   761      1           802   173 (L-TLB=
)

=00c15dff8c 00000046 c1596000 c04fe040 00000292 c1599cac c15de000 c15de00=
0=20

=00       00000296 00000000 00000246 c011fd3a c15de000 c14f2aa0 00000000 =
5d80a040=20

=00       000f41fa c1596168 c15dffc0 ffffe000 c15de000 c15dffcc c02a268e =
0000000f=20

=00Call Trace:

=00 [<c011fd3a>] allow_signal+0xea/0x210

=00 [<c02a268e>] serio_thread+0xce/0x130

=00 [<c013cdc0>] autoremove_wake_function+0x0/0x60

=00 [<c01039c2>] ret_from_fork+0x6/0x14

=00 [<c013cdc0>] autoremove_wake_function+0x0/0x60

=00 [<c02a25c0>] serio_thread+0x0/0x130

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00scsi_eh_0     S C04FE040  7812   802      1           819   761 (L-TLB=
)

=00dfc71f28 00000046 dfc45aa0 c04fe040 c0117ac2 c14f2aa0 c04fe088 000f41f=
b=20

=00       c04fe040 c14f2aa0 dfc71f20 dfc71f30 00000082 c14f2aa0 00000000 =
c4158040=20

=00       000f41fb dfc45c08 dfc71fb8 dfc71fc0 00000246 dfc45aa0 c03d7b1c =
dfc71f58=20

=00Call Trace:

=00 [<c0117ac2>] activate_task+0x62/0x80

=00 [<c03d7b1c>] __down_interruptible+0x13c/0x334

=00 [<c0118961>] __wake_up_common+0x41/0x70

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c03d7d27>] __down_failed_interruptible+0x7/0xc

=00 [<c0319338>] .text.lock.scsi_error+0x3b/0x43

=00 [<c0318cc0>] scsi_error_handler+0x0/0x150

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00kjournald     S C04FE040  6528   819      1          1671   802 (L-TLB=
)

=00dfc93f34 00000046 dfc45550 c04fe040 dfc89cbc dfc89ca4 00000001 0000000=
3=20

=00       dfc93f34 00000282 00000246 00000003 00000001 00000000 00000000 =
1e032280=20

=00       000f4326 dfc456b8 dfc89c00 00000000 00000001 dfc89ce4 c020e2de =
00000000=20

=00Call Trace:

=00 [<c020e2de>] kjournald+0x4de/0x6c0

=00 [<c013cdc0>] autoremove_wake_function+0x0/0x60

=00 [<c013cdc0>] autoremove_wake_function+0x0/0x60

=00 [<c020dde0>] commit_timeout+0x0/0x10

=00 [<c020de00>] kjournald+0x0/0x6c0

=00 [<c01012fd>] kernel_thread_helper+0x5/0x18

=00dhclient      S C04FE040  6576  1671      1          1682   819 (NOTLB=
)

=00dfbd9e80 00000082 df850000 c04fe040 00000000 00000001 00000000 0000000=
0=20

=00       c04485a0 00000246 c04485a0 dfbd9e94 00000246 c17cdc80 00000000 =
2ee9be00=20

=00       000f4205 df850168 028f4f50 dfbd9e94 00000007 00000000 c03d9bde =
dfbd9e94=20

=00Call Trace:

=00 [<c03d9bde>] schedule_timeout+0x8e/0xe0

=00 [<c012a490>] process_timeout+0x0/0x10

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c011614c>] do_page_fault+0x1bc/0x5e9

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00portmap       S C04FE040  6556  1682      1          1739  1671 (NOTLB=
)

=00dfbb7ef0 00000082 dfba7000 c04fe040 c025064c 00000246 dfb0db80 dfbb7fa=
0=20

=00       df6a7918 c014cc3f 00000246 c018c29c df031080 dea45000 00000000 =
3dc12e40=20

=00       000f4205 dfba7168 00000000 7fffffff dfbb7f68 7fffffff c03d9c2a =
df6a7718=20

=00Call Trace:

=00 [<c025064c>] copy_to_user+0x6c/0x80

=00 [<c014cc3f>] __get_free_pages+0x1f/0x40

=00 [<c018c29c>] __pollwait+0x8c/0xd0

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c03485bb>] sock_destroy_inode+0x1b/0x20

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018ce9b>] do_pollfd+0x5b/0xa0

=00 [<c018cf88>] do_poll+0xa8/0xd0

=00 [<c018d111>] sys_poll+0x161/0x240

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00syslogd       S C04FE040  6444  1739      1          1742  1682 (NOTLB=
)

=00deecde80 00000082 dfad9550 c04fe040 00000246 c044a374 00000000 0000000=
0=20

=00       000000d0 c014cac3 c044a61c c044a374 000000d0 00000001 00000000 =
c5074280=20

=00       000f4328 dfad96b8 00000000 7fffffff 00000001 00000000 c03d9c2a =
00000246=20

=00Call Trace:

=00 [<c014cac3>] __alloc_pages+0x2f3/0x450

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c014cc3f>] __get_free_pages+0x1f/0x40

=00 [<c018c29c>] __pollwait+0x8c/0xd0

=00 [<c03503eb>] datagram_poll+0x2b/0xd0

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c0103919>] do_signal+0xc9/0x130

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00klogd         R running  6448  1742      1          1771  1739 (NOTLB)=


=00acpid         S C04FE040  6704  1771      1          1801  1742 (NOTLB=
)

=00dfb3def0 00000082 dfad9000 c04fe040 c044a374 00000000 00000000 000000d=
0=20

=00       c014cac3 c044a61c c044a374 000000d0 00000001 00000000 00000000 =
0acaea80=20

=00       000f4205 dfad9168 00000000 7fffffff dfb3df68 7fffffff c03d9c2a =
dfb53800=20

=00Call Trace:

=00 [<c014cac3>] __alloc_pages+0x2f3/0x450

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c03bb48b>] unix_poll+0x2b/0xb0

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018ce9b>] do_pollfd+0x5b/0xa0

=00 [<c018cf88>] do_poll+0xa8/0xd0

=00 [<c018d111>] sys_poll+0x161/0x240

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00exim4         S C04FE040  6576  1801      1          1806  1771 (NOTLB=
)

=00dea21e80 00000082 dfba7550 c04fe040 c044a61c c044a374 000000d0 0000000=
1=20

=00       00000000 00000000 00000001 00000000 dfba7550 00000010 00000000 =
248ab680=20

=00       000f4205 dfba76b8 00000000 7fffffff 00000001 00000000 c03d9c2a =
c018c29c=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c018c29c>] __pollwait+0x8c/0xd0

=00 [<c03896dd>] tcp_poll+0x2d/0x190

=00 [<c011f64c>] release_task+0x17c/0x260

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c011614c>] do_page_fault+0x1bc/0x5e9

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c01235b5>] sys_waitpid+0x25/0x29

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00inetd         S C04FE040  6576  1806      1          1811  1801 (NOTLB=
)

=00dfafbe80 00000082 dfad9aa0 c04fe040 c044a61c c044a374 000000d0 0000000=
1=20

=00       00000000 00000000 00000001 00000000 00000246 dea45550 00051615 =
20c968c0=20

=00       000f4205 dfad9c08 00000000 7fffffff 00000009 00000000 c03d9c2a =
c03503eb=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c03503eb>] datagram_poll+0x2b/0xd0

=00 [<c03896dd>] tcp_poll+0x2d/0x190

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c011614c>] do_page_fault+0x1bc/0x5e9

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00lpd           S C04FE040  6576  1811      1          1825  1806 (NOTLB=
)

=00de9ffe80 00000082 dfba7aa0 c04fe040 00000246 c044a374 00000000 0000000=
0=20

=00       000000d0 c014cac3 c044a61c c044a374 000000d0 00000001 00000000 =
2663bc40=20

=00       000f4205 dfba7c08 00000000 7fffffff 00000006 00000000 c03d9c2a =
00000246=20

=00Call Trace:

=00 [<c014cac3>] __alloc_pages+0x2f3/0x450

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c014cc3f>] __get_free_pages+0x1f/0x40

=00 [<c018c29c>] __pollwait+0x8c/0xd0

=00 [<c03bb48b>] unix_poll+0x2b/0xb0

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c0199a6f>] notify_change+0x19f/0x25a

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00sshd          S C04FE040  6576  1825      1  1915    1831  1811 (NOTLB=
)

=00dea93e80 00000082 dea45aa0 c04fe040 c044a61c c044a374 000000d0 0000000=
1=20

=00       00000000 00000000 00000001 00000000 dea45aa0 00000010 00000000 =
ce8a2dc0=20

=00       000f431b dea45c08 00000000 7fffffff 00000004 00000000 c03d9c2a =
c018c29c=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c018c29c>] __pollwait+0x8c/0xd0

=00 [<c03896dd>] tcp_poll+0x2d/0x190

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c01962ef>] clear_inode+0x5f/0xf0

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00rpc.statd     S C04FE040  6472  1831      1          1834  1825 (NOTLB=
)

=00de457e80 00000082 dea45000 c04fe040 00000000 00000001 00000000 dea4500=
0=20

=00       00000010 c044a61c 00000000 00000000 00000246 de47fe80 00022e09 =
3dd07080=20

=00       000f4205 dea45168 00000000 7fffffff 00000007 00000000 c03d9c2a =
c03503eb=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c03503eb>] datagram_poll+0x2b/0xd0

=00 [<c03896dd>] tcp_poll+0x2d/0x190

=00 [<c034a0d2>] sys_recvfrom+0x102/0x120

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c011860d>] scheduler_tick+0xfd/0x3f0

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c010597b>] do_IRQ+0x3b/0x70

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00ntpd          S C04FE040  6492  1834      1          1839  1831 (NOTLB=
)

=00de4f9e80 00000082 de47eaa0 c04fe040 00000000 00000001 00000000 de47eaa=
0=20

=00       00000010 c044a61c 00000000 bffffa10 00000246 dfa50980 00000000 =
24284980=20

=00       000f4329 de47ec08 00000000 7fffffff 00000009 00000000 c03d9c2a =
c03503eb=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c03503eb>] datagram_poll+0x2b/0xd0

=00 [<c03a6ae2>] udp_poll+0x22/0x230

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c0103919>] do_signal+0xc9/0x130

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00atd           S C04FE040  6576  1839      1          1842  1834 (NOTLB=
)

=00de5cbf30 00000082 de47e550 c04fe040 c011614c df84e080 dfbad074 0000000=
0=20

=00       c04485a0 00000246 c04485a0 de5cbf44 de5cbfc4 00000000 00000000 =
40420cc0=20

=00       000f4205 de47e6b8 00331700 de5cbf44 000f41a7 00000e10 c03d9bde =
de5cbf44=20

=00Call Trace:

=00 [<c011614c>] do_page_fault+0x1bc/0x5e9

=00 [<c03d9bde>] schedule_timeout+0x8e/0xe0

=00 [<c012a490>] process_timeout+0x0/0x10

=00 [<c012a58e>] sys_nanosleep+0xde/0x170

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00cron          S C04FE040  6712  1842      1          1848  1839 (NOTLB=
)

=00de66df30 00000082 de47e000 c04fe040 00000060 00000803 00000000 0000000=
0=20

=00       c04485a0 00000246 c04485a0 de66df44 00000000 00000000 00000000 =
e0704e80=20

=00       000f4324 de47e168 000fea55 de66df44 000f41a7 0000003c c03d9bde =
de66df44=20

=00Call Trace:

=00 [<c03d9bde>] schedule_timeout+0x8e/0xe0

=00 [<c012a490>] process_timeout+0x0/0x10

=00 [<c012a58e>] sys_nanosleep+0xde/0x170

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00getty         S C04FE040  6608  1848      1          1849  1842 (NOTLB=
)

=00df85de4c 00000082 df850aa0 c04fe040 00000000 00000001 0000001c 0000000=
0=20

=00       de6f2a30 00000000 00000008 00000202 00000203 00000207 00000000 =
836eb480=20

=00       000f4205 df850c08 de684000 7fffffff 7fffffff 00000000 c03d9c2a =
00001961=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c025af9d>] vgacon_cursor+0x16d/0x400

=00 [<c0299cfa>] set_cursor+0x6a/0x90

=00 [<c02917ab>] read_chan+0xd0b/0xe40

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c02893c3>] tty_write+0xb3/0x280

=00 [<c02892ec>] tty_read+0xec/0x110

=00 [<c017219e>] vfs_read+0xae/0x130

=00 [<c0172491>] sys_read+0x51/0x80

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00getty         S C04FE040  6980  1849      1          1850  1848 (NOTLB=
)

=00df85fe4c 00000082 df850550 c04fe040 00000000 00000001 0000001c 0000000=
0=20

=00       de6f2a30 00000000 00000008 00000202 00000203 00000034 00000000 =
8519f380=20

=00       000f4205 df8506b8 de689000 7fffffff 7fffffff 00000000 c03d9c2a =
00000008=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c029cc76>] do_con_write+0x266/0x680

=00 [<c011e2da>] acquire_console_sem+0x2a/0x50

=00 [<c02917ab>] read_chan+0xd0b/0xe40

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c02893c3>] tty_write+0xb3/0x280

=00 [<c02892ec>] tty_read+0xec/0x110

=00 [<c017219e>] vfs_read+0xae/0x130

=00 [<c0172491>] sys_read+0x51/0x80

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00getty         S C04FE040  6980  1850      1          1851  1849 (NOTLB=
)

=00deae5e4c 00000082 dea45550 c04fe040 00000000 00000001 0000001c 0000000=
0=20

=00       de6f2a30 00000000 00000008 00000202 00000203 00000034 00000000 =
8556fc80=20

=00       000f4205 dea456b8 de68f000 7fffffff 7fffffff 00000000 c03d9c2a =
00000008=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c029cc76>] do_con_write+0x266/0x680

=00 [<c011e2da>] acquire_console_sem+0x2a/0x50

=00 [<c02917ab>] read_chan+0xd0b/0xe40

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c02893c3>] tty_write+0xb3/0x280

=00 [<c02892ec>] tty_read+0xec/0x110

=00 [<c017219e>] vfs_read+0xae/0x130

=00 [<c0172491>] sys_read+0x51/0x80

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00getty         S C04FE500  6576  1851      1          1852  1850 (NOTLB=
)

=00de67fe4c 00000082 de647550 c04fe500 000f4205 00000001 0000001c 0000000=
0=20

=00       de6f2a30 00000000 00000008 85940580 000f4205 de647550 00000000 =
85940580=20

=00       000f4205 de647c08 de688000 7fffffff 7fffffff 00000000 c03d9c2a =
00000008=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c029cc76>] do_con_write+0x266/0x680

=00 [<c011e2da>] acquire_console_sem+0x2a/0x50

=00 [<c02917ab>] read_chan+0xd0b/0xe40

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c02893c3>] tty_write+0xb3/0x280

=00 [<c02892ec>] tty_read+0xec/0x110

=00 [<c017219e>] vfs_read+0xae/0x130

=00 [<c0172491>] sys_read+0x51/0x80

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00getty         S C04FE040  6980  1852      1          1853  1851 (NOTLB=
)

=00de50be4c 00000082 de647550 c04fe040 00000000 00000001 0000001c 0000000=
0=20

=00       de6f2a30 00000000 00000008 00000202 00000203 00000034 00000000 =
85940580=20

=00       000f4205 de6476b8 de6a5000 7fffffff 7fffffff 00000000 c03d9c2a =
00000008=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c029cc76>] do_con_write+0x266/0x680

=00 [<c011e2da>] acquire_console_sem+0x2a/0x50

=00 [<c02917ab>] read_chan+0xd0b/0xe40

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c02893c3>] tty_write+0xb3/0x280

=00 [<c02892ec>] tty_read+0xec/0x110

=00 [<c017219e>] vfs_read+0xae/0x130

=00 [<c0172491>] sys_read+0x51/0x80

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00getty         S C04FE040  6980  1853      1          1854  1852 (NOTLB=
)

=00de5c3e4c 00000082 de647000 c04fe040 00000000 00000001 0000001c 0000000=
0=20

=00       de6f2a30 00000000 00000008 00000202 00000203 00000034 00000000 =
863bde40=20

=00       000f4205 de647168 de6ba000 7fffffff 7fffffff 00000000 c03d9c2a =
00000008=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c029cc76>] do_con_write+0x266/0x680

=00 [<c011e2da>] acquire_console_sem+0x2a/0x50

=00 [<c02917ab>] read_chan+0xd0b/0xe40

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c02893c3>] tty_write+0xb3/0x280

=00 [<c02892ec>] tty_read+0xec/0x110

=00 [<c017219e>] vfs_read+0xae/0x130

=00 [<c0172491>] sys_read+0x51/0x80

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00getty         S C04FE040  6964  1854      1                1853 (NOTLB=
)

=00de667e4c 00000082 de643aa0 c04fe040 00100100 00200200 fffc2af7 1d244b3=
c=20

=00       00000000 00000005 c03eed36 00000202 00000203 00000034 00000000 =
86976bc0=20

=00       000f4205 de643c08 dfc6a000 7fffffff 7fffffff 00000000 c03d9c2a =
00000001=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c0159b83>] zap_pmd_range+0x53/0x70

=00 [<c02a705c>] uart_write+0x15c/0x1e0

=00 [<c02917ab>] read_chan+0xd0b/0xe40

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c02892ec>] tty_read+0xec/0x110

=00 [<c017219e>] vfs_read+0xae/0x130

=00 [<c0172491>] sys_read+0x51/0x80

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00sshd          S C04FE040  6400  1915   1825  1917    1923       (NOTLB=
)

=00de74de80 00000082 de643000 c04fe040 00000282 00000060 00000246 c0488cf=
8=20

=00       c0488ce0 00000001 00000003 de74de8c 00000086 c0488ce0 00000000 =
2f5bf100=20

=00       000f4327 de643168 00000000 7fffffff 00000008 00000000 c03d9c2a =
de6e6580=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c0291c2c>] normal_poll+0x11c/0x16b

=00 [<c028b309>] tty_poll+0x89/0xc0

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00bash          S C04FE040  6616  1917   1915  1919               (NOTLB=
)

=00de749f1c 00000082 de643550 c04fe040 01200011 df838c80 df838cac de7375f=
4=20

=00       de643550 c011614c df838c80 00000246 080ed208 00000001 00000000 =
77e2f880=20

=00       000f42e4 de6436b8 de6435f0 de643550 fffffe00 de6435f0 c0123157 =
ffffffff=20

=00Call Trace:

=00 [<c011614c>] do_page_fault+0x1bc/0x5e9

=00 [<c0123157>] do_wait+0x197/0x4f0

=00 [<c011f8de>] session_of_pgrp+0x1e/0x90

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c018b7b8>] do_ioctl+0x58/0x80

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c012f92a>] sys_rt_sigprocmask+0xaa/0x2a0

=00 [<c012357d>] sys_wait4+0x3d/0x50

=00 [<c01235b5>] sys_waitpid+0x25/0x29

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00iperf         S C04FE040  6224  1919   1917          1920       (NOTLB=
)

=00de7fde60 00000082 de7fbaa0 c04fe040 dfd465bc 000000a9 000000d0 c0151c9=
5=20

=00       c14dd180 dee72d80 00000001 df838080 00000001 c014833e 00000000 =
7c1e5840=20

=00       000f42e4 de7fbc08 00000000 7fffffff de7fc000 080581a0 c03d9c2a =
08058000=20

=00Call Trace:

=00 [<c0151c95>] cache_grow+0x175/0x350

=00 [<c014833e>] filemap_nopage+0x1ee/0x3b0

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c01600c9>] find_extend_vma+0x29/0x90

=00 [<c013de2f>] queue_me+0x8f/0x1c0

=00 [<c013d2c5>] get_futex_key+0x45/0x360

=00 [<c013e2e1>] futex_wait+0x171/0x1f0

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c013e628>] do_futex+0x48/0xa0

=00 [<c012a490>] process_timeout+0x0/0x10

=00 [<c013e76e>] sys_futex+0xee/0x100

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00iperf         S C04FE040  6756  1920   1917          1921  1919 (NOTLB=
)

=00de12fde8 00000082 de7fb550 c04fe040 de03cc80 00000246 00000018 0000020=
2=20

=00       c044a374 00000000 00000000 000000d0 c014cac3 de7fb000 00000000 =
d0e0d780=20

=00       000f42e5 de7fb6b8 de7fb550 7fffffff de12e000 7fffffff c03d9c2a =
c044a61c=20

=00Call Trace:

=00 [<c014cac3>] __alloc_pages+0x2f3/0x450

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c0151c95>] cache_grow+0x175/0x350

=00 [<c038d4b7>] wait_for_connect+0xe7/0xf0

=00 [<c013cdc0>] autoremove_wake_function+0x0/0x60

=00 [<c03484f9>] sock_alloc_inode+0x19/0xc0

=00 [<c013cdc0>] autoremove_wake_function+0x0/0x60

=00 [<c038d51c>] tcp_accept+0x5c/0x110

=00 [<c0196e6a>] new_inode+0x1a/0x1d0

=00 [<c03acfd5>] inet_accept+0x35/0xc0

=00 [<c0349bd5>] sys_accept+0x95/0x140

=00 [<c011cb59>] do_fork+0x199/0x1ef

=00 [<c0161460>] mprotect_fixup+0x180/0x1e0

=00 [<c02506cc>] copy_from_user+0x6c/0xa0

=00 [<c034a7b5>] sys_socketcall+0xd5/0x260

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00iperf         S C04FE040  6340  1921   1917          1922  1920 (NOTLB=
)

=00de141d30 00000082 de7fb000 c04fe040 dd249054 000005a8 08058370 000005a=
8=20

=00       c025064c 08058370 dd249054 030c10ac 040d10ac c039cf41 00000000 =
397eef00=20

=00       000f4329 de7fb168 de037580 7fffffff 00000000 de141db0 c03d9c2a =
00000000=20

=00Call Trace:

=00 [<c025064c>] copy_to_user+0x6c/0x80

=00 [<c039cf41>] tcp_v4_send_check+0x51/0xf0

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c034d124>] kfree_skbmem+0x24/0x30

=00 [<c034d190>] __kfree_skb+0x60/0xe0

=00 [<c034c11b>] sk_wait_data+0xbb/0xd0

=00 [<c013cdc0>] autoremove_wake_function+0x0/0x60

=00 [<c013cdc0>] autoremove_wake_function+0x0/0x60

=00 [<c038c2b2>] tcp_recvmsg+0x352/0x710

=00 [<c034cbd8>] sock_common_recvmsg+0x58/0x80

=00 [<c0348cf6>] sock_aio_read+0xf6/0x110

=00 [<c01720b7>] do_sync_read+0xb7/0xf0

=00 [<c02893c3>] tty_write+0xb3/0x280

=00 [<c013cdc0>] autoremove_wake_function+0x0/0x60

=00 [<c02918e0>] write_chan+0x0/0x230

=00 [<c0172208>] vfs_read+0x118/0x130

=00 [<c0172491>] sys_read+0x51/0x80

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00iperf         S C04FE040  7612  1922   1917                1921 (NOTLB=
)

=00de143e60 00000082 de045aa0 c04fe040 00000000 00000000 00000000 0000000=
0=20

=00       00000000 00000000 00000000 00000000 00000000 00000000 00000000 =
d0f019c0=20

=00       000f42e5 de045c08 00000000 7fffffff de142000 08062420 c03d9c2a =
08062000=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c01600c9>] find_extend_vma+0x29/0x90

=00 [<c013de2f>] queue_me+0x8f/0x1c0

=00 [<c013d2c5>] get_futex_key+0x45/0x360

=00 [<c013e2e1>] futex_wait+0x171/0x1f0

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c0118900>] default_wake_function+0x0/0x20

=00 [<c013e628>] do_futex+0x48/0xa0

=00 [<c013e76e>] sys_futex+0xee/0x100

=00 [<c011812e>] schedule_tail+0x1e/0x70

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00sshd          S C04FE088  6736  1923   1825  1925          1915 (NOTLB=
)

=00ddb57e80 00000082 de045550 c04fe088 000f4329 00000030 00000246 c0488cf=
8=20

=00       c0488ce0 00000001 00000003 3fdf9fc0 000f4329 de045550 00000000 =
3fdf9fc0=20

=00       000f4329 de045168 00000000 7fffffff 00000008 00000000 c03d9c2a =
de01e180=20

=00Call Trace:

=00 [<c03d9c2a>] schedule_timeout+0xda/0xe0

=00 [<c0291c2c>] normal_poll+0x11c/0x16b

=00 [<c028b309>] tty_poll+0x89/0xc0

=00 [<c03493b9>] sock_poll+0x29/0x40

=00 [<c018c66a>] do_select+0x28a/0x470

=00 [<c018c210>] __pollwait+0x0/0xd0

=00 [<c018cb6b>] sys_select+0x2db/0x5b0

=00 [<c0103ab3>] syscall_call+0x7/0xb

=00bash          R running  6892  1925   1923                     (NOTLB)=


=00SysRq : Show Regs


--------------070500030203030802020608--
