From: maximilian attems <maks@sternwelten.at>
Subject: Bug#341392: (fwd) Bug#341392: linux-2.6: kernel BUG at mm/slab.c:1807!
Date: Mon, 5 Dec 2005 15:57:05 +0100
Message-ID: <20051205145705.GA18360@sputnik.stro.at>
Reply-To: maximilian attems <maks@sternwelten.at>,
	341392@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 341392@bugs.debian.org, Frans Pop <aragorn@tiscali.nl>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.341392.B341392.113379462932576@bugs.debian.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

please take a look at belows BUG_ON()
at a quick glance didn't find a patch for that in git-commits-list.
belows kernel has all fixes from the latest 2.6.14.3 stable.


----- Forwarded message from Frans Pop <aragorn@tiscali.nl> -----

Subject: Bug#341392: linux-2.6: kernel BUG at mm/slab.c:1807!
Date: Wed, 30 Nov 2005 13:14:02 +0100
From: Frans Pop <aragorn@tiscali.nl>
To: submit@bugs.debian.org

Package: linux-2.6
Version: 2.6.14-4
Severity: serious

The following error happens on Debian Installer boot in vmware (386 kernel).
This problem was not present in -3.

The system does come up after the error, but it looks so basic (memory
management AFAICT) that I've set RC severity anyway.
Feel free to adjust if you disagree.

Cheers,
FJP

ACPI: Processor [CPU0] (supports 8 throttling states)
kmem_cache_create: duplicate cache UNIX
------------[ cut here ]------------
kernel BUG at mm/slab.c:1807!
invalid operand: 0000 [#1]
Modules linked in: unix thermal processor fan pcnet32 mii uhci_hcd usbcore
CPU:    0
EIP:    0060:[<c013c552>]    Not tainted VLI
EFLAGS: 00010202   (2.6.14-2-386)
EIP is at kmem_cache_create+0x4ea/0x64c
eax: 0000002b   ebx: c9c26b4c   ecx: c02f8080   edx: 0000206b
esi: c0303829   edi: ca86fde9   ebp: c9c26980   esp: c988ff38
ds: 007b   es: 007b   ss: 0068
Process modprobe (pid: 1605, threadinfo=c988e000 task=c98c8a70)
Stack: c02ba8f8 ca86fde4 0000000a c9a957a0 c9c2699c ffffff80 00000080 c0000000
       00000080 ca870080 ca86fd60 0804e154 ca86fde4 c02410d2 ca86fde4 0000015c
       00000000 00002000 00000000 00000000 ca804000 ca870080 0804e190 0804e154
Call Trace:
 [<c02410d2>] proto_register+0x56/0x1b4
 [<ca804000>] af_unix_init+0x0/0x5f [unix]
 [<ca80400d>] af_unix_init+0xd/0x5f [unix]
 [<c012e8a1>] sys_init_module+0x99/0x16c
 [<c01030dd>] syscall_call+0x7/0xb
Code: c9 fc ff ff 55 e8 0f 0e 00 00 59 e9 a9 fd ff ff 90 ff 74 24 30 68 f8 a8 2b c0 e8 6e b3
 fd ff ff 05 4c 16 39 c0 0f 8e cb 15 00 00 <0f> 0b 0f 07 0d a0 2b c0 58 5a e9 d7 fd ff ff b8
 00 e0 ff ff 21
 <6>usbcore: registered new driver usbkbd
drivers/usb/input/usbkbd.c: :USB HID Boot Protocol keyboard driver
usbcore: registered new driver hiddev
usbcore: registered new driver usbhid



----- End forwarded message -----
