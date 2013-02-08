From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 08/45] CPU hotplug: Convert preprocessor macros to
 static inline functions
Date: Fri, 8 Feb 2013 15:51:22 -0800
Message-ID: <20130208235122.GO2666@linux.vnet.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
 <20130122073500.13822.11469.stgit@srivatsabhat.in.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, rusty@rustcorp.com.au, mingo@kernel.org,
	akpm@linux-foundation.org, namhyung@kernel.org,
	rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130122073500.13822.11469.stgit@srivatsabhat.in.ibm.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 22, 2013 at 01:05:02PM +0530, Srivatsa S. Bhat wrote:
> On 12/05/2012 06:10 AM, Andrew Morton wrote:
> "static inline C functions would be preferred if possible.  Feel free to
> fix up the wrong crufty surrounding code as well ;-)"
> 
> Convert the macros in the CPU hotplug code to static inline C functions.
> 
> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> ---
> 
>  include/linux/cpu.h |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/cpu.h b/include/linux/cpu.h
> index cf24da1..eb79f47 100644
> --- a/include/linux/cpu.h
> +++ b/include/linux/cpu.h
> @@ -198,10 +198,10 @@ static inline void cpu_hotplug_driver_unlock(void)
> 
>  #else		/* CONFIG_HOTPLUG_CPU */
> 
> -#define get_online_cpus()	do { } while (0)
> -#define put_online_cpus()	do { } while (0)
> -#define get_online_cpus_atomic()	do { } while (0)
> -#define put_online_cpus_atomic()	do { } while (0)
> +static inline void get_online_cpus(void) {}
> +static inline void put_online_cpus(void) {}
> +static inline void get_online_cpus_atomic(void) {}
> +static inline void put_online_cpus_atomic(void) {}
>  #define hotcpu_notifier(fn, pri)	do { (void)(fn); } while (0)
>  /* These aren't inline functions due to a GCC bug. */
>  #define register_hotcpu_notifier(nb)	({ (void)(nb); 0; })
> 

