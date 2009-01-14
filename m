From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] softlockup: detect bottom-half lockups
Date: Wed, 14 Jan 2009 09:06:40 +0100
Message-ID: <20090114080640.GA19116@elte.hu>
References: <20090114070447.GA25222@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, rientjes@google.com,
	mbligh@google.com, thockin@google.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Mandeep Singh Baines <msb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:38766 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754654AbZANIG5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 03:06:57 -0500
Content-Disposition: inline
In-Reply-To: <20090114070447.GA25222@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Mandeep Singh Baines <msb@google.com> wrote:

> The feature should be useful to real-time developers and developers of 
> network and other high-performance drivers.

hm, did you know about the ftrace latency tracers:

 config IRQSOFF_TRACER
         bool "Interrupts-off Latency Tracer"

 config PREEMPT_TRACER
         bool "Preemption-off Latency Tracer"

 config SCHED_TRACER
         bool "Scheduling Latency Tracer"

PREEMPT_TRACER would have shown you that softirqs-off section very nicely. 

(And if you also enable the function tracer then not just the latency 
endpoint is shown, but also all the function calls that happened in the 
critical section.)

	Ingo
