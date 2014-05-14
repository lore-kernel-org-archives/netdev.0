From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH RFC net-next] tracing: accelerate tracing filters with BPF
Date: Wed, 14 May 2014 07:09:05 +0200
Message-ID: <20140514050905.GA9448@gmail.com>
References: <1400036111-7803-1-git-send-email-ast@plumgrid.com>
 <20140513230713.1cc7db94@gandalf.local.home>
 <CAMEtUuyHO-MGzL6nrLShG1UHTzb=HXTAPV5trv1SHL6TV0bMYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Rostedt <rostedt@goodmis.org>,
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
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:35649 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981AbaENFJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 01:09:12 -0400
Content-Disposition: inline
In-Reply-To: <CAMEtUuyHO-MGzL6nrLShG1UHTzb=HXTAPV5trv1SHL6TV0bMYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Alexei Starovoitov <ast@plumgrid.com> wrote:

> On Tue, May 13, 2014 at 8:07 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> > On Tue, 13 May 2014 19:55:11 -0700
> > Alexei Starovoitov <ast@plumgrid.com> wrote:
> >
> >> --- a/kernel/trace/Kconfig
> >> +++ b/kernel/trace/Kconfig
> >> @@ -79,6 +79,7 @@ config FTRACE_NMI_ENTER
> >>         default y
> >>
> >>  config EVENT_TRACING
> >> +     depends on NET
> >>       select CONTEXT_SWITCH_TRACER
> >>       bool
> >>
> >
> > This part makes me a little nervous. I know a lot of embedded devices
> > depend on tracing, but do they all have network?
> 
> I think we may want to split BPF into its own config, since it doesn't
> really depend on anything in net.

Exactly, that's a good plan.

Thanks,

	Ingo
