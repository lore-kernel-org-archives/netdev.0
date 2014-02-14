From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 52/52] net/iucv/iucv.c: Fix CPU hotplug callback
 registration
Date: Fri, 14 Feb 2014 13:31:47 -0500 (EST)
Message-ID: <20140214.133147.1908176449942033339.davem@davemloft.net>
References: <20140214074750.22701.47330.stgit@srivatsabhat.in.ibm.com>
	<20140214080057.22701.94737.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, oleg@redhat.com, mingo@kernel.org,
	rusty@rustcorp.com.au, peterz@infradead.org, tglx@linutronix.de,
	akpm@linux-foundation.org, paulmck@linux.vnet.ibm.com,
	tj@kernel.org, walken@google.com, ego@linux.vnet.ibm.com,
	linux@arm.linux.org.uk, rjw@rjwysocki.net,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	ursula.braun@de.ibm.com, linux-s390@vger.kernel.org,
	netdev@vger.kernel.org
To: srivatsa.bhat@linux.vnet.ibm.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20140214080057.22701.94737.stgit@srivatsabhat.in.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Date: Fri, 14 Feb 2014 13:30:58 +0530

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
> Fix the code in net/iucv/iucv.c by using this latter form of callback
> registration. Also, provide helper functions to perform the common memory
> allocations and frees, to condense repetitive code.
> 
> Cc: Ursula Braun <ursula.braun@de.ibm.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: linux-s390@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>

Acked-by: David S. Miller <davem@davemloft.net>
