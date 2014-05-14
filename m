From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC net-next] tracing: accelerate tracing filters with BPF
Date: Tue, 13 May 2014 20:26:10 -0700
Message-ID: <CAMEtUuyHO-MGzL6nrLShG1UHTzb=HXTAPV5trv1SHL6TV0bMYw@mail.gmail.com>
References: <1400036111-7803-1-git-send-email-ast@plumgrid.com>
	<20140513230713.1cc7db94@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ingo Molnar <mingo@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Grant Likely <grant.likely@secretlab.ca>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140513230713.1cc7db94@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 13, 2014 at 8:07 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> On Tue, 13 May 2014 19:55:11 -0700
> Alexei Starovoitov <ast@plumgrid.com> wrote:
>
>> --- a/kernel/trace/Kconfig
>> +++ b/kernel/trace/Kconfig
>> @@ -79,6 +79,7 @@ config FTRACE_NMI_ENTER
>>         default y
>>
>>  config EVENT_TRACING
>> +     depends on NET
>>       select CONTEXT_SWITCH_TRACER
>>       bool
>>
>
> This part makes me a little nervous. I know a lot of embedded devices
> depend on tracing, but do they all have network?

I think we may want to split BPF into its own config, since it doesn't
really depend on anything in net.

> They may, but I would like to hear from others in the embedded space.
>
> -- Steve
