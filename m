From: "Francois Baligant" <francois@baligant.net>
Subject: Kernel panic 2.6.0-test11 in release_sock
Date: Sun, 30 Nov 2003 22:15:10 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <054201c3b787$0cb93c40$15fea8c0@fortress>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="----=_NextPart_000_053F_01C3B78F.6B19B8C0"
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format...

------=_NextPart_000_053F_01C3B78F.6B19B8C0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

If it helps, box is running a epoll syscalls enabled application and handli=
ng a fair share
of connected sockets.

ksymoops 2.4.9 on i686 2.6.0-test11-mjb1.  Options used
     -V (default)
     -k /proc/ksyms (default)
     -l /proc/modules (default)
     -o /lib/modules/2.6.0-test11-mjb1/ (default)
     -m /usr/src/linux/System.map (default)

Warning: You did not tell me where to find symbol information.  I will
assume that the log matches the kernel and modules that are running
right now and I'll use the default options above for symbol resolution.
If the current kernel and/or modules do not match the log, you can get
more accurate output by telling me the kernel version and where to find
map, modules, ksyms etc.  ksymoops -h explains the options.

Error (regular_file): read_ksyms stat /proc/ksyms failed
ksymoops: No such file or directory
No modules in ksyms, skipping objects
No ksyms, skipping lsmod
Unable to handle kernel NULL pointer dereference at virtual address 00000000
837a8e0a
*pde =3D 00000000
Oops: 0002 [#1]
CPU:    0
EIP:    0060:[<837a8e0a>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010206
eax: 00000000   ebx: ca2afd44   ecx: 837a766c   edx: 41a54000
esi: cd4ec600   edi: 0b07ebdf   ebp: 00000040   esp: ca2afd2c
ds: 007b   es: 007b   ss: 0068
Stack: 00000000 f8819080 f88119c0 f6bd2800 00000001 d0c12840 00000000 ca2af=
dcc=20
       803c5fa8 80000000 8030da88 00000000 b3cb9380 00000002 8025f63b b3cb9=
380=20
       f8813b40 00000000 8025217d 00000001 ca2afdfc f6bd2800 00000000 8025f=
560=20
Call Trace:
 [<8025f63b>] ip_local_deliver_finish+0xdb/0x1a0
 [<8025217d>] nf_iterate+0x3d/0xa0
 [<8025f560>] ip_local_deliver_finish+0x0/0x1a0
 [<80288f7d>] inet_sendmsg+0x3d/0x50
 [<80240f02>] sock_sendmsg+0x82/0xa0
 [<8010c99e>] handle_IRQ_event+0x3e/0x70
 [<801257eb>] do_softirq+0x6b/0xd0
 [<8010cd2f>] do_IRQ+0x10f/0x120
 [<8010b3e0>] common_interrupt+0x18/0x20
 [<80240d28>] sockfd_lookup+0x28/0x70
 [<80240d11>] sockfd_lookup+0x11/0x70
 [<80242100>] sys_sendto+0xd0/0xf0
 [<80275e22>] tcp_send_ack+0xc2/0xd0
 [<f88216ce>] e100_rx_srv+0x4be/0x520 [e100]
 [<80248e7d>] netif_receive_skb+0x1dd/0x220
 [<80131a73>] rcu_process_callbacks+0x163/0x170
 [<802446b8>] kfree_skbmem+0x18/0x20
 [<8024213d>] sys_send+0x1d/0x30
 [<80242961>] sys_socketcall+0x161/0x250
 [<8010cd2f>] do_IRQ+0x10f/0x120
 [<8010aa73>] syscall_call+0x7/0xb
Code: 7a 83 fc 8c 7a 83 40 00 00 00 40 00 00 00 00 00 00 00 00 00=20


>>EIP; 837a8e0a <__crc___release_sock+15aeb5/47c4ae>   <=3D=3D=3D=3D=3D

>>ebx; ca2afd44 <__crc_skb_copy_datagram_iovec+30f1af/5d1d75>
>>ecx; 837a766c <__crc___release_sock+159717/47c4ae>
>>edx; 41a54000 <__crc_pci_request_region+134a3f/2126d1>
>>esi; cd4ec600 <__crc_mb_cache_entry_get+36fb25/40fd55>
>>edi; 0b07ebdf <__crc_blk_queue_invalidate_tags+67c46/17d2da>
>>esp; ca2afd2c <__crc_skb_copy_datagram_iovec+30f197/5d1d75>

Trace; 8025f63b <ip_local_deliver_finish+db/1a0>
Trace; 8025217d <nf_iterate+3d/a0>
Trace; 8025f560 <ip_local_deliver_finish+0/1a0>
Trace; 80288f7d <inet_sendmsg+3d/50>
Trace; 80240f02 <sock_sendmsg+82/a0>
Trace; 8010c99e <handle_IRQ_event+3e/70>
Trace; 801257eb <do_softirq+6b/d0>
Trace; 8010cd2f <do_IRQ+10f/120>
Trace; 8010b3e0 <common_interrupt+18/20>
Trace; 80240d28 <sockfd_lookup+28/70>
Trace; 80240d11 <sockfd_lookup+11/70>
Trace; 80242100 <sys_sendto+d0/f0>
Trace; 80275e22 <tcp_send_ack+c2/d0>
Trace; f88216ce <__crc_utf8_wctomb+5305c5/61ed76>
Trace; 80248e7d <netif_receive_skb+1dd/220>
Trace; 80131a73 <rcu_process_callbacks+163/170>
Trace; 802446b8 <kfree_skbmem+18/20>
Trace; 8024213d <sys_send+1d/30>
Trace; 80242961 <sys_socketcall+161/250>
Trace; 8010cd2f <do_IRQ+10f/120>
Trace; 8010aa73 <syscall_call+7/b>

Code;  837a8e0a <__crc___release_sock+15aeb5/47c4ae>
00000000 <_EIP>:
Code;  837a8e0a <__crc___release_sock+15aeb5/47c4ae>   <=3D=3D=3D=3D=3D
   0:   7a 83                     jp     ffffff85 <_EIP+0xffffff85> 837a8d8=
f <__crc___release_sock+15ae3a/47c4ae>   <=3D=3D=3D=3D=3D
Code;  837a8e0c <__crc___release_sock+15aeb7/47c4ae>
   2:   fc                        cld=20=20=20=20
Code;  837a8e0d <__crc___release_sock+15aeb8/47c4ae>
   3:   8c 7a 83                  movl   %?,0xffffff83(%edx)
Code;  837a8e10 <__crc___release_sock+15aebb/47c4ae>
   6:   40                        inc    %eax
Code;  837a8e11 <__crc___release_sock+15aebc/47c4ae>
   7:   00 00                     add    %al,(%eax)
Code;  837a8e13 <__crc___release_sock+15aebe/47c4ae>
   9:   00 40 00                  add    %al,0x0(%eax)

 <0>Kernel panic: Fatal exception in interrupt

1 warning and 1 error issued.  Results may not be reliable.

Francois Baligant - http://www.pingouin.be
Change the numbers, change your Life!
------=_NextPart_000_053F_01C3B78F.6B19B8C0--
