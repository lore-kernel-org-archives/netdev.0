From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH RFC net-next] tracing: accelerate tracing filters with
 BPF
Date: Tue, 13 May 2014 23:07:13 -0400
Message-ID: <20140513230713.1cc7db94@gandalf.local.home>
References: <1400036111-7803-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Grant Likely <grant.likely@secretlab.ca>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400036111-7803-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 May 2014 19:55:11 -0700
Alexei Starovoitov <ast@plumgrid.com> wrote:

> --- a/kernel/trace/Kconfig
> +++ b/kernel/trace/Kconfig
> @@ -79,6 +79,7 @@ config FTRACE_NMI_ENTER
>         default y
>  
>  config EVENT_TRACING
> +	depends on NET
>  	select CONTEXT_SWITCH_TRACER
>  	bool
>  

This part makes me a little nervous. I know a lot of embedded devices
depend on tracing, but do they all have network?

They may, but I would like to hear from others in the embedded space.

-- Steve
