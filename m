From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] tracing: bpf: Hide bpf trace events when they are not
 used
Date: Thu, 12 Oct 2017 18:14:52 -0700
Message-ID: <20171013011450.w2uqygdfzwf7ud64@ast-mbp>
References: <20171012184002.0661a867@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171012184002.0661a867@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 12, 2017 at 06:40:02PM -0400, Steven Rostedt wrote:
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

Looks fine.
Acked-by: Alexei Starovoitov <ast@kernel.org>

I'm assuming you want to take it through tracing tree along
with all other cleanups?
