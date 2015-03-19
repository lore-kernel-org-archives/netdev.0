From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v7 tip 3/8] tracing: allow BPF programs to call
 bpf_ktime_get_ns()
Date: Thu, 19 Mar 2015 11:41:45 -0400
Message-ID: <20150319114145.53f0755d@gandalf.local.home>
References: <1426542584-9406-1-git-send-email-ast@plumgrid.com>
	<1426542584-9406-4-git-send-email-ast@plumgrid.com>
	<20150319111124.38f53061@gandalf.local.home>
	<550AED5D.3010700@plumgrid.com>
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
In-Reply-To: <550AED5D.3010700@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Mar 2015 08:38:05 -0700
Alexei Starovoitov <ast@plumgrid.com> wrote:

> > Hmm, a nanosecond value returned as integer? Is there a way to make
> > this a 64 bit return type, or is RET_INTEGER default to 64 bits in BPF
> > functions?
> 
> RET_INTEGER doesn't mean C 'int' width. It means non-pointer and
> non-void value. The return value is always promoted to full
> register width which is 64-bit.
> 

OK.

Reviewed-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve
