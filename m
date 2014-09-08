From: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v10 net-next 2/2] net: filter: split filter.h and expose
 eBPF to user space
Date: Mon, 8 Sep 2014 08:37:23 +0200
Message-ID: <20140908063723.GA8219@gmail.com>
References: <20140907180737.GA5057@salvia>
 <CAMEtUuxJLDu8AAsZQdtG781vwC8y60Ygdt4ji5tbeyTE8YbWbQ@mail.gmail.com>
 <20140908052329.GA30461@gmail.com>
 <20140907.222841.1933004265241590374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	torvalds-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org,
	rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, akpm-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140907.222841.1933004265241590374.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


* David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:

> From: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Date: Mon, 8 Sep 2014 07:23:29 +0200
> 
> > 
> > * Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> > 
> >> > I don't think the speed up of the llvm submission is a 
> >> > good argument, this sounds to me similar to the "please 
> >> > apply this patch that reserves this new netlink family in 
> >> > include/linux/netlink.h, I promise this new subsystem will 
> >> > be submitted soon though. Meanwhile this will speed up 
> >> > submission of my userspace software to distributions for 
> >> > packaging" argument.
> >> 
> >> You're not correct here. I'm not saying 'I promise it will 
> >> be submitted'. There _were_ already submitted. [...]
> > 
> > And this split-up smaller submissions was requested by David 
> > Miller, the networking maintainer, so if Pablo wants another 
> > submission format, he needs to take it up with David - we 
> > can't do both at once obviously.
> 
> I think that just because I asked the submission size to be 
> smaller, it does not mean that you can submit things before you 
> provide the initial user as well.
> 
> And how to work that out and keep the submission size 
> reasonable is the submitter's problem, not mine.

That's a pretty harsh requirement but might be doable 
technically: Alexei, please submit a series that is large enough 
to provide self-sufficient functionality as per Pablo's request,
but is also small and minimal, as per David's request.

If that fails then another route would be to decouple from 
networking initially and create something new and stand-alone in 
kernel/ebpf/ (or any other name really), with tracing and perf 
usecases, with networking integration and code deduplication to 
be done at the end, when there can be no legitimate argument 
about its utility.

Thanks,

	Ingo
