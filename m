From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: When does Linux drop UDP packets?
Date: Thu, 4 Jun 2009 17:07:47 -0400 (EDT)
Message-ID: <alpine.DEB.2.00.0906041706370.14994@gandalf.stny.rr.com>
References: <20090604145347.GA27692@miyuki>  <20090604155741.GA8999@goodmis.org> <20090604161015.GA17303@miyuki>  <alpine.DEB.2.00.0906041222450.14994@gandalf.stny.rr.com>  <alpine.DEB.2.00.0906041228170.14994@gandalf.stny.rr.com>
 <1244137576.3553.3.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Philipp Reh <sefi@s-e-f-i.de>, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jaswinder Singh Rajput <jaswinder@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.122]:57745 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468AbZFDVHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 17:07:47 -0400
In-Reply-To: <1244137576.3553.3.camel@ht.satnam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 4 Jun 2009, Jaswinder Singh Rajput wrote:

> On Thu, 2009-06-04 at 12:34 -0400, Steven Rostedt wrote:
> 
> > BTW, I used ftrace to look into this:
> > 
> > Enable:
> > 
> > 	CONFIG_FTRACE
> > 	CONFIG_FUNCTION_TRACER
> > 	CONFIG_FUNCITON_GRAPH_TRACER
> > 	CONFIG_DYNAMIC_FTRACE
> > 
> > Compile and boot:
> > 
> > # mount -t debugfs nodev /sys/kernel/debug
> 
> Very glad to see you following standards ;-)

I only did that to not hear the debugfs nazis squack.

> 
> > # cd /sys/kernel/debug
> 
> hmm you mean # cd /sys/kernel/debug/tracing

A mistake I would not have made if I just did /debug

> 
> > # echo udp_rcv > set_graph_function
> > # echo function_graph > current_tracer
> > # cat trace
> > 
> 
> Anyway you can also see UDP packet drops when you increase network and
> CPU load.

That's not the issue here.

-- Steve

