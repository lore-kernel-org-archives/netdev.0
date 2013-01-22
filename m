From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 01/45] percpu_rwlock: Introduce the global
 reader-writer lock backend
Date: Tue, 22 Jan 2013 15:54:21 -0500
Message-ID: <1358888061.21576.57.camel@gandalf.local.home>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
	 <20130122073315.13822.27093.stgit@srivatsabhat.in.ibm.com>
	 <1358883152.21576.55.camel@gandalf.local.home>
	 <50FEEF5D.6080302@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-doc@vger.kernel.org, peterz@infradead.org,
	fweisbec@gmail.com, linux-kernel@vger.kernel.org, mingo@kernel.org,
	linux-arch@vger.kernel.org, linux@arm.linux.org.uk,
	xiaoguangrong@linux.vnet.ibm.com, wangyun@linux.vnet.ibm.com,
	paulmck@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, rusty@rustcorp.com.au, rjw@sisk.pl,
	namhyung@kernel.org, tglx@linutronix.de,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	oleg@redhat.com, sbw@mit.edu, tj@kernel.org,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <50FEEF5D.6080302@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-01-23 at 01:28 +0530, Srivatsa S. Bhat wrote:

> > I thought global locks are now fair. That is, a reader will block if a
> > writer is waiting. Hence, the above should deadlock on the current
> > rwlock_t types.
> > 
> 
> Oh is it? Last I checked, lockdep didn't complain about this ABBA scenario!

It doesn't and Peter Zijlstra said we need to fix that ;-)  It only
recently became an issue with the new "fair" locking of rwlocks.

-- Steve
