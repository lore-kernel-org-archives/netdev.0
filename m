From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH resend] tracing/events: convert NAPI's tracepoint via
 TRACE_EVENT
Date: Mon, 31 Aug 2009 14:09:04 -0400 (EDT)
Message-ID: <alpine.DEB.2.00.0908311407060.13931@gandalf.stny.rr.com>
References: <4A9B6AA7.5020508@cn.fujitsu.com> <20090831084922.GB25811@elte.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.123]:60501 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753310AbZHaSJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 14:09:04 -0400
In-Reply-To: <20090831084922.GB25811@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 31 Aug 2009, Ingo Molnar wrote:

> 
> * Xiao Guangrong <xiaoguangrong@cn.fujitsu.com> wrote:
> 
> > - Convert NAPI's tracepoint via TRACE_EVENT macro, the output information
> >   like below:
> 
> I think as long as it does not touch tracing infrastructure (which 
> your patches dont do in their current form) this should be 
> done/merged via the networking tree.

I agree, all changes that are in include/trace/events/ and trace point 
usage can stay within the subsystem tree.

> 
> [ There might be some small collisions in define_trace.h (because
>   these tracepoints move from legacy to new-style TRACE_EVENT() 
>   form) but that's OK. ]

But changes to anything in include/trace or kernel/trace needs to go 
throught the tracing subsystem. This includes a changes to define_trace.h.

Thanks,

-- Steve

