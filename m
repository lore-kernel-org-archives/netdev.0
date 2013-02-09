From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 44/45] CPU hotplug, stop_machine: Decouple CPU hotplug
 from stop_machine() in Kconfig
Date: Fri, 8 Feb 2013 16:15:54 -0800
Message-ID: <20130209001554.GR2666@linux.vnet.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
 <20130122074518.13822.86992.stgit@srivatsabhat.in.ibm.com>
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
Return-path: <linux-pm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130122074518.13822.86992.stgit@srivatsabhat.in.ibm.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 22, 2013 at 01:15:22PM +0530, Srivatsa S. Bhat wrote:
> ... and also cleanup a comment that refers to CPU hotplug being dependent on
> stop_machine().
> 
> Cc: David Howells <dhowells@redhat.com>
> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

(Hey, I thought I owed myself an easy one!)

> ---
> 
>  include/linux/stop_machine.h |    2 +-
>  init/Kconfig                 |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/stop_machine.h b/include/linux/stop_machine.h
> index 3b5e910..ce2d3c4 100644
> --- a/include/linux/stop_machine.h
> +++ b/include/linux/stop_machine.h
> @@ -120,7 +120,7 @@ int stop_machine(int (*fn)(void *), void *data, const struct cpumask *cpus);
>   * @cpus: the cpus to run the @fn() on (NULL = any online cpu)
>   *
>   * Description: This is a special version of the above, which assumes cpus
> - * won't come or go while it's being called.  Used by hotplug cpu.
> + * won't come or go while it's being called.
>   */
>  int __stop_machine(int (*fn)(void *), void *data, const struct cpumask *cpus);
> 
> diff --git a/init/Kconfig b/init/Kconfig
> index be8b7f5..048a0c5 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1711,7 +1711,7 @@ config INIT_ALL_POSSIBLE
>  config STOP_MACHINE
>  	bool
>  	default y
> -	depends on (SMP && MODULE_UNLOAD) || HOTPLUG_CPU
> +	depends on (SMP && MODULE_UNLOAD)
>  	help
>  	  Need stop_machine() primitive.
> 
> 

