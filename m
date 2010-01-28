From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: PROBLEM: reproducible crash KVM+nf_conntrack all recent 2.6
 kernels
Date: Thu, 28 Jan 2010 16:49:14 -0500
Message-ID: <1264715354.2793.156.camel@tonnant>
References: <1264657559.2793.103.camel@tonnant>
	 <1264658364.2793.105.camel@tonnant>  <4B6180D1.6050609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752935Ab0A1VtY@vger.kernel.org>
In-Reply-To: <4B6180D1.6050609@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-01-28 at 13:19 +0100, Patrick McHardy wrote:
> ip6tables -t raw -I PREROUTING -j TRACE

I'm not seeing anything on the console - is there additional conntrack
debugging I can enable? I will try building in netfilter debug again.

But I did just get this crash while testing again:

BUG: unable to handle kernel paging request at ffff8802aae52f20
IP: [<ffffffff813b1e7d>] __nf_conntrack_find+0x53/0xb1
PGD 1a3c063 PUD 0 
Oops: 0000 [#1] SMP 
last sysfs file: /sys/kernel/mm/ksm/run
CPU 5 
Pid: 2012, comm: qemu-kvm Not tainted 2.6.33-rc5 #1 0F9382/Precision
WorkStation 490    
RIP: 0010:[<ffffffff813b1e7d>]  [<ffffffff813b1e7d>] __nf_conntrack_find
+0x53/0xb1
RSP: 0018:ffff880172893778  EFLAGS: 00010282
RAX: ffff8802aae52f20 RBX: ffff880172893878 RCX: 00000000eb883b77
RDX: 000000000001d710 RSI: 0000000081af2f90 RDI: 000000003b9ab4e4
RBP: ffff8801728937b8 R08: 000000008a6bf028 R09: 00000000a2d26753
R10: 0000000067d81e2b R11: ffff88017289389c R12: ffffffff81ddace0
R13: ffff880172893878 R14: ffffffff81ddace0 R15: 00000000137f25e4
FS:  00007f002fe16780(0000) GS:ffff880028340000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffff8802aae52f20 CR3: 00000001717dd000 CR4: 00000000000026e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process qemu-kvm (pid: 2012, threadinfo ffff880172892000, task
ffff8801702bc5f0)

Jon.
