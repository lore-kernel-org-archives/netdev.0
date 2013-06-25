From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH 40/45] powerpc, irq: Use GFP_ATOMIC allocations in atomic
 context
Date: Tue, 25 Jun 2013 12:58:58 +1000
Message-ID: <20130625025858.GE14051@concordia>
References: <20130623133642.19094.16038.stgit@srivatsabhat.in.ibm.com>
 <20130623134657.19094.93687.stgit@srivatsabhat.in.ibm.com>
 <20130625020842.GD14051@concordia>
 <1372126384.3944.177.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org,
	laijs@cn.fujitsu.com, rostedt@goodmis.org,
	wangyun@linux.vnet.ibm.com, xiaoguangrong@linux.vnet.ibm.com,
	sbw@mit.edu, fweisbec@gmail.com, zhong@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Paul Mackerras <paulus@samba.org>,
	Ian Munsie <imunsie@au1.ibm.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-pm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1372126384.3944.177.camel@pasglop>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 25, 2013 at 12:13:04PM +1000, Benjamin Herrenschmidt wrote:
> On Tue, 2013-06-25 at 12:08 +1000, Michael Ellerman wrote:
> > We're not checking for allocation failure, which we should be.
> > 
> > But this code is only used on powermac and 85xx, so it should probably
> > just be a TODO to fix this up to handle the failure.
> 
> And what can we do if they fail ?

Fail up the chain and not unplug the CPU presumably.

cheers
