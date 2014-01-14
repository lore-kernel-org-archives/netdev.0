From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] reciprocal_divide: correction/update of the algorithm
Date: Tue, 14 Jan 2014 21:10:42 +0100
Message-ID: <20140114201042.GA13804@order.stressinduktion.org>
References: <20140113214249.GK6586@order.stressinduktion.org> <1389722825.31367.260.camel@edumazet-glaptop2.roam.corp.google.com> <52D58E6F.4050000@gmail.com> <1389729032.31367.262.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Austin S Hemmelgarn <ahferroin7@gmail.com>, netdev@vger.kernel.org,
	dborkman@redhat.com, linux-kernel@vger.kernel.org,
	darkjames-ws@darkjames.pl
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1389729032.31367.262.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 14, 2014 at 11:50:32AM -0800, Eric Dumazet wrote:
> On Tue, 2014-01-14 at 14:22 -0500, Austin S Hemmelgarn wrote:
> 
> > I disagree with the statement that current CPU's have reasonably fast
> > dividers.  A lot of embedded processors and many low-end x86 CPU's do
> > not in-fact have any hardware divider, and usually provide it using
> > microcode based emulation if they provide it at all.  The AMD Jaguar
> > micro-architecture in particular comes to mind, it uses an iterative
> > division algorithm provided by the microcode that only produces 2 bits
> > of quotient per cycle, even in the best case (2 8-bit integers and an
> > integral 8-bit quotient) this still takes 4 cycles, which is twice as
> > slow as any other math operation on the same processor.
> 
> I doubt you run any BPF filter with a divide instruction in it on these
> platform.
> 
> Get real, do not over optimize things where it does not matter.

If I read the instruction tables correctly, we could half the latency with
reciprocal divide even on haswell.

What a pitty that the Intel Architecture Code Analyzer does not support imul
nor div instruction. :(
