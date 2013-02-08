From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v5 00/45] CPU hotplug: stop_machine()-free CPU hotplug
Date: Fri, 8 Feb 2013 15:41:13 +0000
Message-ID: <20130208154113.GV17833@n2100.arm.linux.org.uk>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com> <510FBC01.2030405@linux.vnet.ibm.com> <87haloiwv0.fsf@rustcorp.com.au> <51134596.4080106@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, tglx@linutronix.de,
	peterz@infradead.org, tj@kernel.org, oleg@redhat.com,
	paulmck@linux.vnet.ibm.com, mingo@kernel.org,
	linux-arch@vger.kernel.org, nikunj@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, fweisbec@gmail.com,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	rostedt@goodmis.org, xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl,
	sbw@mit.edu, wangyun@linux.vnet.ibm.com, netdev@vger.kernel.org,
	namhyung@kernel.org, akpm@linux-foundation.org, walken@google.com,
	linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51134596.4080106@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 07, 2013 at 11:41:34AM +0530, Srivatsa S. Bhat wrote:
> On 02/07/2013 09:44 AM, Rusty Russell wrote:
> > "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com> writes:
> >> On 01/22/2013 01:03 PM, Srivatsa S. Bhat wrote:
> >>                  Avg. latency of 1 CPU offline (ms) [stop-cpu/stop-m/c latency]
> >>
> >> # online CPUs    Mainline (with stop-m/c)       This patchset (no stop-m/c)
> >>
> >>       8                 17.04                          7.73
> >>
> >>      16                 18.05                          6.44
> >>
> >>      32                 17.31                          7.39
> >>
> >>      64                 32.40                          9.28
> >>
> >>     128                 98.23                          7.35
> > 
> > Nice!
> 
> Thank you :-)
> 
> >  I wonder how the ARM guys feel with their quad-cpu systems...
> > 
> 
> That would be definitely interesting to know :-)

That depends what exactly you'd like tested (and how) and whether you'd
like it to be a test-chip based quad core, or an OMAP dual-core SoC.
