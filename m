From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v3 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Tue, 10 Feb 2015 07:27:45 -0500
Message-ID: <20150210072745.09ce84f4@grimm.local.home>
References: <CAMEtUuzuu9T1eHyh27tdyj1+BnFta9-dzK8q7P9Y7x4iQrk+Xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>, Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuzuu9T1eHyh27tdyj1+BnFta9-dzK8q7P9Y7x4iQrk+Xw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 9 Feb 2015 21:51:05 -0800
Alexei Starovoitov <ast@plumgrid.com> wrote:

> On Mon, Feb 9, 2015 at 8:46 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> >
> > Looks like this is entirely perf based and does not interact with
> > ftrace at all. In other words, it's perf not tracing.
> >
> > It makes more sense to go through tip than the tracing tree.
> 
> well, all of earlier series were based on ftrace only,
> but I was given convincing enough arguments that
> perf_even_open+ioctl is a better interface :)
> Ok. will rebase on tip in the next version.

That's fine. If this proves useful, I'll probably add the interface
back to ftrace as well.

-- Steve
