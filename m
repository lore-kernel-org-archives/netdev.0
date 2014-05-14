From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH RFC net-next] tracing: accelerate tracing filters with BPF
Date: Wed, 14 May 2014 07:09:58 +0200
Message-ID: <20140514050958.GB9448@gmail.com>
References: <1400036111-7803-1-git-send-email-ast@plumgrid.com>
 <20140513231708.7eb39a38@gandalf.local.home>
 <CAMEtUuzct=k_9f4QTqRf2TG6mFCjpnfTjo+JkHYQDHKj_i2b+A@mail.gmail.com>
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
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:65403 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937AbaENFKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 01:10:05 -0400
Content-Disposition: inline
In-Reply-To: <CAMEtUuzct=k_9f4QTqRf2TG6mFCjpnfTjo+JkHYQDHKj_i2b+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Alexei Starovoitov <ast@plumgrid.com> wrote:

> On Tue, May 13, 2014 at 8:17 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> > On Tue, 13 May 2014 19:55:11 -0700
> > Alexei Starovoitov <ast@plumgrid.com> wrote:
> >
> >> Tracing filters are parsing user supplied character string and constructing
> >> a predicate tree. filter_match_preds() was used to walk nodes of the tree to
> >> simulate matching of boolean expression.
> >>
> >
> > I applied this on top of net-next, from:
> >
> >  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
> >  (master branch)
> >
> > and got this compile error:
> 
> Sorry I wasn't clear in the log.
> This patch depends on JIT patches that were posted separately.
> Since this one is RFC, I didn't want to mix them.
> JIT patches:
> http://patchwork.ozlabs.org/patch/348558/
> http://patchwork.ozlabs.org/patch/348559/
> http://patchwork.ozlabs.org/patch/348560/

Might make sense for you to get a korg account and stick such bits 
into Git trees, to ease testing.

Thanks,

	Ingo
