From: Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH-next 00/32] Delete support for __cpuinit
Date: Mon, 24 Jun 2013 16:00:21 -0400
Message-ID: <51C8A555.8090006@windriver.com>
References: <1372102237-8757-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-m32r-ja-rQhvJZKUsGBRYuoOT4C5/9i2O/JbrIOy@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-m32r-rQhvJZKUsGBRYuoOT4C5/9i2O/JbrIOy@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org,
        linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org,
        linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        cpufreq-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lm-sensors-GZX6beZjE8VD60Wz+7aTrA@public.gmane.org,
        linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org,
        x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Return-path: <uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
In-Reply-To: <1372102237-8757-1-git-send-email-paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
List-Unsubscribe: <https://blackfin.uclinux.org/mailman/options/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://blackfin.uclinux.org/pipermail/uclinux-dist-devel>
List-Post: <mailto:uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <https://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Errors-To: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

[Resending with only lists on Cc: -- previous mail header on the 00/32
 was too long; failed to get passed vger's crap filters.]

On 13-06-24 03:30 PM, Paul Gortmaker wrote:
> This is the whole patch queue for removal of __cpuinit support
> against the latest linux-next tree (Jun24th).  Some of you may
> have already seen chunks of it, or already read the logistics
> of what is being done (and why) here:
> 
>   https://lkml.org/lkml/2013/6/20/513
> 
> I won't repeat all that here again, other than to say this send
> is to ensure arch/subsystem maintainers get a 2nd chance to know
> what is going on and to look at what is being proposed for their
> area of code.  That, and to ensure one complete continuous copy
> of it gets mailed out.  You can also see the patch queue here:
> 
>   http://git.kernel.org/cgit/linux/kernel/git/paulg/cpuinit-delete.git
> 
> If you've noticed that a chunk for MIPS isn't present here, that
> is because it has already been queued in the linux-mips for-next
> branch.
> 
> Thanks,
> Paul.
> 
> ---
> Cc: Len Brown <lenb-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
> Cc: Richard Henderson <rth-hL46jP5Bxq7R7s880joybQ@public.gmane.org>
> Cc: Ivan Kokshaysky <ink-biIs/Y0ymYJMZLIVYojuPNP0rXTJTi09@public.gmane.org>
> Cc: Matt Turner <mattst88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Vineet Gupta <vgupta-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
> Cc: Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
> Cc: Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>
> Cc: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>
> Cc: Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>
> Cc: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
> Cc: Bob Liu <lliubbo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Sonic Zhang <sonic.zhang-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org>
> Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
> Cc: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> Cc: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
> Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
> Cc: Viresh Kumar <viresh.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> Cc: Mikael Starvik <starvik-VrBV9hrLPhE@public.gmane.org>
> Cc: Jesper Nilsson <jesper.nilsson-VrBV9hrLPhE@public.gmane.org>
> Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
> Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Richard Kuo <rkuo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
> Cc: Fenghua Yu <fenghua.yu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Cc: Tony Luck <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Cc: Fenghua Yu <fenghua.yu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Cc: Hirokazu Takata <takata-TMSiXQfHlQjsTix1lMzHGQ@public.gmane.org>
> Cc: James Hogan <james.hogan-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
> Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> Cc: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: Jonas Bonn <jonas-A9uVI2HLR7kOP4wsBPIw7w@public.gmane.org>
> Cc: Helge Deller <deller-Mmb7MZpHnFY@public.gmane.org>
> Cc: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
> Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
> Cc: Josh Boyer <jwboyer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Matt Porter <mporter-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
> Cc: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
> Cc: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Cc: Josh Triplett <josh-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org>
> Cc: Dipankar Sarma <dipankar-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
> Cc: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
> Cc: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
> Cc: Chen Liqin <liqin.chen-+XGAvkf1AAHby3iVrkZq2A@public.gmane.org>
> Cc: Lennox Wu <lennox.wu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Paul Mundt <lethal-M7jkjyW5wf5g9hUCZPvPmw@public.gmane.org>
> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: Chris Metcalf <cmetcalf-kv+TWInifGbQT0dZR+AlfA@public.gmane.org>
> Cc: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
> Cc: Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
> Cc: Chris Zankel <chris-YvXeqwSYzG2sTnJN9+BGXg@public.gmane.org>
> Cc: Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> Cc: uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
> Cc: cpufreq-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-cris-kernel-VrBV9hrLPhE@public.gmane.org
> Cc: linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: lm-sensors-GZX6beZjE8VD60Wz+7aTrA@public.gmane.org
> Cc: linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-m32r-rQhvJZKUsGBRYuoOT4C5/9i2O/JbrIOy@public.gmane.org
> Cc: linux-m32r-ja-rQhvJZKUsGBRYuoOT4C5/9i2O/JbrIOy@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-ZwoEplunGu2h2975yA52AaxOck334EZe@public.gmane.org
> Cc: linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
> Cc: linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
> Cc: linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
> Cc: linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org
> 
> Paul Gortmaker (32):
>   init.h: remove __cpuinit sections from the kernel
>   modpost: remove all traces of cpuinit/cpuexit sections
>   alpha: delete __cpuinit usage from all users
>   powerpc: delete __cpuinit usage from all users
>   parisc: delete __cpuinit usage from all users
>   ia64: delete __cpuinit usage from all ia64 users
>   arm: delete __cpuinit/__CPUINIT usage from all ARM users
>   sparc: delete __cpuinit/__CPUINIT usage from all users
>   arm64: delete __cpuinit usage from all users
>   arc: delete __cpuinit usage from all arc files
>   blackfin: delete __cpuinit usage from all blackfin files
>   s390: delete __cpuinit usage from all s390 files
>   sh: delete __cpuinit usage from all sh files
>   tile: delete __cpuinit usage from all tile files
>   metag: delete __cpuinit usage from all metag files
>   cris: delete __cpuinit usage from all cris files
>   frv: delete __cpuinit usage from all frv files
>   hexagon: delete __cpuinit usage from all hexagon files
>   m32r: delete __cpuinit usage from all m32r files
>   openrisc: delete __cpuinit usage from all openrisc files
>   xtensa: delete __cpuinit usage from all xtensa files
>   score: delete __cpuinit usage from all score files
>   x86: delete __cpuinit usage from all x86 files
>   clocksource+irqchip: delete __cpuinit usage from all related files
>   cpufreq: delete __cpuinit usage from all cpufreq files
>   hwmon: delete __cpuinit usage from all hwmon files
>   acpi: delete __cpuinit usage from all acpi files
>   net: delete __cpuinit usage from all net files
>   rcu: delete __cpuinit usage from all rcu files
>   kernel: delete __cpuinit usage from all core kernel files
>   drivers: delete __cpuinit usage from all remaining drivers files
>   block: delete __cpuinit usage from all block files
> 
>  Documentation/cpu-hotplug.txt                 |  6 +--
>  arch/alpha/kernel/smp.c                       | 10 ++---
>  arch/alpha/kernel/traps.c                     |  4 +-
>  arch/arc/include/asm/irq.h                    |  2 +-
>  arch/arc/kernel/irq.c                         |  2 +-
>  arch/arc/kernel/setup.c                       | 10 ++---
>  arch/arc/kernel/smp.c                         |  4 +-
>  arch/arc/kernel/time.c                        |  6 +--
>  arch/arc/mm/cache_arc700.c                    |  4 +-
>  arch/arc/mm/tlb.c                             |  4 +-
>  arch/arm/common/mcpm_platsmp.c                |  4 +-
>  arch/arm/include/asm/arch_timer.h             |  2 +-
>  arch/arm/kernel/head-common.S                 |  1 -
>  arch/arm/kernel/head.S                        |  1 -
>  arch/arm/kernel/hw_breakpoint.c               |  4 +-
>  arch/arm/kernel/perf_event_cpu.c              |  6 +--
>  arch/arm/kernel/psci_smp.c                    |  3 +-
>  arch/arm/kernel/smp.c                         | 18 ++++----
>  arch/arm/kernel/smp_twd.c                     |  6 +--
>  arch/arm/lib/delay.c                          |  2 +-
>  arch/arm/mach-exynos/headsmp.S                |  2 -
>  arch/arm/mach-exynos/platsmp.c                |  4 +-
>  arch/arm/mach-highbank/platsmp.c              |  2 +-
>  arch/arm/mach-imx/platsmp.c                   |  2 +-
>  arch/arm/mach-msm/headsmp.S                   |  2 -
>  arch/arm/mach-msm/platsmp.c                   |  6 +--
>  arch/arm/mach-msm/timer.c                     |  4 +-
>  arch/arm/mach-mvebu/coherency.c               |  2 +-
>  arch/arm/mach-mvebu/headsmp.S                 |  2 -
>  arch/arm/mach-mvebu/platsmp.c                 |  5 +--
>  arch/arm/mach-omap2/omap-headsmp.S            |  2 -
>  arch/arm/mach-omap2/omap-mpuss-lowpower.c     |  2 +-
>  arch/arm/mach-omap2/omap-smp.c                |  4 +-
>  arch/arm/mach-omap2/omap-wakeupgen.c          |  4 +-
>  arch/arm/mach-prima2/headsmp.S                |  2 -
>  arch/arm/mach-prima2/platsmp.c                |  4 +-
>  arch/arm/mach-shmobile/headsmp-scu.S          |  1 -
>  arch/arm/mach-shmobile/headsmp.S              |  2 -
>  arch/arm/mach-shmobile/smp-emev2.c            |  2 +-
>  arch/arm/mach-shmobile/smp-r8a7779.c          |  2 +-
>  arch/arm/mach-shmobile/smp-sh73a0.c           |  2 +-
>  arch/arm/mach-socfpga/headsmp.S               |  1 -
>  arch/arm/mach-socfpga/platsmp.c               |  2 +-
>  arch/arm/mach-spear/generic.h                 |  2 +-
>  arch/arm/mach-spear/platsmp.c                 |  4 +-
>  arch/arm/mach-tegra/platsmp.c                 |  4 +-
>  arch/arm/mach-tegra/pm.c                      |  2 +-
>  arch/arm/mach-ux500/platsmp.c                 |  4 +-
>  arch/arm/mach-zynq/common.h                   |  2 +-
>  arch/arm/mach-zynq/headsmp.S                  |  2 -
>  arch/arm/mach-zynq/platsmp.c                  |  6 +--
>  arch/arm/mm/proc-arm1020.S                    |  2 -
>  arch/arm/mm/proc-arm1020e.S                   |  2 -
>  arch/arm/mm/proc-arm1022.S                    |  2 -
>  arch/arm/mm/proc-arm1026.S                    |  3 --
>  arch/arm/mm/proc-arm720.S                     |  2 -
>  arch/arm/mm/proc-arm740.S                     |  2 -
>  arch/arm/mm/proc-arm7tdmi.S                   |  2 -
>  arch/arm/mm/proc-arm920.S                     |  2 -
>  arch/arm/mm/proc-arm922.S                     |  2 -
>  arch/arm/mm/proc-arm925.S                     |  2 -
>  arch/arm/mm/proc-arm926.S                     |  2 -
>  arch/arm/mm/proc-arm940.S                     |  2 -
>  arch/arm/mm/proc-arm946.S                     |  2 -
>  arch/arm/mm/proc-arm9tdmi.S                   |  2 -
>  arch/arm/mm/proc-fa526.S                      |  2 -
>  arch/arm/mm/proc-feroceon.S                   |  2 -
>  arch/arm/mm/proc-mohawk.S                     |  2 -
>  arch/arm/mm/proc-sa110.S                      |  2 -
>  arch/arm/mm/proc-sa1100.S                     |  2 -
>  arch/arm/mm/proc-v6.S                         |  2 -
>  arch/arm/mm/proc-v7-2level.S                  |  4 --
>  arch/arm/mm/proc-v7-3level.S                  |  4 --
>  arch/arm/mm/proc-v7.S                         |  2 -
>  arch/arm/mm/proc-xsc3.S                       |  2 -
>  arch/arm/mm/proc-xscale.S                     |  2 -
>  arch/arm/plat-versatile/platsmp.c             |  6 +--
>  arch/arm64/include/asm/arch_timer.h           |  2 +-
>  arch/arm64/kernel/debug-monitors.c            |  6 +--
>  arch/arm64/kernel/hw_breakpoint.c             |  4 +-
>  arch/arm64/kernel/smp.c                       |  8 ++--
>  arch/blackfin/kernel/perf_event.c             |  2 +-
>  arch/blackfin/kernel/setup.c                  |  4 +-
>  arch/blackfin/mach-bf561/smp.c                |  6 +--
>  arch/blackfin/mach-common/cache-c.c           |  4 +-
>  arch/blackfin/mach-common/ints-priority.c     |  2 +-
>  arch/blackfin/mach-common/smp.c               |  8 ++--
>  arch/cris/arch-v32/kernel/smp.c               |  2 +-
>  arch/frv/kernel/setup.c                       |  2 +-
>  arch/hexagon/kernel/setup.c                   |  2 +-
>  arch/hexagon/kernel/smp.c                     |  4 +-
>  arch/ia64/kernel/acpi.c                       |  4 +-
>  arch/ia64/kernel/err_inject.c                 |  8 ++--
>  arch/ia64/kernel/mca.c                        | 12 ++---
>  arch/ia64/kernel/numa.c                       |  4 +-
>  arch/ia64/kernel/palinfo.c                    |  4 +-
>  arch/ia64/kernel/salinfo.c                    |  4 +-
>  arch/ia64/kernel/setup.c                      | 10 ++---
>  arch/ia64/kernel/smpboot.c                    |  8 ++--
>  arch/ia64/kernel/topology.c                   | 18 ++++----
>  arch/ia64/mm/contig.c                         |  3 +-
>  arch/ia64/mm/discontig.c                      |  2 +-
>  arch/ia64/mm/numa.c                           |  2 +-
>  arch/ia64/sn/kernel/setup.c                   |  8 ++--
>  arch/ia64/xen/hypervisor.c                    |  2 +-
>  arch/m32r/kernel/smpboot.c                    |  2 +-
>  arch/metag/kernel/perf/perf_event.c           |  6 +--
>  arch/metag/kernel/smp.c                       | 16 +++----
>  arch/metag/kernel/traps.c                     |  2 +-
>  arch/openrisc/kernel/setup.c                  |  2 +-
>  arch/parisc/kernel/firmware.c                 | 14 +++---
>  arch/parisc/kernel/hardware.c                 |  2 +-
>  arch/parisc/kernel/processor.c                |  6 +--
>  arch/parisc/kernel/smp.c                      |  8 ++--
>  arch/powerpc/include/asm/rtas.h               |  4 +-
>  arch/powerpc/include/asm/vdso.h               |  2 +-
>  arch/powerpc/kernel/cacheinfo.c               | 36 ++++++++-------
>  arch/powerpc/kernel/rtas.c                    |  4 +-
>  arch/powerpc/kernel/smp.c                     |  4 +-
>  arch/powerpc/kernel/sysfs.c                   |  6 +--
>  arch/powerpc/kernel/time.c                    |  1 -
>  arch/powerpc/kernel/vdso.c                    |  2 +-
>  arch/powerpc/mm/44x_mmu.c                     |  6 +--
>  arch/powerpc/mm/hash_utils_64.c               |  2 +-
>  arch/powerpc/mm/mmu_context_nohash.c          |  6 +--
>  arch/powerpc/mm/numa.c                        |  7 ++-
>  arch/powerpc/mm/tlb_nohash.c                  |  2 +-
>  arch/powerpc/perf/core-book3s.c               |  4 +-
>  arch/powerpc/platforms/44x/currituck.c        |  4 +-
>  arch/powerpc/platforms/44x/iss4xx.c           |  4 +-
>  arch/powerpc/platforms/85xx/smp.c             |  6 +--
>  arch/powerpc/platforms/powermac/smp.c         |  2 +-
>  arch/powerpc/platforms/powernv/smp.c          |  2 +-
>  arch/s390/kernel/cache.c                      | 15 +++----
>  arch/s390/kernel/perf_cpum_cf.c               |  4 +-
>  arch/s390/kernel/processor.c                  |  2 +-
>  arch/s390/kernel/smp.c                        | 17 ++++---
>  arch/s390/kernel/sysinfo.c                    |  2 +-
>  arch/s390/kernel/vtime.c                      |  6 +--
>  arch/s390/mm/fault.c                          |  4 +-
>  arch/score/mm/tlb-score.c                     |  2 +-
>  arch/sh/kernel/cpu/init.c                     | 18 ++++----
>  arch/sh/kernel/cpu/sh2/probe.c                |  2 +-
>  arch/sh/kernel/cpu/sh2a/probe.c               |  2 +-
>  arch/sh/kernel/cpu/sh3/probe.c                |  2 +-
>  arch/sh/kernel/cpu/sh4/probe.c                |  2 +-
>  arch/sh/kernel/cpu/sh4a/smp-shx3.c            |  6 +--
>  arch/sh/kernel/cpu/sh5/probe.c                |  2 +-
>  arch/sh/kernel/perf_event.c                   |  4 +-
>  arch/sh/kernel/process.c                      |  2 +-
>  arch/sh/kernel/setup.c                        |  2 +-
>  arch/sh/kernel/smp.c                          |  8 ++--
>  arch/sh/kernel/traps_32.c                     |  2 +-
>  arch/sh/kernel/traps_64.c                     |  2 +-
>  arch/sh/mm/tlb-sh5.c                          |  2 +-
>  arch/sparc/kernel/ds.c                        | 11 ++---
>  arch/sparc/kernel/entry.h                     |  2 +-
>  arch/sparc/kernel/hvtramp.S                   |  1 -
>  arch/sparc/kernel/irq_64.c                    |  5 ++-
>  arch/sparc/kernel/leon_smp.c                  | 10 ++---
>  arch/sparc/kernel/mdesc.c                     | 34 +++++++-------
>  arch/sparc/kernel/smp_32.c                    | 20 ++++-----
>  arch/sparc/kernel/smp_64.c                    |  9 ++--
>  arch/sparc/kernel/sun4d_smp.c                 |  6 +--
>  arch/sparc/kernel/sun4m_smp.c                 |  6 +--
>  arch/sparc/kernel/sysfs.c                     |  4 +-
>  arch/sparc/kernel/trampoline_32.S             |  3 --
>  arch/sparc/kernel/trampoline_64.S             |  2 -
>  arch/sparc/mm/init_64.c                       |  2 +-
>  arch/sparc/mm/srmmu.c                         | 12 ++---
>  arch/tile/kernel/irq.c                        |  2 +-
>  arch/tile/kernel/messaging.c                  |  2 +-
>  arch/tile/kernel/setup.c                      | 12 ++---
>  arch/tile/kernel/smpboot.c                    |  8 ++--
>  arch/tile/kernel/time.c                       |  2 +-
>  arch/x86/include/asm/cpu.h                    |  2 +-
>  arch/x86/include/asm/microcode.h              |  4 +-
>  arch/x86/include/asm/microcode_intel.h        |  4 +-
>  arch/x86/include/asm/mmconfig.h               |  4 +-
>  arch/x86/include/asm/mpspec.h                 |  2 +-
>  arch/x86/include/asm/numa.h                   |  6 +--
>  arch/x86/include/asm/prom.h                   |  2 +-
>  arch/x86/include/asm/smp.h                    |  2 +-
>  arch/x86/kernel/acpi/boot.c                   |  6 +--
>  arch/x86/kernel/apic/apic.c                   | 30 ++++++-------
>  arch/x86/kernel/apic/apic_numachip.c          |  2 +-
>  arch/x86/kernel/apic/es7000_32.c              |  2 +-
>  arch/x86/kernel/apic/numaq_32.c               |  2 +-
>  arch/x86/kernel/apic/x2apic_cluster.c         |  2 +-
>  arch/x86/kernel/apic/x2apic_uv_x.c            | 14 +++---
>  arch/x86/kernel/cpu/amd.c                     | 33 +++++++-------
>  arch/x86/kernel/cpu/centaur.c                 | 26 +++++------
>  arch/x86/kernel/cpu/common.c                  | 64 +++++++++++++--------------
>  arch/x86/kernel/cpu/cyrix.c                   | 40 ++++++++---------
>  arch/x86/kernel/cpu/hypervisor.c              |  2 +-
>  arch/x86/kernel/cpu/intel.c                   | 30 ++++++-------
>  arch/x86/kernel/cpu/intel_cacheinfo.c         | 55 +++++++++++------------
>  arch/x86/kernel/cpu/mcheck/mce.c              | 23 +++++-----
>  arch/x86/kernel/cpu/mcheck/mce_amd.c          | 14 +++---
>  arch/x86/kernel/cpu/mcheck/therm_throt.c      |  9 ++--
>  arch/x86/kernel/cpu/perf_event.c              |  2 +-
>  arch/x86/kernel/cpu/perf_event_amd_ibs.c      |  2 +-
>  arch/x86/kernel/cpu/perf_event_amd_uncore.c   | 31 +++++++------
>  arch/x86/kernel/cpu/perf_event_intel_uncore.c | 20 ++++-----
>  arch/x86/kernel/cpu/rdrand.c                  |  2 +-
>  arch/x86/kernel/cpu/scattered.c               |  4 +-
>  arch/x86/kernel/cpu/topology.c                |  2 +-
>  arch/x86/kernel/cpu/transmeta.c               |  6 +--
>  arch/x86/kernel/cpu/umc.c                     |  2 +-
>  arch/x86/kernel/cpu/vmware.c                  |  2 +-
>  arch/x86/kernel/cpuid.c                       |  7 ++-
>  arch/x86/kernel/devicetree.c                  |  2 +-
>  arch/x86/kernel/head_32.S                     |  1 -
>  arch/x86/kernel/i387.c                        |  8 ++--
>  arch/x86/kernel/irq_32.c                      |  2 +-
>  arch/x86/kernel/kvm.c                         | 10 ++---
>  arch/x86/kernel/kvmclock.c                    |  2 +-
>  arch/x86/kernel/microcode_core.c              |  2 +-
>  arch/x86/kernel/microcode_core_early.c        |  6 +--
>  arch/x86/kernel/microcode_intel_early.c       | 26 +++++------
>  arch/x86/kernel/mmconf-fam10h_64.c            | 12 ++---
>  arch/x86/kernel/msr.c                         |  6 +--
>  arch/x86/kernel/process.c                     |  2 +-
>  arch/x86/kernel/setup.c                       |  2 +-
>  arch/x86/kernel/smpboot.c                     | 28 ++++++------
>  arch/x86/kernel/tboot.c                       |  6 +--
>  arch/x86/kernel/tsc.c                         |  4 +-
>  arch/x86/kernel/tsc_sync.c                    | 18 ++++----
>  arch/x86/kernel/vsyscall_64.c                 |  6 +--
>  arch/x86/kernel/x86_init.c                    |  4 +-
>  arch/x86/kernel/xsave.c                       |  4 +-
>  arch/x86/mm/mmio-mod.c                        |  4 +-
>  arch/x86/mm/numa.c                            | 12 ++---
>  arch/x86/mm/numa_emulation.c                  | 12 ++---
>  arch/x86/mm/setup_nx.c                        |  4 +-
>  arch/x86/pci/amd_bus.c                        |  8 ++--
>  arch/x86/platform/ce4100/ce4100.c             |  2 +-
>  arch/x86/platform/mrst/mrst.c                 |  4 +-
>  arch/x86/xen/enlighten.c                      |  6 +--
>  arch/x86/xen/setup.c                          |  6 +--
>  arch/x86/xen/smp.c                            | 12 ++---
>  arch/x86/xen/spinlock.c                       |  2 +-
>  arch/x86/xen/xen-ops.h                        |  2 +-
>  arch/xtensa/kernel/time.c                     |  2 +-
>  block/blk-iopoll.c                            |  6 +--
>  block/blk-softirq.c                           |  6 +--
>  drivers/acpi/acpi_processor.c                 |  2 +-
>  drivers/acpi/processor_core.c                 |  8 ++--
>  drivers/acpi/processor_driver.c               |  8 ++--
>  drivers/acpi/processor_idle.c                 |  6 +--
>  drivers/base/cpu.c                            |  2 +-
>  drivers/base/topology.c                       | 10 ++---
>  drivers/clocksource/arm_arch_timer.c          |  8 ++--
>  drivers/clocksource/exynos_mct.c              |  4 +-
>  drivers/clocksource/metag_generic.c           |  6 +--
>  drivers/clocksource/time-armada-370-xp.c      |  4 +-
>  drivers/clocksource/timer-marco.c             |  4 +-
>  drivers/cpufreq/cpufreq.c                     |  4 +-
>  drivers/cpufreq/cpufreq_stats.c               |  4 +-
>  drivers/cpufreq/dbx500-cpufreq.c              |  2 +-
>  drivers/cpufreq/intel_pstate.c                |  4 +-
>  drivers/cpufreq/longhaul.c                    |  6 +--
>  drivers/cpufreq/longhaul.h                    | 26 +++++------
>  drivers/cpufreq/longrun.c                     |  8 ++--
>  drivers/cpufreq/omap-cpufreq.c                |  2 +-
>  drivers/cpufreq/powernow-k7.c                 |  8 ++--
>  drivers/cpufreq/powernow-k8.c                 |  6 +--
>  drivers/hwmon/coretemp.c                      | 39 ++++++++--------
>  drivers/hwmon/via-cputemp.c                   |  8 ++--
>  drivers/irqchip/irq-gic.c                     |  8 ++--
>  drivers/oprofile/timer_int.c                  |  4 +-
>  drivers/xen/xen-acpi-cpuhotplug.c             |  2 +-
>  include/asm-generic/vmlinux.lds.h             | 12 -----
>  include/linux/cpu.h                           |  2 +-
>  include/linux/init.h                          | 19 ++++----
>  include/linux/perf_event.h                    |  2 +-
>  init/calibrate.c                              | 13 +++---
>  kernel/cpu.c                                  |  6 +--
>  kernel/events/core.c                          |  4 +-
>  kernel/fork.c                                 |  2 +-
>  kernel/hrtimer.c                              |  6 +--
>  kernel/printk.c                               |  2 +-
>  kernel/profile.c                              |  2 +-
>  kernel/rcutorture.c                           |  6 +--
>  kernel/rcutree.c                              |  6 +--
>  kernel/rcutree.h                              |  4 +-
>  kernel/rcutree_plugin.h                       |  6 +--
>  kernel/relay.c                                |  2 +-
>  kernel/sched/core.c                           | 12 ++---
>  kernel/sched/fair.c                           |  2 +-
>  kernel/smp.c                                  |  2 +-
>  kernel/smpboot.c                              |  2 +-
>  kernel/softirq.c                              |  8 ++--
>  kernel/time/tick-sched.c                      |  2 +-
>  kernel/timer.c                                | 10 ++---
>  kernel/workqueue.c                            |  4 +-
>  lib/Kconfig.debug                             |  2 +-
>  lib/earlycpio.c                               |  2 +-
>  lib/percpu_counter.c                          |  2 +-
>  mm/memcontrol.c                               |  2 +-
>  mm/page-writeback.c                           |  4 +-
>  mm/slab.c                                     | 10 ++---
>  mm/slub.c                                     |  4 +-
>  mm/vmstat.c                                   |  6 +--
>  net/core/flow.c                               |  4 +-
>  net/iucv/iucv.c                               |  2 +-
>  scripts/mod/modpost.c                         | 52 ++++------------------
>  307 files changed, 896 insertions(+), 1037 deletions(-)
> 
