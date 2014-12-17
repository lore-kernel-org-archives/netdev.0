From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: [RFC PATCH net-next 0/5] tcp: TCP tracer
Date: Wed, 17 Dec 2014 18:24:59 -0300
Message-ID: <20141217212459.GD3150@kernel.org>
References: <CAADnVQ+zkNL9sJhJuAiQ_y4bis=Sck5pzG86qccXE9vvM0-drQ@mail.gmail.com>
 <5491EE01.5020406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Martin KaFai Lau <kafai@fb.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Lawrence Brakmo <brakmo@fb.com>, Josef Bacik <jbacik@fb.com>,
	Kernel Team <Kernel-team@fb.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:44570 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbaLQVZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 16:25:37 -0500
Content-Disposition: inline
In-Reply-To: <5491EE01.5020406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Dec 17, 2014 at 01:56:33PM -0700, David Ahern escreveu:
> On 12/17/14 1:42 PM, Alexei Starovoitov wrote:
> >>It is not strictly necessary to carry vmlinux, that is just a probe
> >>>point resolution time problem, solvable when generating a shell script,
> >>>on the development machine, to insert the probes.
> >on N development machines with kernels that
> >would match worker machines...
> >I'm not saying it's impossible, just operationally difficult.
> >This is my understanding of Martin's use case.

> That's the use case I am talking about ... N-different kernel versions and
> the probe definitions would need to be generated at *build* time of the
> kernel that uses a cross-compile environment. ie., can't assume there is a
> development machine running the kernel from which you can generate the probe
> definitions. This gets messy quick for embedded deployments.

It shouldn't, you're saying that the rate of pushing out production
kernels is so high that we get lost and can't find the matching full
debug original binaries used.

We have build-ids for that, to have binary content keys, that we can
match what is in production, that has to be as lean as possible, while
being able to get back to all that fat.

Is it that people want so hard to forget about that extra debugging fat
that in the end we need to keep it to be able to figure out what happens
when things go wrong?

I understand that the expectation is that for each production build
there will be unwieldly different probe point definitions to keep, but
is that so?

- Arnaldo
