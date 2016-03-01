From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC][PATCH] tags: Fix DEFINE_PER_CPU expansions
Date: Tue, 1 Mar 2016 13:49:49 -0500
Message-ID: <20160301184949.GJ3965@htj.duckdns.org>
References: <20160301102625.GQ6357@twins.programming.kicks-ass.net>
 <20160301163707.GF3965@htj.duckdns.org>
 <20160301181842.GX6357@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, rjw@rjwysocki.net,
	konrad.wilk@oracle.com, Ingo Molnar <mingo@kernel.org>,
	paulmck@linux.vnet.ibm.com, davem@davemloft.net,
	linux-acpi@vger.kernel.org, netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160301181842.GX6357@twins.programming.kicks-ass.net>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Tue, Mar 01, 2016 at 07:18:42PM +0100, Peter Zijlstra wrote:
> > Urgh... I really hate the fact that we're putting on arbitrary
> > formatting constraints to compensate for shortcomings in an
> > out-of-line utility.
> 
> Yes it does.
> 
> I'm not too bothered if you don't want to fix this, I just figured I'd
> have a stab at fixing all this, since I regularly run 'make tags' and
> got tired of seeing the warns.

I use cscope so haven't noticed them.

> > Can't it do multiline regex?
> 
> Apparently not:
> 
>   https://sourceforge.net/p/ctags/feature-requests/38/

That's unfortunate.  Ah well, it's only several spots and isn't a big
deal one way or the other.  Occasional >80 lines are fine by me.
Please feel free to add

 Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
