From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: APIC error on 32-bit kernel
Date: Mon, 09 Apr 2007 14:04:54 -0500
Message-ID: <461A8E56.6020002@bellsouth.net>
References: <20070323200817.1f3e39b9@osprey.hogchain.net> <20070408133822.3868e6ff@osprey.hogchain.net> <461A7F14.1080105@redhat.com>
Reply-To: jacliburn@bellsouth.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmx2.usace.army.mil ([140.194.245.34]:26146 "EHLO
	cmx2.usace.army.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965105AbXDITTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 15:19:07 -0400
In-Reply-To: <461A7F14.1080105@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chuck Ebbert wrote:

> Where is the text of the oops?

In one of the files on the website I referenced.  Here's the text...

[  173.584000] APIC error on CPU1: 08(08)
[  173.665000] APIC error on CPU0: 08(08)
[  173.665000] APIC error on CPU1: 08(08)
[  173.746000] APIC error on CPU0: 08(08)
[  173.746000] APIC error on CPU1: 08(08)
[  173.827000] APIC error on CPU0: 08(08)
[  173.827000] APIC error on CPU1: 08(08)
[  173.908000] APIC error on CPU0: 08(08)
[  173.908000] APIC error on CPU1: 08(08)
[  173.989000] APIC error on CPU0: 08(08)
[  173.989000] APIC error on CPU1: 08(08)

pinged my router somewhere along about here...

[  174.069000] BUG: unable to handle kernel NULL pointer 
dereference<1>BUG: unable to 0
[  174.069000]  printing eip:
[  174.069000] 00000000
[  174.069000] *pde = 1feb8067
[  174.069000] Oops: 0000 [#1]
[  174.069000] SMP
[  174.069000] Modules linked in: nf_conntrack_netbios_ns ipt_REJECT 
nf_conntrack_ipv4d
[  174.069000] CPU:    1
[  174.069000] EIP:    0060:[<00000000>]    Not tainted VLI
[  174.069000] EFLAGS: 00010006   (2.6.21-rc5-git1 #1)
[  174.069000] EIP is at 0x0
[  174.069000] eax: 000000a0   ebx: dfe99f98   ecx: c07bb000   edx: c074de00
[  174.069000] esi: 000000a0   edi: 00000000   ebp: 00000000   esp: c07bbffc
[  174.069000] ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
[  174.069000] Process beagled-helper (pid: 3393, ti=c07bb000 
task=dfe28270 task.ti=df)
[  174.069000] Stack: c040704b
[  174.069000] Call Trace:
[  174.069000]  [<c040704b>] do_IRQ+0xac/0xd1
[  174.069000]  [<c040580e>] common_interrupt+0x2e/0x34
[  174.069000]  =======================
[  174.069000] Code:  Bad EIP value.
[  174.069000] EIP: [<00000000>] 0x0 SS:ESP 0068:c07bbffc
[  174.069000] Kernel panic - not syncing: Fatal exception in interrupt
[  174.069000] BUG: at arch/i386/kernel/smp.c:546 smp_call_function()
[  174.069000]  [<c0417b4f>] smp_call_function+0x5c/0xc8
[  174.069000]  [<c054052e>] do_unblank_screen+0x2a/0x120
[  174.069000]  [<c0417bd6>] smp_send_stop+0x1b/0x2e
[  174.069000]  [<c04271ca>] panic+0x54/0xf2
[  174.069000]  [<c04062c5>] die+0x1f8/0x22c
[  174.069000]  [<c0623d13>] do_page_fault+0x40c/0x4df
[  174.069000]  [<c0623907>] do_page_fault+0x0/0x4df
[  174.069000]  [<c0622574>] error_code+0x7c/0x84
[  174.069000]  [<c040704b>] do_IRQ+0xac/0xd1
[  174.069000]  [<c040580e>] common_interrupt+0x2e/0x34
[  174.069000]  =======================
[  174.069000]  at virtual address 00000000
[  174.069000]  printing eip:
[  174.069000] 00000000
[  174.069000] *pde = 20bd3067
[  174.069000] Oops: 0000 [#2]
[  174.069000] SMP
[  174.069000] Modules linked in: nf_conntrack_netbios_ns ipt_REJECT 
nf_conntrack_ipv4d
[  174.069000] CPU:    0
[  174.069000] EIP:    0060:[<00000000>]    Not tainted VLI
[  174.069000] EFLAGS: 00010087   (2.6.21-rc5-git1 #1)
[  174.069000] EIP is at 0x0
[  174.069000] eax: 000000a0   ebx: c0753f74   ecx: c07ba000   edx: c074de00
[  174.069000] esi: 000000a0   edi: 00000000   ebp: 00000000   esp: c07baffc
[  174.069000] ds: 007b   es: 007b   fs: 00d8  gs: 0000  ss: 0068
[  174.069000] Process swapper (pid: 0, ti=c07ba000 task=c07094c0 
task.ti=c0753000)
[  174.069000] Stack: c040704b
[  174.069000] Call Trace:
[  174.069000]  [<c040704b>] do_IRQ+0xac/0xd1
[  174.069000]  [<c040580e>] common_interrupt+0x2e/0x34
[  174.069000]  [<c0403c74>] default_idle+0x3d/0x54
[  174.069000]  [<c040339b>] cpu_idle+0xa3/0xbc
[  174.069000]  [<c0758a37>] start_kernel+0x45d/0x465
[  174.069000]  [<c07581ae>] unknown_bootoption+0x0/0x202
[  174.069000]  =======================
[  174.069000] Code:  Bad EIP value.
[  174.069000] EIP: [<00000000>] 0x0 SS:ESP 0068:c07baffc
[  174.069000] Kernel panic - not syncing: Fatal exception in interrupt

Short hang, then spontaneous reboot.


