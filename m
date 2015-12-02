From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: ipsec impact on performance
Date: Wed, 2 Dec 2015 08:25:11 -0500
Message-ID: <20151202132511.GL23178@oracle.com>
References: <20151201175953.GC21252@oracle.com>
 <CALx6S35uLqbuJTAFLMeT-BcyZw_fksz+7BkS=Nt7_3-nYMHF2A@mail.gmail.com>
 <20151201183720.GE21252@oracle.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CBE0ED7@AcuExch.aculab.com>
 <20151202121156.GK23178@oracle.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CBE0F39@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBE0F39@AcuExch.aculab.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (12/02/15 12:41), David Laight wrote:
> 
> Also what/how are you measuring cpu use.
> I'm not sure anything on Linux gives you a truly accurate value
> when processes are running for very short periods.

I was using mpstat, while running iperf. Should I be using
something else? or running it for longer intervals?

but I hope we are not doomed at 1 Gbps, or else security itself would
come at a very unattractive cost. Anyway, even aside from crypto.
we need to have some way to add TCP options (that depend on the 
contents of the tcp header) etc post-GSO, in the interest of not 
ossifying the stack.

> On an SMP system you also get big effects when work is switched
> between cpus. I've got some tests that run a lot faster if I
> put all but one of the cpus into a busy-loop in userspace
> (eg: while :; do :; done)!

yes Rick Jones also pointed the same thing to me, and one of the
things I was going to try out later today is to instrument the
effects of pinning irqs and iperf threads to a specific cpu.

--Sowmini
