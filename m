From: Andi Kleen <ak@suse.de>
Subject: Re: System crash in tcp_fragment()
Date: Tue, 21 May 2002 01:54:07 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <acc2ct$ctr$2@main.gmane.org>
References: <3CE95190.75C52E2D@mvista.com> <200205202125.BAA03545@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: george anzinger <george@mvista.com>, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, davem@redhat.com, ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200205202125.BAA03545@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

> And also your reasoning about smp_processor_id() sounds strange,
> preemption code must reschedule thread preemted in the kernel to the
> same cpu, it is enough to avoid troubles with this. 

It's unfortunately the truth. Even in_interrupt() is buggy current 
on SMP preemptive.

-Andi
