From: "George P Nychis" <gnychis@cmu.edu>
Subject: Re: 2.4.32: unresolved symbol unregister_qdisc
Date: Sat, 8 Apr 2006 19:18:47 -0400 (EDT)
Message-ID: <33083.128.2.140.234.1144538327.squirrel@128.2.140.234>
References: <32947.128.2.140.234.1144536454.squirrel@128.2.140.234>
    <20060408.155430.111013393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965052AbWDHXSu@vger.kernel.org>
In-Reply-To: <20060408.155430.111013393.davem@davemloft.net>
To: "David S. Miller" <davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yeah, this module is unfortunately not under the GPL, it was made for research and i am not the author, I was only given the code for my own research.

I enabled that support in the kernel, and then tried to recompile and get tons of errors/warnings... so maybe I am missing something else to be enabled in the kernel... here are a few examples of errors:
/usr/include/linux/skbuff.h:30:26: net/checksum.h: No such file or directory
/usr/include/asm/irq.h:16:25: irq_vectors.h: No such file or directory
/usr/include/linux/irq.h:72: error: `NR_IRQS' undeclared here (not in a function)
/usr/include/asm/hw_irq.h:28: error: `NR_IRQ_VECTORS' undeclared here (not in a function)

I think those are the top most errors, so if i can fix those hopefully the rest shall vanish!

- George


> From: "George P Nychis" <gnychis@cmu.edu> Date: Sat, 8 Apr 2006 18:47:34
> -0400 (EDT)
> 
>> Hey,
>> 
>> I have a kernel module that uses unregister_qdisc and register_qdisc,
>> whenever i try to insert the module I get: 
>> /lib/modules/2.4.32/kernel/net/sched/sch_xcp.o:
>> /lib/modules/2.4.32/kernel/net/sched/sch_xcp.o: unresolved symbol
>> unregister_qdisc /lib/modules/2.4.32/kernel/net/sched/sch_xcp.o:
>> /lib/modules/2.4.32/kernel/net/sched/sch_xcp.o: unresolved symbol
>> register_qdisc
>> 
>> Am i missing some sort of support in the kernel?
> 
> Make sure CONFIG_NET_SCHED is enabled and that you compiled your module
> against that kernel.
> 
> Where does this sch_xcp come from?  It's not in the vanilla sources.
> 
> Also, please direct networking questions to the netdev@vger.kernel.org 
> mailing list which I have added to the CC:.
> 
> 


-- 
