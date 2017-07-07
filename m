From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2 0/9] Remove spin_unlock_wait()
Date: Fri, 7 Jul 2017 10:06:21 +0200
Message-ID: <20170707080621.dmhw2ryes7n3kgag@gmail.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <20170705232955.GA15992@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0033F01@AcuExch.aculab.com>
 <20170706160555.xc63yydk77gmttae@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
        "'paulmck@linux.vnet.ibm.com'" <paulmck@linux.vnet.ibm.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oleg@redhat.com" <oleg@redhat.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "mingo@redhat.com" <mingo@redhat.com>,
        "dave@stgolabs.net" <dave@stgolabs.net>,
        "manfred@colorfullife.com" <manfred@colorfullife.com>,
        "tj@kernel.org" <tj@kernel.org>, "arnd@arndb.de" <arnd@arndb.de>,
        "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
        "will.deacon@arm.com" <will.deacon@arm.com>,
        "stern@rowland.harvard.edu" <stern@rowland.harvard.edu>,
        "parri.andrea@gmail.com" <parri.andrea@gmail
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170706160555.xc63yydk77gmttae@hirez.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Peter Zijlstra <peterz@infradead.org> wrote:

> > It might even be that this is the defined semantics of spin_unlock_wait().
> 
> As is, spin_unlock_wait() is somewhat ill defined. IIRC it grew from an 
> optimization by Oleg and subsequently got used elsewhere. And it being the 
> subtle bugger it is, there were bugs.

I believe the historical, original spin_unlock_wait() came from early SMP 
optimizations of the networking code - and then spread elsewhere, step by step. 
All but one of the networking uses went away since then - so I don't think there's 
any original usecase left.

Thanks,

	Ingo
