From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v10 net-next 2/2] net: filter: split filter.h and expose
 eBPF to user space
Date: Sun, 7 Sep 2014 23:34:23 -0700
Message-ID: <CAMEtUuzfhnKKbyMW8qDk4YxM3X_NWHU6Gkt1DDTSHXhcScXccQ@mail.gmail.com>
References: <20140907180737.GA5057@salvia>
	<CAMEtUuxJLDu8AAsZQdtG781vwC8y60Ygdt4ji5tbeyTE8YbWbQ@mail.gmail.com>
	<20140908052329.GA30461@gmail.com>
	<20140907.222841.1933004265241590374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	Linus Torvalds <torvalds-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140907.222841.1933004265241590374.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 7, 2014 at 10:28 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Date: Mon, 8 Sep 2014 07:23:29 +0200
>
>>
>> * Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>>
>>> > I don't think the speed up of the llvm submission is a good
>>> > argument, this sounds to me similar to the "please apply this
>>> > patch that reserves this new netlink family in
>>> > include/linux/netlink.h, I promise this new subsystem will be
>>> > submitted soon though. Meanwhile this will speed up
>>> > submission of my userspace software to distributions for
>>> > packaging" argument.
>>>
>>> You're not correct here. I'm not saying 'I promise it will be
>>> submitted'. There _were_ already submitted. [...]
>>
>> And this split-up smaller submissions was requested by David
>> Miller, the networking maintainer, so if Pablo wants another
>> submission format, he needs to take it up with David - we can't
>> do both at once obviously.
>
> I think that just because I asked the submission size to be smaller,
> it does not mean that you can submit things before you provide the
> initial user as well.
>
> And how to work that out and keep the submission size reasonable is
> the submitter's problem, not mine.

imo llvm is more than enough for the first user, no?
I think I've explained that it's practically impossible to have
first in-tree user in the first patch. What do you suggest?
I'm listening, but currently I see no way out.
The patch was large. I broke it down. The first patch is as tiny
as it can get, but Pablo is stalling it, like he did for the last year.
Honestly it doesn't feel fair.
When there were technical arguments (like global vs fd) or
(union attr vs long for syscall) I've listened and rewrote things.
Now it doesn't sound technical.
