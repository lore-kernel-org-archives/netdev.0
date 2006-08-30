From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 7074] New: Kernel Panic on kernel 2.6.16.1
Date: Tue, 29 Aug 2006 20:30:19 -0700
Message-ID: <20060829203019.c642cb7b.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eshi@anchiva.com.cn,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:13517 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751297AbWH3Dag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 23:30:36 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Obvious question: does it happen with 2.6.17.x or 2.6.18-rc5?


Begin forwarded message:

Date: Tue, 29 Aug 2006 19:49:11 -0700
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 7074] New: Kernel Panic on kernel 2.6.16.1


http://bugzilla.kernel.org/show_bug.cgi?id=7074

           Summary: Kernel Panic on kernel 2.6.16.1
    Kernel Version: 2.6.16.1
            Status: NEW
          Severity: high
             Owner: laforge@gnumonks.org
         Submitter: eshi@anchiva.com.cn


Most recent kernel where this bug did not occur:
Distribution:
Hardware Environment: P4 3.4G   1G Mem
Software Environment: FC3 Kernel 2.6.16.1
Problem Description: 

kernel BUG at net/ipv4/netfilter/ip_conntrack_proto_tcp.c:911!
invalid opcode: 0000 [#1]
SMP
Modules linked in:
CPU:    0
EIP:    0060:[<c036b8bc>]    Not tainted VLI
EFLAGS: 00010246   (2.6.16.1 #1)
EIP is at tcp_packet+0x1dc/0x580
eax: fffffff2   ebx: c0481d44   ecx: 00000028   edx: f5bd0580
esi: 00000014   edi: 00000000   ebp: c0446380   esp: c0481d20
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=c0480000 task=c0405b40)
Stack: <0>f5bd0580 0000003c c0481d44 00000014 e33507c0 f5bd0580 c0368661 
f1e70816
       00001ff7 9575777c c0368d23 c0481d9c 00000282 f5bd0580 c0481d9c c0481e40
       c0446380 f5bd0580 ef0d3358 c0481e40 c0446380 c03699b2 ef0d3358 f5bd0580
Call Trace:
 [<c0368661>] hash_conntrack+0x21/0x30
 [<c0368d23>] __ip_conntrack_find+0x13/0xe0
 [<c03699b2>] ip_conntrack_in+0x202/0x330
 [<c0378700>] ip_recent_ctrl+0x4a0/0x540
 [<c039d6a0>] br_nf_pre_routing_finish+0x0/0x430
 [<c032835d>] nf_iterate+0x5d/0x90
 [<c039d6a0>] br_nf_pre_routing_finish+0x0/0x430
 [<c039d6a0>] br_nf_pre_routing_finish+0x0/0x430
 [<c03283fe>] nf_hook_slow+0x6e/0x130
 [<c039d6a0>] br_nf_pre_routing_finish+0x0/0x430
 [<c0399330>] br_handle_frame_finish+0x0/0x160
 [<c039e412>] br_nf_pre_routing+0x572/0x590
 [<c039d6a0>] br_nf_pre_routing_finish+0x0/0x430
 [<c032835d>] nf_iterate+0x5d/0x90
 [<c0399330>] br_handle_frame_finish+0x0/0x160
 [<c0399330>] br_handle_frame_finish+0x0/0x160
 [<c03283fe>] nf_hook_slow+0x6e/0x130
 [<c0399330>] br_handle_frame_finish+0x0/0x160
 [<c0399688>] br_handle_frame+0x1f8/0x250
 [<c0399330>] br_handle_frame_finish+0x0/0x160
 [<c0316ee4>] netif_receive_skb+0x134/0x270
 [<c03170b2>] process_backlog+0x92/0x120
 [<c03171c3>] net_rx_action+0x83/0x120
 [<c01220a9>] __do_softirq+0x79/0x100
 [<c0122165>] do_softirq+0x35/0x40
 [<c01056ee>] do_IRQ+0x1e/0x30
 [<c0103916>] common_interrupt+0x1a/0x20
 [<c010103b>] mwait_idle+0x2b/0x40
 [<c0100e95>] cpu_idle+0x65/0x80
 [<c048299a>] start_kernel+0x1aa/0x1f0
 [<c0482320>] unknown_bootoption+0x0/0x1e0
Code: 5c 24 08 8b 44 24 5c be 14 00 00 00 89 74 24 0c 31 ff 89 54 24 04 89 04 
24 e8 01 60 fa ff 85 c0 0f 49 fb 85 ff 0f
85 72 fe ff ff <0f> 0b 8f 03 80 b7 3e c0 e9 65 fe ff ff 8d b4 26 00 00 00 00 83
 <0>Kernel panic - not syncing: Fatal exception in interrupt

Steps to reproduce:  This panic will randomly happen. no steps to reproduce

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
