From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 50/51] net/core/flow.c: Fix CPU hotplug callback
 registration
Date: Thu, 06 Feb 2014 20:39:21 -0800 (PST)
Message-ID: <20140206.203921.888218847049631688.davem@davemloft.net>
References: <20140205220251.19080.92336.stgit@srivatsabhat.in.ibm.com>
	<20140205221345.19080.20784.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, oleg@redhat.com, rusty@rustcorp.com.au,
	peterz@infradead.org, tglx@linutronix.de,
	akpm@linux-foundation.org, mingo@kernel.org,
	paulmck@linux.vnet.ibm.com, tj@kernel.org, walken@google.com,
	ego@linux.vnet.ibm.com, linux@arm.linux.org.uk,
	linux-kernel@vger.kernel.org, roy.qing.li@gmail.com,
	sasha.levin@oracle.com, cmetcalf@tilera.com, netdev@vger.kernel.org
To: srivatsa.bhat@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140205221345.19080.20784.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Date: Thu, 06 Feb 2014 03:43:46 +0530

> Subsystems that want to register CPU hotplug callbacks, as well as perform
> initialization for the CPUs that are already online, often do it as shown
> below:
 ...
> This is wrong, since it is prone to ABBA deadlocks involving the
> cpu_add_remove_lock and the cpu_hotplug.lock (when running concurrently
> with CPU hotplug operations).
> 
> Instead, the correct and race-free way of performing the callback
> registration is:
 ...
> Fix the code in net/core/flow.c by using this latter form of callback
> registration.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Li RongQing <roy.qing.li@gmail.com>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Chris Metcalf <cmetcalf@tilera.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>

Applied.
