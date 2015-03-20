From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v8 tip 2/9] tracing: add kprobe flag
Date: Fri, 20 Mar 2015 16:11:23 -0400
Message-ID: <20150320161123.24c65bcb@gandalf.local.home>
References: <1426816787-5001-1-git-send-email-ast@plumgrid.com>
	<1426816787-5001-3-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>, Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426816787-5001-3-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Mar 2015 18:59:40 -0700
Alexei Starovoitov <ast@plumgrid.com> wrote:

> add TRACE_EVENT_FL_KPROBE flag to differentiate kprobe type of tracepoints,
> since bpf programs can only be attached to kprobe type of
> PERF_TYPE_TRACEPOINT perf events.
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
>  include/linux/ftrace_event.h |    3 +++
>  kernel/trace/trace_kprobe.c  |    2 +-
>  2 files changed, 4 insertions(+), 1 deletion(-)

Reviewed-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve
