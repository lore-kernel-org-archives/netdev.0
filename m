From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v5 00/45] CPU hotplug: stop_machine()-free CPU hotplug
Date: Thu, 07 Feb 2013 14:44:27 +1030
Message-ID: <87haloiwv0.fsf@rustcorp.com.au>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com> <510FBC01.2030405@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	akpm@linux-foundation.org, namhyung@kernel.org,
	rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	walken@google.com
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, mingo@kernel.org
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <510FBC01.2030405@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com> writes:
> On 01/22/2013 01:03 PM, Srivatsa S. Bhat wrote:
>                  Avg. latency of 1 CPU offline (ms) [stop-cpu/stop-m/c latency]
>
> # online CPUs    Mainline (with stop-m/c)       This patchset (no stop-m/c)
>
>       8                 17.04                          7.73
>
>      16                 18.05                          6.44
>
>      32                 17.31                          7.39
>
>      64                 32.40                          9.28
>
>     128                 98.23                          7.35

Nice!  I wonder how the ARM guys feel with their quad-cpu systems...

Thanks!
Rusty.
