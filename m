From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 15/45] rcu: Use get/put_online_cpus_atomic() to
 prevent CPU offline
Date: Wed, 26 Jun 2013 07:45:24 -0700
Message-ID: <20130626144524.GQ3828@linux.vnet.ibm.com>
References: <20130625202452.16593.22810.stgit@srivatsabhat.in.ibm.com>
 <20130625202755.16593.67819.stgit@srivatsabhat.in.ibm.com>
 <20130625220026.GG3828@linux.vnet.ibm.com>
 <51CAF624.6060004@linux.vnet.ibm.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B72AA@saturn3.aculab.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, fweisbec@gmail.com, oleg@redhat.com,
 walken@google.com, mingo@kernel.org, linux-arch@vger.kernel.org,
 vincent.guittot@linaro.org, xiaoguangrong@linux.vnet.ibm.com,
 wangyun@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
 linux-pm@vger.kernel.org, rusty@rustcorp.com.au, rostedt@goodmis.org,
 namhyung@kernel.org, tglx@linutronix.de, laijs@cn.fujitsu.com,
 zhong@linux.vnet.ibm.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 sbw@mit.edu, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
 tj@kernel.org, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: David Laight <David.Laight@aculab.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B72AA@saturn3.aculab.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

On Wed, Jun 26, 2013 at 03:29:40PM +0100, David Laight wrote:
> > Once stop_machine() is gone from the CPU offline path, we won't be able
> > to depend on disabling preemption to prevent CPUs from going offline
> > from under us.
> 
> Could you use an rcu-like sequence so that disabling pre-emption
> would be enough?
> 
> Something like rebuilding the cpu list, then forcing yourself
> to run on all the cpu.
> 
> That would be far less intrusive.

Maybe...  I must defer to Srivatsa on this question.

							Thanx, Paul
