From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 15/45] rcu: Use get/put_online_cpus_atomic() to prevent CPU offline
Date: Wed, 26 Jun 2013 15:29:40 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B72AA@saturn3.aculab.com>
References: <20130625202452.16593.22810.stgit@srivatsabhat.in.ibm.com> <20130625202755.16593.67819.stgit@srivatsabhat.in.ibm.com> <20130625220026.GG3828@linux.vnet.ibm.com> <51CAF624.6060004@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <peterz@infradead.org>, <fweisbec@gmail.com>,
	<linux-kernel@vger.kernel.org>, <walken@google.com>,
	<mingo@kernel.org>, <linux-arch@vger.kernel.org>,
	<vincent.guittot@linaro.org>, <xiaoguangrong@linux.vnet.ibm.com>,
	<wangyun@linux.vnet.ibm.com>, <nikunj@linux.vnet.ibm.com>,
	<linux-pm@vger.kernel.org>, <rusty@rustcorp.com.au>,
	<rostedt@goodmis.org>, <namhyung@kernel.org>, <tglx@linutronix.de>,
	<laijs@cn.fujitsu.com>, <zhong@linux.vnet.ibm.com>,
	<netdev@vger.kernel.org>, <oleg@redhat.com>, <sbw@mit.edu>,
	<tj@kernel.org>, <akpm@linux-foundation.org>,
	<linuxppc-dev@lists.ozlabs.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	<paulmck@linux.vnet.ibm.com>
Return-path: <linux-pm-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <51CAF624.6060004@linux.vnet.ibm.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Once stop_machine() is gone from the CPU offline path, we won't be able
> to depend on disabling preemption to prevent CPUs from going offline
> from under us.

Could you use an rcu-like sequence so that disabling pre-emption
would be enough?

Something like rebuilding the cpu list, then forcing yourself
to run on all the cpu.

That would be far less intrusive.

	David



