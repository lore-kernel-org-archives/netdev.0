From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [Fwd: [Bug 1692] New: System do a kernel panic in ip_push_pending_frames]
Date: Wed, 17 Dec 2003 12:58:14 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FE0C366.1080208@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm helping Martin and OSDL BUGME admins out with
handling the networking bugs. Hope to save Andrew
some cycles tracking these..

Any ideas?

thanks,
Nivedita

-------- Original Message --------
Subject: [Bug 1692] New: System do a kernel panic in ip_push_pending_frames
Date: Wed, 17 Dec 2003 12:05:33 -0800
From: bugme-daemon@osdl.org
To: niv@us.ibm.com

http://bugme.osdl.org/show_bug.cgi?id=1692

            Summary: System do a kernel panic in ip_push_pending_frames
     Kernel Version: 2.6.0-test11
             Status: NEW
           Severity: normal
              Owner: niv@us.ibm.com
          Submitter: jean-michel@kelbert.com


Distribution: Debian unstable
Hardware Environment: Athlon 900 512 SDRAM
Software Environment: Debian unstable with kernel 2.6.0-test11
Problem Description:
My system crash unexpectly with the following message :

Dec 17 10:44:47 mars postfix/smtpd[25921]: connect from
mars.ephaone.org[192.168.0.1]
Dec 17 10:44:47 mars postfix/smtpd[25921]: disconnect from
mars.ephaone.org[192.168.0.1]
Dec 17 10:45:25 mars kernel: Shorewall:newnotsyn:DROP:IN=eth1 OUT=
MAC=00:e0:7d:81:0d:8d:00:07:cb:01:b7:23:08:00 SRC=81.56.36.190
DST=81.56.115.55 LEN=40 TOS=0x00 PREC=0x00 TTL=122 ID=31230 PROTO=TCP SPT=1025
DPT=1621 WINDOW=0 RES=0x00 ACK RST URGP=0
Dec 17 10:45:44 mars kernel: Shorewall:newnotsyn:DROP:IN=eth1 OUT=
MAC=00:e0:7d:81:0d:8d:00:07:cb:01:b7:23:08:00 SRC=81.56.36.190
DST=81.56.115.55 LEN=40 TOS=0x00 PREC=0x00 TTL=122 ID=32855 PROTO=TCP SPT=1025
DPT=1491 WINDOW=0 RES=0x00 ACK RST URGP=0
Dec 17 10:47:47 mars postfix/smtpd[25956]: connect from
mars.ephaone.org[192.168.0.1]
Dec 17 10:47:47 mars postfix/smtpd[25956]: disconnect from
mars.ephaone.org[192.168.0.1]
Dec 17 10:47:57 mars kernel: Unable to handle kernel NULL pointer dereference
at virtual address 00000000
Dec 17 10:47:57 mars kernel:  printing eip:
Dec 17 10:47:57 mars kernel: c011b9ff
Dec 17 10:47:57 mars kernel: *pde = 00000000
Dec 17 10:47:57 mars kernel: Oops: 0002 [#1]
Dec 17 10:47:57 mars kernel: CPU:    0
Dec 17 10:47:57 mars kernel: EIP:    0060:[schedule+239/1392]    Not tainted
Dec 17 10:47:57 mars kernel: EFLAGS: 00010097
Dec 17 10:47:57 mars kernel: EIP is at schedule+0xef/0x570
Dec 17 10:47:57 mars kernel: eax: 00000001   ebx: 00000000   ecx: d9ae3360
edx: d9ae3360
Dec 17 10:47:57 mars kernel: esi: d9ae3360   edi: d5d1bd28   ebp: d5d1bcc8
esp: d5d1bc8c
Dec 17 10:47:57 mars kernel: ds: 007b   es: 007b   ss: 0068
Dec 17 10:47:57 mars kernel: Process ping (pid: 25966, threadinfo=d5d1a000
task=d9ae3360)
Dec 17 10:47:57 mars kernel: Stack: 00000040 ddcda480 d1bc1964 c0323222
c151d8c0 00000003 ddcda480 dd050040
Dec 17 10:47:57 mars kernel:        00000875 2540d65e 00002ff5 d9ae3360
00000000 7fffffff d5d1bd28 d5d1bd68
Dec 17 10:47:57 mars kernel:        c0127885 00000000 d5d1a000 c033f228
d1bc1840 c03222b0 d5d1beb8 00000000
Dec 17 10:47:57 mars kernel: Call Trace:
Dec 17 10:47:57 mars kernel:  [ip_push_pending_frames+914/1024]
ip_push_pending_frames+0x392/0x400
Dec 17 10:47:57 mars kernel:  [schedule_timeout+181/192] schedule_timeout
+0xb5/0xc0
Dec 17 10:47:57 mars kernel:  [raw_sendmsg+872/1392] raw_sendmsg+0x368/0x570
Dec 17 10:47:57 mars kernel:  [ip_generic_getfrag+0/192] ip_generic_getfrag
+0x0/0xc0
Dec 17 10:47:57 mars kernel:  [wait_for_packet+183/272] wait_for_packet
+0xb7/0x110
Dec 17 10:47:57 mars kernel:  [autoremove_wake_function+0/80]
autoremove_wake_function+0x0/0x50
Dec 17 10:47:57 mars kernel:  [autoremove_wake_function+0/80]
autoremove_wake_function+0x0/0x50
Dec 17 10:47:57 mars kernel:  [skb_recv_datagram+147/240] skb_recv_datagram
+0x93/0xf0
Dec 17 10:47:57 mars kernel:  [raw_recvmsg+115/384] raw_recvmsg+0x73/0x180
Dec 17 10:47:57 mars kernel:  [inet_recvmsg+90/128] inet_recvmsg+0x5a/0x80
Dec 17 10:47:57 mars kernel:  [sock_recvmsg+156/192] sock_recvmsg+0x9c/0xc0
Dec 17 10:47:57 mars kernel:  [filemap_nopage+631/768] filemap_nopage
+0x277/0x300
Dec 17 10:47:57 mars kernel:  [sockfd_lookup+28/128] sockfd_lookup+0x1c/0x80
Dec 17 10:47:57 mars kernel:  [sys_recvfrom+180/288] sys_recvfrom+0xb4/0x120
Dec 17 10:47:57 mars kernel:  [handle_mm_fault+212/368] handle_mm_fault
+0xd4/0x170
Dec 17 10:47:57 mars kernel:  [do_page_fault+812/1292] do_page_fault
+0x32c/0x50c
Dec 17 10:47:57 mars kernel:  [do_mmap_pgoff+1394/1712] do_mmap_pgoff
+0x572/0x6b0
Dec 17 10:47:57 mars kernel:  [sys_socketcall+482/672] sys_socketcall
+0x1e2/0x2a0
Dec 17 10:47:57 mars kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
Dec 17 10:47:57 mars kernel:
Dec 17 10:47:57 mars kernel: Code: ff 0b 8b 4d f0 8b 75 f0 83 c1 20 8b 46 20
8b 51 04 89 50 04
Dec 17 10:47:57 mars kernel:  <6>note: ping[25966] exited with preempt_count 2
Dec 17 10:47:57 mars kernel: bad: scheduling while atomic!
Dec 17 10:47:57 mars kernel: Call Trace:
Dec 17 10:47:57 mars kernel:  [schedule+1373/1392] schedule+0x55d/0x570
Dec 17 10:47:57 mars kernel:  [unmap_page_range+67/112] unmap_page_range
+0x43/0x70
Dec 17 10:47:57 mars kernel:  [unmap_vmas+440/528] unmap_vmas+0x1b8/0x210
Dec 17 10:47:57 mars kernel:  [exit_mmap+123/400] exit_mmap+0x7b/0x190
Dec 17 10:47:57 mars kernel:  [mmput+100/192] mmput+0x64/0xc0
Dec 17 10:47:57 mars kernel:  [do_exit+290/992] do_exit+0x122/0x3e0
Dec 17 10:47:57 mars kernel:  [do_page_fault+0/1292] do_page_fault+0x0/0x50c
Dec 17 10:47:57 mars kernel:  [die+225/240] die+0xe1/0xf0
Dec 17 10:47:57 mars kernel:  [do_page_fault+474/1292] do_page_fault
+0x1da/0x50c
Dec 17 10:47:57 mars kernel:  [ip_finish_output2+0/464] ip_finish_output2
+0x0/0x1d0
Dec 17 10:47:57 mars kernel:  [recalc_task_prio+142/432] recalc_task_prio
+0x8e/0x1b0
Dec 17 10:47:57 mars kernel:  [schedule+761/1392] schedule+0x2f9/0x570
Dec 17 10:47:57 mars kernel:  [do_page_fault+0/1292] do_page_fault+0x0/0x50c
Dec 17 10:47:57 mars kernel:  [error_code+45/56] error_code+0x2d/0x38
Dec 17 10:47:57 mars kernel:  [schedule+239/1392] schedule+0xef/0x570
Dec 17 10:47:57 mars kernel:  [ip_push_pending_frames+914/1024]
ip_push_pending_frames+0x392/0x400
Dec 17 10:47:57 mars kernel:  [schedule_timeout+181/192] schedule_timeout
+0xb5/0xc0
Dec 17 10:47:57 mars kernel:  [raw_sendmsg+872/1392] raw_sendmsg+0x368/0x570
Dec 17 10:47:57 mars kernel:  [ip_generic_getfrag+0/192] ip_generic_getfrag
+0x0/0xc0
Dec 17 10:47:57 mars kernel:  [wait_for_packet+183/272] wait_for_packet
+0xb7/0x110
Dec 17 10:47:57 mars kernel:  [autoremove_wake_function+0/80]
autoremove_wake_function+0x0/0x50
Dec 17 10:47:57 mars kernel:  [autoremove_wake_function+0/80]
autoremove_wake_function+0x0/0x50
Dec 17 10:47:57 mars kernel:  [skb_recv_datagram+147/240] skb_recv_datagram
+0x93/0xf0
Dec 17 10:47:57 mars kernel:  [raw_recvmsg+115/384] raw_recvmsg+0x73/0x180
Dec 17 10:47:57 mars kernel:  [inet_recvmsg+90/128] inet_recvmsg+0x5a/0x80
Dec 17 10:47:57 mars kernel:  [sock_recvmsg+156/192] sock_recvmsg+0x9c/0xc0
Dec 17 10:47:57 mars kernel:  [filemap_nopage+631/768] filemap_nopage
+0x277/0x300
Dec 17 10:47:57 mars kernel:  [sockfd_lookup+28/128] sockfd_lookup+0x1c/0x80
Dec 17 10:47:57 mars kernel:  [sys_recvfrom+180/288] sys_recvfrom+0xb4/0x120
Dec 17 10:47:57 mars kernel:  [handle_mm_fault+212/368] handle_mm_fault
+0xd4/0x170
Dec 17 10:47:57 mars kernel:  [do_page_fault+812/1292] do_page_fault
+0x32c/0x50c
Dec 17 10:47:57 mars kernel:  [do_mmap_pgoff+1394/1712] do_mmap_pgoff
+0x572/0x6b0
Dec 17 10:47:57 mars kernel:  [sys_socketcall+482/672] sys_socketcall
+0x1e2/0x2a0
Dec 17 10:47:57 mars kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
Dec 17 10:47:57 mars kernel:
Dec 17 13:10:18 mars syslogd 1.4.1#13: restart.


Steps to reproduce: I'm sury but I don't know how to reproduce that. My system
ran for 12 hours and then crashed.
