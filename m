From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10309] New: BUG: soft lockup - CPU#0 stuck
Date: Sat, 22 Mar 2008 09:37:33 -0700
Message-ID: <20080322093733.f19781d3.akpm@linux-foundation.org>
References: <bug-10309-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, arnova@eld.physics.leidenuniv.nl
To: sparclinux@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44491 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753242AbYCVQhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 12:37:41 -0400
In-Reply-To: <bug-10309-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 22 Mar 2008 06:53:40 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10309
> 
>            Summary: BUG: soft lockup - CPU#0 stuck
>            Product: Platform Specific/Hardware
>            Version: 2.5
>      KernelVersion: 2.6.24.3
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: SPARC64
>         AssignedTo: platform_sparc64@kernel-bugs.osdl.org
>         ReportedBy: arnova@eld.physics.leidenuniv.nl
> 
> 
> Earliest failing kernel version: 2.6.24.3
> Distribution: Debian 4.0/Etch Sparc64
> Hardware Environment: Sparc64
> Problem Description:
> During boot of my Sparc64 with a vanille 2.6.24.3 kernel the kernel gets stuck.
> After while it continues allowing normal use of the machine. The message shown
> in the kernel logs looks like this:
> 
> BUG: soft lockup - CPU#0 stuck for 11s! [ifconfig:2408]
> TSTATE: 0000004480009603 TPC: 0000000010013390 TNPC: 0000000010013394 Y:
> 00000000    Not tainted
> TPC: <gem_interrupt+0x14/0xec [sungem]>
> g0: 0000000000009000 g1: 0800000000000001 g2: 0000000000000100 g3:
> 0000000000000400
> g4: fffff8003e61c060 g5: 0000000000000020 g6: fffff8003e7e8000 g7:
> 0000000000000000
> o0: 0000000000000001 o1: fffff8003d090670 o2: 0000000000000001 o3:
> 000001fe0000f078
> o4: 7fffffffffffffff o5: 0000000080000000 sp: fffff8003e7ea341 ret_pc:
> 00000000100133bc
> RPC: <gem_interrupt+0x40/0xec [sungem]>
> l0: fffff8003d090670 l1: 0000000000821400 l2: fffff8003e7eaca0 l3:
> 0000000000000400
> l4: 0000000000000000 l5: 0000000000000005 l6: 0000000000000000 l7:
> 0000000000000008
> i0: 0000000000000009 i1: fffff8003d090620 i2: 000000001c2245fa i3:
> 000000000000000c
> i4: 7fffffffffffffff i5: 0000000000000000 i6: fffff8003e7ea401 i7:
> 000000000047e974
> I7: <handle_IRQ_event+0x34/0x74>
> 
> It appartently has to do with the network (ifconfig) although I'm not 100%. I
> tried changing several settings in the kernel (to many to write down here) but
> all give the same result.
> 
> Steps to reproduce:
> - Build a 2.6.24.3 for Sparc64
> - Boot a SUN Sparc64 machine with this kernel
> - System gets stuck during boot but after a while it continues its boot.
> 

I expect it would be useful if you tell us the latest version of the kernel
on which this didn't happen.  ie: what kernel version were you running before
you "up"graded to 2.6.24?

Thanks.
