From: Mandeep Singh Baines <msb@google.com>
Subject: Re: [PATCH] softlockup: detect bottom-half lockups
Date: Thu, 15 Jan 2009 06:04:55 -0800
Message-ID: <20090115140454.GH4722@google.com>
References: <20090114070447.GA25222@google.com> <20090114080640.GA19116@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, rientjes@google.com,
	mbligh@google.com, thockin@google.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764538AbZAOTTi@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090114080640.GA19116@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stumbled upon ftrace tracepoints while writing this patch. Should
make life a lot easier for debugging latency issues.

bhlockup should complement ftrace. Once you've found that there's a
problem, tracing can be a big help in debugging. But assertions are
nice for finding problems you didn't know exist.

Ingo Molnar (mingo@elte.hu) wrote:
> 
> * Mandeep Singh Baines <msb@google.com> wrote:
> 
> > The feature should be useful to real-time developers and developers of 
> > network and other high-performance drivers.
> 
> hm, did you know about the ftrace latency tracers:
> 
>  config IRQSOFF_TRACER
>          bool "Interrupts-off Latency Tracer"
> 
>  config PREEMPT_TRACER
>          bool "Preemption-off Latency Tracer"
> 
>  config SCHED_TRACER
>          bool "Scheduling Latency Tracer"
> 
> PREEMPT_TRACER would have shown you that softirqs-off section very nicely. 
> 
> (And if you also enable the function tracer then not just the latency 
> endpoint is shown, but also all the function calls that happened in the 
> critical section.)
> 
> 	Ingo
