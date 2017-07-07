From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 0/9] Remove spin_unlock_wait()
Date: Fri, 7 Jul 2017 13:23:12 +0200
Message-ID: <20170707112312.lyo762rayi5uqayw@hirez.programming.kicks-ass.net>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <20170705232955.GA15992@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0033F01@AcuExch.aculab.com>
 <20170706160555.xc63yydk77gmttae@hirez.programming.kicks-ass.net>
 <20170706162024.GD2393@linux.vnet.ibm.com>
 <20170706165036.v4u5rbz56si4emw5@hirez.programming.kicks-ass.net>
 <20170707083128.wqk6msuuhtyykhpu@gmail.com>
 <20170707084427.vdsmwkgqx6uvg7tw@hirez.programming.kicks-ass.net>
 <20170707103349.yohrygljglwx6qn2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        David Laight <David.Laight@ACULAB.COM>,
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
        "parri.andrea@gmail.com" <parri.andrea@gmail.com>,
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170707103349.yohrygljglwx6qn2@gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 07, 2017 at 12:33:49PM +0200, Ingo Molnar wrote:

>  [1997/04] v2.1.36:
> 
>       the spin_unlock_wait() primitive gets introduced as part of release()


Whee, that goes _way_ further back than I thought it did :-)

>  [2017/07] v4.12:
> 
>       wait_task_inactive() is still alive and kicking. Its poll loop has
>       increased in complexity, but it still does not use spin_unlock_wait()
> 

I've tried 'fixing' that wait_task_inactive() thing a number of times,
but always failed :/ That is very nasty code indeed.
