From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4223] New: sis900 kernel oop at boot
Date: Thu, 17 Feb 2005 13:44:40 -0800
Message-ID: <20050217134440.44f591e2.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Thu, 17 Feb 2005 10:39:03 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4223] New: sis900 kernel oop at boot


http://bugme.osdl.org/show_bug.cgi?id=4223

           Summary: sis900 kernel oop at boot
    Kernel Version: 2.6.10
            Status: NEW
          Severity: low
             Owner: acme@conectiva.com.br
         Submitter: mangus@deprecated.it


Distribution: Slackware 10.1 
Hardware Environment: 
Software Environment: 
Problem Description: 
kernel oop at boot time , it happens once for now. 
 
Steps to reproduce:  
don't know.. 
here is the trace 
Feb 15 18:26:20 saturno kernel: Unable to handle kernel NULL pointer 
dereference at virtual address 0000000e 
Feb 15 18:26:20 saturno kernel:  printing eip: 
Feb 15 18:26:20 saturno kernel: e1113417 
Feb 15 18:26:20 saturno kernel: *pde = 00000000 
Feb 15 18:26:20 saturno kernel: Oops: 0000 [#1] 
Feb 15 18:26:20 saturno kernel: PREEMPT 
Feb 15 18:26:20 saturno kernel: Modules linked in: sis900 nvidia 8250_pci 8250 
serial_core psmouse 
Feb 15 18:26:20 saturno kernel: CPU:    0 
Feb 15 18:26:20 saturno kernel: EIP:    0060:[<e1113417>]    Tainted: P 
VLI 
Feb 15 18:26:20 saturno kernel: EFLAGS: 00010296   (2.6.10-M7) 
Feb 15 18:26:20 saturno kernel: EIP is at sis900_check_mode+0x17/0xa0 [sis900] 
Feb 15 18:26:20 saturno kernel: eax: 00000000   ebx: dfd38000   ecx: 10501010 
edx: 0000ec18 
Feb 15 18:26:20 saturno kernel: esi: 00000000   edi: 0000ec00   ebp: dfd38220 
esp: deaede88 
Feb 15 18:26:20 saturno kernel: ds: 007b   es: 007b   ss: 0068 
Feb 15 18:26:20 saturno kernel: Process ifconfig (pid: 1145, 
threadinfo=deaec000 task=c16fe020) 
Feb 15 18:26:20 saturno kernel: Stack: 00000000 00000000 00000000 00000001 
dfd38000 0000ec00 e1112cc9 dfd38000 
Feb 15 18:26:20 saturno kernel:        00000000 00000001 dfd38000 dfd38000 
9100007b dfd38000 00000000 00001043 
Feb 15 18:26:20 saturno kernel:        00000000 c027c435 dfd38000 dabe1540 
c0280314 dfd38000 00001002 c027d9d3 
Feb 15 18:26:20 saturno kernel: Call Trace: 
Feb 15 18:26:20 saturno kernel:  [<e1112cc9>] sis900_open+0xe9/0x130 [sis900] 
Feb 15 18:26:20 saturno kernel:  [<c027c435>] dev_open+0x85/0xa0 
Feb 15 18:26:20 saturno kernel:  [<c0280314>] dev_mc_upload+0x24/0x50 
Feb 15 18:26:20 saturno kernel:  [<c027d9d3>] dev_change_flags+0x53/0x130 
Feb 15 18:26:20 saturno kernel:  [<c027c305>] dev_load+0x25/0x70 
Feb 15 18:26:20 saturno kernel:  [<c02b7be7>] devinet_ioctl+0x257/0x5d0 
Feb 15 18:26:20 saturno kernel:  [<c02ba146>] inet_ioctl+0x66/0xb0 
Feb 15 18:26:20 saturno kernel:  [<c02734d9>] sock_ioctl+0xc9/0x240 
Feb 15 18:26:20 saturno kernel:  [<c015fc6a>] sys_ioctl+0xca/0x230 
Feb 15 18:26:20 saturno kernel:  [<c01026c7>] syscall_call+0x7/0xb 
Feb 15 18:26:20 saturno kernel: Code: df e9 2d ff ff ff 8d b4 26 00 00 00 00 
8d bc 27 00 00 00 00 83 ec 18 89 74 24 10 8b 74 24 20 89 5c 24 0c 8b 5c 24 1c 
89 7c 24 14 <80> 7e 0e 02 8b 7b 68 8b 4b 18 74 3d 8d 51 04 ed 83 c8 10 ef 89 
Feb 15 18:26:20 saturno kernel:  <6>eth0: Using transceiver found at address 1 
as default 
Feb 15 18:27:25 saturno portmap[2561]: cannot bind udp: Address already in use

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
