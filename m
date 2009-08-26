From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 26 Aug 2009 21:48:35 +0200
Message-ID: <20090826194835.GA16508@elte.hu>
References: <20090826181502.GC13632@elte.hu> <20090826190435.GC10816@hmsreliant.think-freely.org> <20090826190830.GF13632@elte.hu> <20090826.123631.79533250.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, rostedt@goodmis.org, fweisbec@gmail.com,
	billfink@mindspring.com, netdev@vger.kernel.org, brice@myri.com,
	gallatin@myri.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:42759 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751390AbZHZTsm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 15:48:42 -0400
Content-Disposition: inline
In-Reply-To: <20090826.123631.79533250.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Wed, 26 Aug 2009 21:08:30 +0200
> 
> > Sigh, no. Please re-read the past discussions about this. 
> > trace_skb_sources.c is a hack and should be converted to generic 
> > tracepoints. Is there anything in it that cannot be expressed in 
> > terms of TRACE_EVENT()?
> 
> Neil explained why he needed to implement it this way in his reply 
> to Steven Rostedt.  I attach it here for your convenience.

thanks. The argument is invalid:

> > BTW, why not just do this as events? Or was this just a easy way 
> > to communicate with the user space tools?
> 
> Thats exactly why I did it.  the idea is for me to now write a 
> user space tool that lets me analyze the events and ajust process 
> scheduling to optimize the rx path. Neil

All tooling (in fact _more_ tooling) can be done based on generic, 
TRACE_EVENT() based tracepoints. Generic tracepoints are far more 
available, have a generalized format with format parsers and user 
tooling implemented, etc. etc.

	Ingo
