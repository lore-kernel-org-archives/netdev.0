From: Jesper Nilsson <jesper.nilsson@axis.com>
Subject: Re: [PATCH v6 33/46] cris/smp: Use get/put_online_cpus_atomic() to
 prevent CPU offline
Date: Mon, 18 Feb 2013 14:07:12 +0100
Message-ID: <20130218130712.GO23529@axis.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
 <20130218124254.26245.4577.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	walken@google.com, vincent.guittot@linaro.org
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130218124254.26245.4577.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 18, 2013 at 06:12:54PM +0530, Srivatsa S. Bhat wrote:
> Once stop_machine() is gone from the CPU offline path, we won't be able to
> depend on preempt_disable() or local_irq_disable() to prevent CPUs from
> going offline from under us.
> 
> Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going offline,
> while invoking from atomic context.
> 
> Cc: Mikael Starvik <starvik@axis.com>

> Cc: linux-cris-kernel@axis.com
> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>

Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>

/^JN - Jesper Nilsson
-- 
               Jesper Nilsson -- jesper.nilsson@axis.com
