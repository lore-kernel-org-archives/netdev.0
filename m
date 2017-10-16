From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tracing: bpf: Hide bpf trace events when they are not
 used
Date: Mon, 16 Oct 2017 20:54:34 +0100 (WEST)
Message-ID: <20171016.205434.1066116631088582472.davem@davemloft.net>
References: <20171012184002.0661a867@gandalf.local.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
        netdev@vger.kernel.org
To: rostedt@goodmis.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171012184002.0661a867@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Rostedt <rostedt@goodmis.org>
Date: Thu, 12 Oct 2017 18:40:02 -0400

> From: Steven Rostedt (VMware) <rostedt@goodmis.org>
> 
> All the trace events defined in include/trace/events/bpf.h are only
> used when CONFIG_BPF_SYSCALL is defined. But this file gets included by
> include/linux/bpf_trace.h which is included by the networking code with
> CREATE_TRACE_POINTS defined.
> 
> If a trace event is created but not used it still has data structures
> and functions created for its use, even though nothing is using them.
> To not waste space, do not define the BPF trace events in bpf.h unless
> CONFIG_BPF_SYSCALL is defined.
> 
> Signed-off-by: Steven Rostedt (VMware) <rostedt@goodmis.org>

Steven, I lost track of how this patch is being handled.

Do you want me to merge it via my net-next tree?
