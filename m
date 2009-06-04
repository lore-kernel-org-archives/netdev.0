From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: Re: When does Linux drop UDP packets?
Date: Thu, 04 Jun 2009 23:16:16 +0530
Message-ID: <1244137576.3553.3.camel@ht.satnam>
References: <20090604145347.GA27692@miyuki>
	 <20090604155741.GA8999@goodmis.org> <20090604161015.GA17303@miyuki>
	 <alpine.DEB.2.00.0906041222450.14994@gandalf.stny.rr.com>
	 <alpine.DEB.2.00.0906041228170.14994@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Philipp Reh <sefi@s-e-f-i.de>, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752482AbZFDRp5@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.0906041228170.14994@gandalf.stny.rr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-06-04 at 12:34 -0400, Steven Rostedt wrote:

> BTW, I used ftrace to look into this:
> 
> Enable:
> 
> 	CONFIG_FTRACE
> 	CONFIG_FUNCTION_TRACER
> 	CONFIG_FUNCITON_GRAPH_TRACER
> 	CONFIG_DYNAMIC_FTRACE
> 
> Compile and boot:
> 
> # mount -t debugfs nodev /sys/kernel/debug

Very glad to see you following standards ;-)

> # cd /sys/kernel/debug

hmm you mean # cd /sys/kernel/debug/tracing

> # echo udp_rcv > set_graph_function
> # echo function_graph > current_tracer
> # cat trace
> 

Anyway you can also see UDP packet drops when you increase network and
CPU load.

--
JSR
