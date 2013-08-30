From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 1/8] Drop support for Renesas H8/300 (h8300) architecture
Date: Fri, 30 Aug 2013 16:51:27 -0700
Message-ID: <1377906694-9578-2-git-send-email-linux@roeck-us.net>
References: <1377906694-9578-1-git-send-email-linux@roeck-us.net>
Cc: linux-ide@vger.kernel.org, netdev@vger.kernel.org,
	linux-watchdog@vger.kernel.org, Wim Van Sebroeck <wim@iguana.be>,
	"David S. Miller" <davem@davemloft.net>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Eric Paris <eparis@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiang Liu <jiang.liu@huawei.com>,
	David Howells <dhowells@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Guenter Roeck <linux@roeck-us.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377906694-9578-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

H8/300 has been dead for several years, and the kernel for it
has not compiled for ages. Drop support for it.

Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 Documentation/scheduler/sched-arch.txt           |    5 -
 arch/h8300/Kconfig                               |  109 ------
 arch/h8300/Kconfig.cpu                           |  171 ---------
 arch/h8300/Kconfig.debug                         |   68 ----
 arch/h8300/Kconfig.ide                           |   44 ---
 arch/h8300/Makefile                              |   71 ----
 arch/h8300/README                                |   38 --
 arch/h8300/boot/Makefile                         |   22 --
 arch/h8300/boot/compressed/Makefile              |   37 --
 arch/h8300/boot/compressed/head.S                |   47 ---
 arch/h8300/boot/compressed/misc.c                |  180 ---------
 arch/h8300/boot/compressed/vmlinux.lds           |   32 --
 arch/h8300/boot/compressed/vmlinux.scr           |    9 -
 arch/h8300/defconfig                             |   42 --
 arch/h8300/include/asm/Kbuild                    |    8 -
 arch/h8300/include/asm/asm-offsets.h             |    1 -
 arch/h8300/include/asm/atomic.h                  |  146 -------
 arch/h8300/include/asm/barrier.h                 |   29 --
 arch/h8300/include/asm/bitops.h                  |  211 ----------
 arch/h8300/include/asm/bootinfo.h                |    2 -
 arch/h8300/include/asm/bug.h                     |   12 -
 arch/h8300/include/asm/bugs.h                    |   16 -
 arch/h8300/include/asm/cache.h                   |   13 -
 arch/h8300/include/asm/cachectl.h                |   14 -
 arch/h8300/include/asm/cacheflush.h              |   40 --
 arch/h8300/include/asm/checksum.h                |  102 -----
 arch/h8300/include/asm/cmpxchg.h                 |   60 ---
 arch/h8300/include/asm/cputime.h                 |    6 -
 arch/h8300/include/asm/current.h                 |   25 --
 arch/h8300/include/asm/dbg.h                     |    2 -
 arch/h8300/include/asm/delay.h                   |   38 --
 arch/h8300/include/asm/device.h                  |    7 -
 arch/h8300/include/asm/div64.h                   |    1 -
 arch/h8300/include/asm/dma.h                     |   15 -
 arch/h8300/include/asm/elf.h                     |  101 -----
 arch/h8300/include/asm/emergency-restart.h       |    6 -
 arch/h8300/include/asm/fb.h                      |   12 -
 arch/h8300/include/asm/flat.h                    |   26 --
 arch/h8300/include/asm/fpu.h                     |    1 -
 arch/h8300/include/asm/ftrace.h                  |    1 -
 arch/h8300/include/asm/futex.h                   |    6 -
 arch/h8300/include/asm/gpio-internal.h           |   52 ---
 arch/h8300/include/asm/hardirq.h                 |   19 -
 arch/h8300/include/asm/hw_irq.h                  |    1 -
 arch/h8300/include/asm/io.h                      |  358 -----------------
 arch/h8300/include/asm/irq.h                     |   49 ---
 arch/h8300/include/asm/irq_regs.h                |    1 -
 arch/h8300/include/asm/irqflags.h                |   43 ---
 arch/h8300/include/asm/kdebug.h                  |    1 -
 arch/h8300/include/asm/kmap_types.h              |    6 -
 arch/h8300/include/asm/local.h                   |    6 -
 arch/h8300/include/asm/local64.h                 |    1 -
 arch/h8300/include/asm/mc146818rtc.h             |    9 -
 arch/h8300/include/asm/mmu_context.h             |   32 --
 arch/h8300/include/asm/mutex.h                   |    9 -
 arch/h8300/include/asm/page.h                    |   78 ----
 arch/h8300/include/asm/page_offset.h             |    3 -
 arch/h8300/include/asm/param.h                   |    9 -
 arch/h8300/include/asm/pci.h                     |   19 -
 arch/h8300/include/asm/percpu.h                  |    6 -
 arch/h8300/include/asm/pgalloc.h                 |    8 -
 arch/h8300/include/asm/pgtable.h                 |   73 ----
 arch/h8300/include/asm/processor.h               |  139 -------
 arch/h8300/include/asm/ptrace.h                  |   33 --
 arch/h8300/include/asm/regs267x.h                |  336 ----------------
 arch/h8300/include/asm/regs306x.h                |  212 -----------
 arch/h8300/include/asm/scatterlist.h             |    6 -
 arch/h8300/include/asm/sections.h                |    6 -
 arch/h8300/include/asm/segment.h                 |   49 ---
 arch/h8300/include/asm/sh_bios.h                 |   29 --
 arch/h8300/include/asm/shm.h                     |   31 --
 arch/h8300/include/asm/shmparam.h                |    6 -
 arch/h8300/include/asm/signal.h                  |   24 --
 arch/h8300/include/asm/smp.h                     |    1 -
 arch/h8300/include/asm/spinlock.h                |    6 -
 arch/h8300/include/asm/string.h                  |   44 ---
 arch/h8300/include/asm/switch_to.h               |   50 ---
 arch/h8300/include/asm/target_time.h             |    4 -
 arch/h8300/include/asm/termios.h                 |   50 ---
 arch/h8300/include/asm/thread_info.h             |  103 -----
 arch/h8300/include/asm/timer.h                   |   25 --
 arch/h8300/include/asm/timex.h                   |   19 -
 arch/h8300/include/asm/tlb.h                     |    8 -
 arch/h8300/include/asm/tlbflush.h                |   55 ---
 arch/h8300/include/asm/topology.h                |    6 -
 arch/h8300/include/asm/traps.h                   |   37 --
 arch/h8300/include/asm/types.h                   |    9 -
 arch/h8300/include/asm/uaccess.h                 |  163 --------
 arch/h8300/include/asm/ucontext.h                |   12 -
 arch/h8300/include/asm/unaligned.h               |   11 -
 arch/h8300/include/asm/unistd.h                  |   36 --
 arch/h8300/include/asm/user.h                    |   75 ----
 arch/h8300/include/asm/virtconvert.h             |   20 -
 arch/h8300/include/uapi/asm/Kbuild               |   34 --
 arch/h8300/include/uapi/asm/auxvec.h             |    4 -
 arch/h8300/include/uapi/asm/bitsperlong.h        |    1 -
 arch/h8300/include/uapi/asm/byteorder.h          |    6 -
 arch/h8300/include/uapi/asm/errno.h              |    6 -
 arch/h8300/include/uapi/asm/fcntl.h              |   11 -
 arch/h8300/include/uapi/asm/ioctl.h              |    1 -
 arch/h8300/include/uapi/asm/ioctls.h             |    8 -
 arch/h8300/include/uapi/asm/ipcbuf.h             |    1 -
 arch/h8300/include/uapi/asm/kvm_para.h           |    1 -
 arch/h8300/include/uapi/asm/mman.h               |    1 -
 arch/h8300/include/uapi/asm/msgbuf.h             |   31 --
 arch/h8300/include/uapi/asm/param.h              |   16 -
 arch/h8300/include/uapi/asm/poll.h               |   11 -
 arch/h8300/include/uapi/asm/posix_types.h        |   26 --
 arch/h8300/include/uapi/asm/ptrace.h             |   44 ---
 arch/h8300/include/uapi/asm/resource.h           |    6 -
 arch/h8300/include/uapi/asm/sembuf.h             |   25 --
 arch/h8300/include/uapi/asm/setup.h              |    6 -
 arch/h8300/include/uapi/asm/shmbuf.h             |   42 --
 arch/h8300/include/uapi/asm/sigcontext.h         |   18 -
 arch/h8300/include/uapi/asm/siginfo.h            |    6 -
 arch/h8300/include/uapi/asm/signal.h             |  115 ------
 arch/h8300/include/uapi/asm/socket.h             |   79 ----
 arch/h8300/include/uapi/asm/sockios.h            |   13 -
 arch/h8300/include/uapi/asm/stat.h               |   78 ----
 arch/h8300/include/uapi/asm/statfs.h             |    6 -
 arch/h8300/include/uapi/asm/swab.h               |   10 -
 arch/h8300/include/uapi/asm/termbits.h           |  201 ----------
 arch/h8300/include/uapi/asm/termios.h            |   44 ---
 arch/h8300/include/uapi/asm/types.h              |    1 -
 arch/h8300/include/uapi/asm/unistd.h             |  330 ----------------
 arch/h8300/kernel/Makefile                       |   12 -
 arch/h8300/kernel/asm-offsets.c                  |   60 ---
 arch/h8300/kernel/entry.S                        |  402 --------------------
 arch/h8300/kernel/gpio.c                         |  178 ---------
 arch/h8300/kernel/h8300_ksyms.c                  |  100 -----
 arch/h8300/kernel/irq.c                          |  165 --------
 arch/h8300/kernel/module.c                       |   75 ----
 arch/h8300/kernel/process.c                      |  154 --------
 arch/h8300/kernel/ptrace.c                       |  168 --------
 arch/h8300/kernel/setup.c                        |  242 ------------
 arch/h8300/kernel/signal.c                       |  444 ----------------------
 arch/h8300/kernel/sys_h8300.c                    |   48 ---
 arch/h8300/kernel/syscalls.S                     |  338 ----------------
 arch/h8300/kernel/time.c                         |   66 ----
 arch/h8300/kernel/timer/Makefile                 |    6 -
 arch/h8300/kernel/timer/itu.c                    |   82 ----
 arch/h8300/kernel/timer/timer16.c                |   77 ----
 arch/h8300/kernel/timer/timer8.c                 |  102 -----
 arch/h8300/kernel/timer/tpu.c                    |  100 -----
 arch/h8300/kernel/traps.c                        |  166 --------
 arch/h8300/kernel/vmlinux.lds.S                  |  157 --------
 arch/h8300/lib/Makefile                          |    5 -
 arch/h8300/lib/abs.S                             |   21 -
 arch/h8300/lib/ashrdi3.c                         |   63 ---
 arch/h8300/lib/checksum.c                        |  164 --------
 arch/h8300/lib/memcpy.S                          |   84 ----
 arch/h8300/lib/memset.S                          |   61 ---
 arch/h8300/lib/romfs.S                           |   57 ---
 arch/h8300/mm/Makefile                           |    5 -
 arch/h8300/mm/fault.c                            |   56 ---
 arch/h8300/mm/init.c                             |  155 --------
 arch/h8300/mm/kmap.c                             |   58 ---
 arch/h8300/mm/memory.c                           |   54 ---
 arch/h8300/platform/h8300h/Makefile              |    7 -
 arch/h8300/platform/h8300h/aki3068net/Makefile   |    5 -
 arch/h8300/platform/h8300h/aki3068net/crt0_ram.S |  110 ------
 arch/h8300/platform/h8300h/generic/Makefile      |    5 -
 arch/h8300/platform/h8300h/generic/crt0_ram.S    |  107 ------
 arch/h8300/platform/h8300h/generic/crt0_rom.S    |  122 ------
 arch/h8300/platform/h8300h/h8max/Makefile        |    5 -
 arch/h8300/platform/h8300h/h8max/crt0_ram.S      |  110 ------
 arch/h8300/platform/h8300h/irq.c                 |   82 ----
 arch/h8300/platform/h8300h/ptrace_h8300h.c       |  284 --------------
 arch/h8300/platform/h8s/Makefile                 |    7 -
 arch/h8300/platform/h8s/edosk2674/Makefile       |    5 -
 arch/h8300/platform/h8s/edosk2674/crt0_ram.S     |  130 -------
 arch/h8300/platform/h8s/edosk2674/crt0_rom.S     |  186 ---------
 arch/h8300/platform/h8s/generic/Makefile         |    5 -
 arch/h8300/platform/h8s/generic/crt0_ram.S       |  127 -------
 arch/h8300/platform/h8s/generic/crt0_rom.S       |  128 -------
 arch/h8300/platform/h8s/irq.c                    |  104 -----
 arch/h8300/platform/h8s/ptrace_h8s.c             |   84 ----
 include/linux/serial_sci.h                       |    2 +-
 tools/testing/ktest/examples/crosstests.conf     |    6 -
 179 files changed, 1 insertion(+), 10891 deletions(-)
 delete mode 100644 arch/h8300/Kconfig
 delete mode 100644 arch/h8300/Kconfig.cpu
 delete mode 100644 arch/h8300/Kconfig.debug
 delete mode 100644 arch/h8300/Kconfig.ide
 delete mode 100644 arch/h8300/Makefile
 delete mode 100644 arch/h8300/README
 delete mode 100644 arch/h8300/boot/Makefile
 delete mode 100644 arch/h8300/boot/compressed/Makefile
 delete mode 100644 arch/h8300/boot/compressed/head.S
 delete mode 100644 arch/h8300/boot/compressed/misc.c
 delete mode 100644 arch/h8300/boot/compressed/vmlinux.lds
 delete mode 100644 arch/h8300/boot/compressed/vmlinux.scr
 delete mode 100644 arch/h8300/defconfig
 delete mode 100644 arch/h8300/include/asm/Kbuild
 delete mode 100644 arch/h8300/include/asm/asm-offsets.h
 delete mode 100644 arch/h8300/include/asm/atomic.h
 delete mode 100644 arch/h8300/include/asm/barrier.h
 delete mode 100644 arch/h8300/include/asm/bitops.h
 delete mode 100644 arch/h8300/include/asm/bootinfo.h
 delete mode 100644 arch/h8300/include/asm/bug.h
 delete mode 100644 arch/h8300/include/asm/bugs.h
 delete mode 100644 arch/h8300/include/asm/cache.h
 delete mode 100644 arch/h8300/include/asm/cachectl.h
 delete mode 100644 arch/h8300/include/asm/cacheflush.h
 delete mode 100644 arch/h8300/include/asm/checksum.h
 delete mode 100644 arch/h8300/include/asm/cmpxchg.h
 delete mode 100644 arch/h8300/include/asm/cputime.h
 delete mode 100644 arch/h8300/include/asm/current.h
 delete mode 100644 arch/h8300/include/asm/dbg.h
 delete mode 100644 arch/h8300/include/asm/delay.h
 delete mode 100644 arch/h8300/include/asm/device.h
 delete mode 100644 arch/h8300/include/asm/div64.h
 delete mode 100644 arch/h8300/include/asm/dma.h
 delete mode 100644 arch/h8300/include/asm/elf.h
 delete mode 100644 arch/h8300/include/asm/emergency-restart.h
 delete mode 100644 arch/h8300/include/asm/fb.h
 delete mode 100644 arch/h8300/include/asm/flat.h
 delete mode 100644 arch/h8300/include/asm/fpu.h
 delete mode 100644 arch/h8300/include/asm/ftrace.h
 delete mode 100644 arch/h8300/include/asm/futex.h
 delete mode 100644 arch/h8300/include/asm/gpio-internal.h
 delete mode 100644 arch/h8300/include/asm/hardirq.h
 delete mode 100644 arch/h8300/include/asm/hw_irq.h
 delete mode 100644 arch/h8300/include/asm/io.h
 delete mode 100644 arch/h8300/include/asm/irq.h
 delete mode 100644 arch/h8300/include/asm/irq_regs.h
 delete mode 100644 arch/h8300/include/asm/irqflags.h
 delete mode 100644 arch/h8300/include/asm/kdebug.h
 delete mode 100644 arch/h8300/include/asm/kmap_types.h
 delete mode 100644 arch/h8300/include/asm/local.h
 delete mode 100644 arch/h8300/include/asm/local64.h
 delete mode 100644 arch/h8300/include/asm/mc146818rtc.h
 delete mode 100644 arch/h8300/include/asm/mmu_context.h
 delete mode 100644 arch/h8300/include/asm/mutex.h
 delete mode 100644 arch/h8300/include/asm/page.h
 delete mode 100644 arch/h8300/include/asm/page_offset.h
 delete mode 100644 arch/h8300/include/asm/param.h
 delete mode 100644 arch/h8300/include/asm/pci.h
 delete mode 100644 arch/h8300/include/asm/percpu.h
 delete mode 100644 arch/h8300/include/asm/pgalloc.h
 delete mode 100644 arch/h8300/include/asm/pgtable.h
 delete mode 100644 arch/h8300/include/asm/processor.h
 delete mode 100644 arch/h8300/include/asm/ptrace.h
 delete mode 100644 arch/h8300/include/asm/regs267x.h
 delete mode 100644 arch/h8300/include/asm/regs306x.h
 delete mode 100644 arch/h8300/include/asm/scatterlist.h
 delete mode 100644 arch/h8300/include/asm/sections.h
 delete mode 100644 arch/h8300/include/asm/segment.h
 delete mode 100644 arch/h8300/include/asm/sh_bios.h
 delete mode 100644 arch/h8300/include/asm/shm.h
 delete mode 100644 arch/h8300/include/asm/shmparam.h
 delete mode 100644 arch/h8300/include/asm/signal.h
 delete mode 100644 arch/h8300/include/asm/smp.h
 delete mode 100644 arch/h8300/include/asm/spinlock.h
 delete mode 100644 arch/h8300/include/asm/string.h
 delete mode 100644 arch/h8300/include/asm/switch_to.h
 delete mode 100644 arch/h8300/include/asm/target_time.h
 delete mode 100644 arch/h8300/include/asm/termios.h
 delete mode 100644 arch/h8300/include/asm/thread_info.h
 delete mode 100644 arch/h8300/include/asm/timer.h
 delete mode 100644 arch/h8300/include/asm/timex.h
 delete mode 100644 arch/h8300/include/asm/tlb.h
 delete mode 100644 arch/h8300/include/asm/tlbflush.h
 delete mode 100644 arch/h8300/include/asm/topology.h
 delete mode 100644 arch/h8300/include/asm/traps.h
 delete mode 100644 arch/h8300/include/asm/types.h
 delete mode 100644 arch/h8300/include/asm/uaccess.h
 delete mode 100644 arch/h8300/include/asm/ucontext.h
 delete mode 100644 arch/h8300/include/asm/unaligned.h
 delete mode 100644 arch/h8300/include/asm/unistd.h
 delete mode 100644 arch/h8300/include/asm/user.h
 delete mode 100644 arch/h8300/include/asm/virtconvert.h
 delete mode 100644 arch/h8300/include/uapi/asm/Kbuild
 delete mode 100644 arch/h8300/include/uapi/asm/auxvec.h
 delete mode 100644 arch/h8300/include/uapi/asm/bitsperlong.h
 delete mode 100644 arch/h8300/include/uapi/asm/byteorder.h
 delete mode 100644 arch/h8300/include/uapi/asm/errno.h
 delete mode 100644 arch/h8300/include/uapi/asm/fcntl.h
 delete mode 100644 arch/h8300/include/uapi/asm/ioctl.h
 delete mode 100644 arch/h8300/include/uapi/asm/ioctls.h
 delete mode 100644 arch/h8300/include/uapi/asm/ipcbuf.h
 delete mode 100644 arch/h8300/include/uapi/asm/kvm_para.h
 delete mode 100644 arch/h8300/include/uapi/asm/mman.h
 delete mode 100644 arch/h8300/include/uapi/asm/msgbuf.h
 delete mode 100644 arch/h8300/include/uapi/asm/param.h
 delete mode 100644 arch/h8300/include/uapi/asm/poll.h
 delete mode 100644 arch/h8300/include/uapi/asm/posix_types.h
 delete mode 100644 arch/h8300/include/uapi/asm/ptrace.h
 delete mode 100644 arch/h8300/include/uapi/asm/resource.h
 delete mode 100644 arch/h8300/include/uapi/asm/sembuf.h
 delete mode 100644 arch/h8300/include/uapi/asm/setup.h
 delete mode 100644 arch/h8300/include/uapi/asm/shmbuf.h
 delete mode 100644 arch/h8300/include/uapi/asm/sigcontext.h
 delete mode 100644 arch/h8300/include/uapi/asm/siginfo.h
 delete mode 100644 arch/h8300/include/uapi/asm/signal.h
 delete mode 100644 arch/h8300/include/uapi/asm/socket.h
 delete mode 100644 arch/h8300/include/uapi/asm/sockios.h
 delete mode 100644 arch/h8300/include/uapi/asm/stat.h
 delete mode 100644 arch/h8300/include/uapi/asm/statfs.h
 delete mode 100644 arch/h8300/include/uapi/asm/swab.h
 delete mode 100644 arch/h8300/include/uapi/asm/termbits.h
 delete mode 100644 arch/h8300/include/uapi/asm/termios.h
 delete mode 100644 arch/h8300/include/uapi/asm/types.h
 delete mode 100644 arch/h8300/include/uapi/asm/unistd.h
 delete mode 100644 arch/h8300/kernel/Makefile
 delete mode 100644 arch/h8300/kernel/asm-offsets.c
 delete mode 100644 arch/h8300/kernel/entry.S
 delete mode 100644 arch/h8300/kernel/gpio.c
 delete mode 100644 arch/h8300/kernel/h8300_ksyms.c
 delete mode 100644 arch/h8300/kernel/irq.c
 delete mode 100644 arch/h8300/kernel/module.c
 delete mode 100644 arch/h8300/kernel/process.c
 delete mode 100644 arch/h8300/kernel/ptrace.c
 delete mode 100644 arch/h8300/kernel/setup.c
 delete mode 100644 arch/h8300/kernel/signal.c
 delete mode 100644 arch/h8300/kernel/sys_h8300.c
 delete mode 100644 arch/h8300/kernel/syscalls.S
 delete mode 100644 arch/h8300/kernel/time.c
 delete mode 100644 arch/h8300/kernel/timer/Makefile
 delete mode 100644 arch/h8300/kernel/timer/itu.c
 delete mode 100644 arch/h8300/kernel/timer/timer16.c
 delete mode 100644 arch/h8300/kernel/timer/timer8.c
 delete mode 100644 arch/h8300/kernel/timer/tpu.c
 delete mode 100644 arch/h8300/kernel/traps.c
 delete mode 100644 arch/h8300/kernel/vmlinux.lds.S
 delete mode 100644 arch/h8300/lib/Makefile
 delete mode 100644 arch/h8300/lib/abs.S
 delete mode 100644 arch/h8300/lib/ashrdi3.c
 delete mode 100644 arch/h8300/lib/checksum.c
 delete mode 100644 arch/h8300/lib/memcpy.S
 delete mode 100644 arch/h8300/lib/memset.S
 delete mode 100644 arch/h8300/lib/romfs.S
 delete mode 100644 arch/h8300/mm/Makefile
 delete mode 100644 arch/h8300/mm/fault.c
 delete mode 100644 arch/h8300/mm/init.c
 delete mode 100644 arch/h8300/mm/kmap.c
 delete mode 100644 arch/h8300/mm/memory.c
 delete mode 100644 arch/h8300/platform/h8300h/Makefile
 delete mode 100644 arch/h8300/platform/h8300h/aki3068net/Makefile
 delete mode 100644 arch/h8300/platform/h8300h/aki3068net/crt0_ram.S
 delete mode 100644 arch/h8300/platform/h8300h/generic/Makefile
 delete mode 100644 arch/h8300/platform/h8300h/generic/crt0_ram.S
 delete mode 100644 arch/h8300/platform/h8300h/generic/crt0_rom.S
 delete mode 100644 arch/h8300/platform/h8300h/h8max/Makefile
 delete mode 100644 arch/h8300/platform/h8300h/h8max/crt0_ram.S
 delete mode 100644 arch/h8300/platform/h8300h/irq.c
 delete mode 100644 arch/h8300/platform/h8300h/ptrace_h8300h.c
 delete mode 100644 arch/h8300/platform/h8s/Makefile
 delete mode 100644 arch/h8300/platform/h8s/edosk2674/Makefile
 delete mode 100644 arch/h8300/platform/h8s/edosk2674/crt0_ram.S
 delete mode 100644 arch/h8300/platform/h8s/edosk2674/crt0_rom.S
 delete mode 100644 arch/h8300/platform/h8s/generic/Makefile
 delete mode 100644 arch/h8300/platform/h8s/generic/crt0_ram.S
 delete mode 100644 arch/h8300/platform/h8s/generic/crt0_rom.S
 delete mode 100644 arch/h8300/platform/h8s/irq.c
 delete mode 100644 arch/h8300/platform/h8s/ptrace_h8s.c

diff --git a/Documentation/scheduler/sched-arch.txt b/Documentation/scheduler/sched-arch.txt
index b1b8587..9290de7 100644
--- a/Documentation/scheduler/sched-arch.txt
+++ b/Documentation/scheduler/sched-arch.txt
@@ -65,11 +65,6 @@ Possible arch/ problems
 
 Possible arch problems I found (and either tried to fix or didn't):
 
-h8300 - Is such sleeping racy vs interrupts? (See #4a).
-        The H8/300 manual I found indicates yes, however disabling IRQs
-        over the sleep mean only NMIs can wake it up, so can't fix easily
-        without doing spin waiting.
-
 ia64 - is safe_halt call racy vs interrupts? (does it sleep?) (See #4a)
 
 sh64 - Is sleeping racy vs interrupts? (See #4a)
diff --git a/arch/h8300/Kconfig b/arch/h8300/Kconfig
deleted file mode 100644
index 3d6759e..0000000
--- a/arch/h8300/Kconfig
+++ /dev/null
@@ -1,109 +0,0 @@
-config H8300
-	bool
-	default y
-	select HAVE_IDE
-	select HAVE_GENERIC_HARDIRQS
-	select GENERIC_ATOMIC64
-	select HAVE_UID16
-	select VIRT_TO_BUS
-	select ARCH_WANT_IPC_PARSE_VERSION
-	select GENERIC_IRQ_SHOW
-	select GENERIC_CPU_DEVICES
-	select MODULES_USE_ELF_RELA
-	select OLD_SIGSUSPEND3
-	select OLD_SIGACTION
-	select HAVE_UNDERSCORE_SYMBOL_PREFIX
-
-config MMU
-	bool
-	default n
-
-config SWAP
-	bool
-	default n
-
-config ZONE_DMA
-	bool
-	default y
-
-config FPU
-	bool
-	default n
-
-config RWSEM_GENERIC_SPINLOCK
-	bool
-	default y
-
-config RWSEM_XCHGADD_ALGORITHM
-	bool
-	default n
-
-config ARCH_HAS_ILOG2_U32
-	bool
-	default n
-
-config ARCH_HAS_ILOG2_U64
-	bool
-	default n
-
-config GENERIC_HWEIGHT
-	bool
-	default y
-
-config GENERIC_CALIBRATE_DELAY
-	bool
-	default y
-
-config GENERIC_BUG
-        bool
-        depends on BUG
-
-config TIME_LOW_RES
-	bool
-	default y
-
-config NO_IOPORT
-	def_bool y
-
-config NO_DMA
-	def_bool y
-
-config ISA
-	bool
-	default y
-
-config PCI
-	bool
-	default n
-
-config HZ
-	int
-	default 100
-
-source "init/Kconfig"
-
-source "kernel/Kconfig.freezer"
-
-source "arch/h8300/Kconfig.cpu"
-
-menu "Executable file formats"
-
-source "fs/Kconfig.binfmt"
-
-endmenu
-
-source "net/Kconfig"
-
-source "drivers/Kconfig"
-
-source "arch/h8300/Kconfig.ide"
-
-source "fs/Kconfig"
-
-source "arch/h8300/Kconfig.debug"
-
-source "security/Kconfig"
-
-source "crypto/Kconfig"
-
-source "lib/Kconfig"
diff --git a/arch/h8300/Kconfig.cpu b/arch/h8300/Kconfig.cpu
deleted file mode 100644
index cdee771..0000000
--- a/arch/h8300/Kconfig.cpu
+++ /dev/null
@@ -1,171 +0,0 @@
-menu "Processor type and features"
-
-choice
-	prompt "H8/300 platform"
-	default H8300H_GENERIC
-
-config H8300H_GENERIC
-	bool "H8/300H Generic"
-	help
-	  H8/300H CPU Generic Hardware Support
-
-config H8300H_AKI3068NET
-	bool "AE-3068/69"
-	select H83068
-	help
-	  AKI-H8/3068F / AKI-H8/3069F Flashmicom LAN Board Support
-	  More Information. (Japanese Only)
-	  <http://akizukidenshi.com/catalog/default.aspx>
-	  AE-3068/69 Evaluation Board Support
-	  More Information.
-	  <http://www.microtronique.com/ae3069lan.htm>
-
-config H8300H_H8MAX
-	bool "H8MAX"
-	select H83068
-	help
-	  H8MAX Evaluation Board Support
-	  More Information. (Japanese Only)
-	  <http://strawberry-linux.com/h8/index.html>
-
-config H8300H_SIM
-	bool "H8/300H Simulator"
-	select H83007
-	help
-	  GDB Simulator Support
-	  More Information.
-	  <http://sourceware.org/sid/>
-
-config H8S_GENERIC
-	bool "H8S Generic"
-	help
-	  H8S CPU Generic Hardware Support
-
-config H8S_EDOSK2674
-	bool "EDOSK-2674"
-	select H8S2678
-	help
-	  Renesas EDOSK-2674 Evaluation Board Support
-	  More Information.
-	  <http://www.azpower.com/H8-uClinux/index.html>
- 	  <http://www.renesas.eu/products/tools/introductory_evaluation_tools/evaluation_development_os_kits/edosk2674r/edosk2674r_software_tools_root.jsp>
-
-config H8S_SIM
-	bool "H8S Simulator"
-	help
-	  GDB Simulator Support
-	  More Information.
-	  <http://sourceware.org/sid/>
-
-endchoice
-
-choice
-	prompt "CPU Selection"
-
-config H83002
-	bool "H8/3001,3002,3003"
-	depends on BROKEN
-	select CPU_H8300H
-
-config H83007
-	bool "H8/3006,3007"
-	select CPU_H8300H
-
-config H83048
-	bool "H8/3044,3045,3046,3047,3048,3052"
-	depends on BROKEN
-	select CPU_H8300H
-
-config H83068
-	bool "H8/3065,3066,3067,3068,3069"
-	select CPU_H8300H
-
-config H8S2678
-	bool "H8S/2670,2673,2674R,2675,2676"
-	select CPU_H8S
-
-endchoice
-
-config CPU_CLOCK
-	int "CPU Clock Frequency (/1KHz)"
-	default "20000"
-	help
-	  CPU Clock Frequency divide to 1000
-
-choice
-	prompt "Kernel executes from"
-	---help---
-	  Choose the memory type that the kernel will be running in.
-
-config RAMKERNEL
-	bool "RAM"
-	help
-	  The kernel will be resident in RAM when running.
-
-config ROMKERNEL
-	bool "ROM"
-	help
-	  The kernel will be resident in FLASH/ROM when running.
-endchoice
-
-
-config CPU_H8300H
-	bool
-	depends on (H83002 || H83007 || H83048 || H83068)
-	default y
-
-config CPU_H8S
-	bool
-	depends on H8S2678
-	default y
-
-choice
-	prompt "Timer"
-config H8300_TIMER8
-	bool "8bit timer (2ch cascade)"
-	depends on (H83007 || H83068 || H8S2678)
-
-config H8300_TIMER16
-	bool "16bit timer"
-	depends on (H83007 || H83068)
-
-config H8300_ITU
-	bool "ITU"
-	depends on (H83002 || H83048)
-
-config H8300_TPU
-	bool "TPU"
-	depends on H8S2678
-endchoice
-
-if H8300_TIMER8
-choice
-	prompt "Timer Channel"
-config H8300_TIMER8_CH0
-	bool "Channel 0"
-config H8300_TIMER8_CH2
-	bool "Channel 2"
-	depends on CPU_H8300H
-endchoice
-endif
-
-config H8300_TIMER16_CH
-	int "16bit timer channel (0 - 2)"
-	depends on H8300_TIMER16
-	range 0 2
-
-config H8300_ITU_CH
-	int "ITU channel"
-	depends on H8300_ITU
-	range 0 4
-
-config H8300_TPU_CH
-	int "TPU channel"
-	depends on H8300_TPU
-	range 0 4
-
-source "kernel/Kconfig.preempt"
-
-source "mm/Kconfig"
-
-endmenu
diff --git a/arch/h8300/Kconfig.debug b/arch/h8300/Kconfig.debug
deleted file mode 100644
index e8d1b23..0000000
--- a/arch/h8300/Kconfig.debug
+++ /dev/null
@@ -1,68 +0,0 @@
-menu "Kernel hacking"
-
-source "lib/Kconfig.debug"
-
-config FULLDEBUG
-	bool "Full Symbolic/Source Debugging support"
-	help
-	  Enable debugging symbols on kernel build.
-
-config HIGHPROFILE
-	bool "Use fast second timer for profiling"
-	help
-	  Use a fast secondary clock to produce profiling information.
-
-config NO_KERNEL_MSG
-	bool "Suppress Kernel BUG Messages"
-	help
-	  Do not output any debug BUG messages within the kernel.
-
-config GDB_MAGICPRINT
-	bool "Message Output for GDB MagicPrint service"
-	depends on (H8300H_SIM || H8S_SIM)
-	help
-	  kernel messages output using MagicPrint service from GDB
-
-config SYSCALL_PRINT
-	bool "SystemCall trace print"
-	help
-	  output history of systemcall
-
-config GDB_DEBUG
-   	bool "Use gdb stub"
-	depends on (!H8300H_SIM && !H8S_SIM)
-	help
-	  gdb stub exception support
-
-config SH_STANDARD_BIOS
-	bool "Use gdb protocol serial console"
-	depends on (!H8300H_SIM && !H8S_SIM)
-	help
-	  serial console output using GDB protocol.
-	  Require eCos/RedBoot
-
-config DEFAULT_CMDLINE
-	bool "Use builtin commandline"
-	default n
-	help
-	  builtin kernel commandline enabled.
-
-config KERNEL_COMMAND
-	string "Buildin command string"
-	depends on DEFAULT_CMDLINE
-	help
-	  builtin kernel commandline strings.
-
-config BLKDEV_RESERVE
-	bool "BLKDEV Reserved Memory"
-	default n
-	help
-	  Reserved BLKDEV area.
-
-config BLKDEV_RESERVE_ADDRESS
-	hex 'start address'
-	depends on BLKDEV_RESERVE
-	help
-	  BLKDEV start address.
-
-endmenu
diff --git a/arch/h8300/Kconfig.ide b/arch/h8300/Kconfig.ide
deleted file mode 100644
index a38a630..0000000
--- a/arch/h8300/Kconfig.ide
+++ /dev/null
@@ -1,44 +0,0 @@
-# uClinux H8/300 Target Board Selection Menu (IDE)
-
-if (H8300H_AKI3068NET)
-menu "IDE Extra configuration"
-
-config H8300_IDE_BASE
-	hex "IDE register base address"
-	depends on IDE
-	default 0
-	help
-	  IDE registers base address
-
-config H8300_IDE_ALT
-	hex "IDE register alternate address"
-	depends on IDE
-	default 0
-	help
-	  IDE alternate registers address
-
-config H8300_IDE_IRQ
-	int "IDE IRQ no"
-	depends on IDE
-	default 0
-	help
-	  IDE use IRQ no
-endmenu
-endif
-
-if (H8300H_H8MAX)
-config H8300_IDE_BASE
-	hex
-	depends on IDE
-	default 0x200000
-
-config H8300_IDE_ALT
-	hex
-	depends on IDE
-	default 0x60000c
-
-config H8300_IDE_IRQ
-	int
-	depends on IDE
-	default 5
-endif
diff --git a/arch/h8300/Makefile b/arch/h8300/Makefile
deleted file mode 100644
index a556447..0000000
--- a/arch/h8300/Makefile
+++ /dev/null
@@ -1,71 +0,0 @@
-#
-# arch/h8300/Makefile
-#
-# This file is subject to the terms and conditions of the GNU General Public
-# License.  See the file "COPYING" in the main directory of this archive
-# for more details.
-#
-# (C) Copyright 2002,2003 Yoshinori Sato <ysato@users.sourceforge.jp>
-#
-
-platform-$(CONFIG_CPU_H8300H)	:= h8300h
-platform-$(CONFIG_CPU_H8S)	:= h8s
-PLATFORM := $(platform-y)
-
-board-$(CONFIG_H8300H_GENERIC)		:= generic
-board-$(CONFIG_H8300H_AKI3068NET)	:= aki3068net
-board-$(CONFIG_H8300H_H8MAX)		:= h8max
-board-$(CONFIG_H8300H_SIM)		:= generic
-board-$(CONFIG_H8S_GENERIC)		:= generic
-board-$(CONFIG_H8S_EDOSK2674)		:= edosk2674
-board-$(CONFIG_H8S_SIM)			:= generic
-BOARD := $(board-y)
-
-model-$(CONFIG_RAMKERNEL)	:= ram
-model-$(CONFIG_ROMKERNEL)	:= rom
-MODEL := $(model-y)
-
-cflags-$(CONFIG_CPU_H8300H)	:= -mh
-ldflags-$(CONFIG_CPU_H8300H)	:= -mh8300helf
-cflags-$(CONFIG_CPU_H8S)	:= -ms
-ldflags-$(CONFIG_CPU_H8S)	:= -mh8300self
-
-KBUILD_CFLAGS += $(cflags-y)
-KBUILD_CFLAGS += -mint32 -fno-builtin
-KBUILD_CFLAGS += -g
-KBUILD_CFLAGS += -D__linux__
-KBUILD_CFLAGS += -DUTS_SYSNAME=\"uClinux\"
-KBUILD_AFLAGS += -DPLATFORM=$(PLATFORM) -DMODEL=$(MODEL) $(cflags-y)
-LDFLAGS += $(ldflags-y)
-
-CROSS_COMPILE = h8300-elf-
-LIBGCC := $(shell $(CROSS-COMPILE)$(CC) $(KBUILD_CFLAGS) -print-libgcc-file-name)
-
-head-y := arch/$(ARCH)/platform/$(PLATFORM)/$(BOARD)/crt0_$(MODEL).o
-
-core-y	+= arch/$(ARCH)/kernel/ \
-	   arch/$(ARCH)/mm/
-ifdef PLATFORM
-core-y	+= arch/$(ARCH)/platform/$(PLATFORM)/ \
-	   arch/$(ARCH)/platform/$(PLATFORM)/$(BOARD)/
-endif
-
-libs-y	+= arch/$(ARCH)/lib/ $(LIBGCC)
-
-boot := arch/h8300/boot
-
-export MODEL PLATFORM BOARD
-
-archmrproper:
-
-archclean:
-	$(Q)$(MAKE) $(clean)=$(boot)
-
-vmlinux.srec vmlinux.bin zImage: vmlinux
-	$(Q)$(MAKE) $(build)=$(boot) $(boot)/$@
-
-define archhelp
-  @echo  'vmlinux.bin  - Create raw binary'
-  @echo  'vmlinux.srec - Create srec binary'
-  @echo  'zImage       - Compressed kernel image'
-endef
diff --git a/arch/h8300/README b/arch/h8300/README
deleted file mode 100644
index efa805f..0000000
--- a/arch/h8300/README
+++ /dev/null
@@ -1,38 +0,0 @@
-linux-2.6 for H8/300 README
-Yoshinori Sato <ysato@users.sourceforge.jp>
-
-* Supported CPU
-H8/300H and H8S
-
-* Supported Target
-1.simulator of GDB
-  require patches.
-
-2.AE 3068/AE 3069
-  more information 
-  MICROTRONIQUE <http://www.microtronique.com/>
-  Akizuki Denshi Tsusho Ltd. <http://akizukidenshi.com/> (Japanese Only)
-
-3.H8MAX 
-  see http://ip-sol.jp/h8max/ (Japanese Only)
-
-4.EDOSK2674
-  see http://www.eu.renesas.com/products/mpumcu/tool/edk/support/edosk2674.html
-      http://www.uclinux.org/pub/uClinux/ports/h8/HITACHI-EDOSK2674-HOWTO
-      http://www.azpower.com/H8-uClinux/
-
-* Toolchain Version
-gcc-3.1 or higher and patch
-see arch/h8300/tools_patch/README
-binutils-2.12 or higher
-gdb-5.2 or higher
-The environment that can compile a h8300-elf binary is necessary.
-
-* Userland Develop environment
-used h8300-elf toolchains.
-see http://www.uclinux.org/pub/uClinux/ports/h8/
-
-* A few words of thanks
-Porting to H8/300 serieses is support of Information-technology Promotion Agency, Japan.
-I thank support.
-and All developer/user.
diff --git a/arch/h8300/boot/Makefile b/arch/h8300/boot/Makefile
deleted file mode 100644
index 0bb62e0..0000000
--- a/arch/h8300/boot/Makefile
+++ /dev/null
@@ -1,22 +0,0 @@
-# arch/h8300/boot/Makefile
-
-targets := vmlinux.srec vmlinux.bin zImage
-subdir- := compressed
-
-OBJCOPYFLAGS_vmlinux.srec := -Osrec
-OBJCOPYFLAGS_vmlinux.bin  := -Obinary
-OBJCOPYFLAGS_zImage := -O binary -R .note -R .comment -R .stab -R .stabstr -S
-
-$(obj)/vmlinux.srec $(obj)/vmlinux.bin:  vmlinux FORCE
-	$(call if_changed,objcopy)
-	@echo '  Kernel: $@ is ready'
-
-$(obj)/zImage: $(obj)/compressed/vmlinux FORCE
-	$(call if_changed,objcopy)
-	@echo 'Kernel: $@ is ready'
-
-$(obj)/compressed/vmlinux: FORCE
-	$(Q)$(MAKE) $(build)=$(obj)/compressed $@
-
-CLEAN_FILES += arch/$(ARCH)/vmlinux.bin arch/$(ARCH)/vmlinux.srec
-
diff --git a/arch/h8300/boot/compressed/Makefile b/arch/h8300/boot/compressed/Makefile
deleted file mode 100644
index a6c98fe..0000000
--- a/arch/h8300/boot/compressed/Makefile
+++ /dev/null
@@ -1,37 +0,0 @@
-#
-# linux/arch/sh/boot/compressed/Makefile
-#
-# create a compressed vmlinux image from the original vmlinux
-#
-
-targets		:= vmlinux vmlinux.bin vmlinux.bin.gz head.o misc.o piggy.o
-asflags-y	:= -traditional
-
-OBJECTS = $(obj)/head.o $(obj)/misc.o
-
-#
-# IMAGE_OFFSET is the load offset of the compression loader
-# Assign dummy values if these 2 variables are not defined,
-# in order to suppress error message.
-#
-CONFIG_MEMORY_START     ?= 0x00400000
-CONFIG_BOOT_LINK_OFFSET ?= 0x00140000
-IMAGE_OFFSET := $(shell printf "0x%08x" $$(($(CONFIG_MEMORY_START)+$(CONFIG_BOOT_LINK_OFFSET))))
-
-LDFLAGS_vmlinux := -Ttext $(IMAGE_OFFSET) -estartup $(obj)/vmlinux.lds
-
-$(obj)/vmlinux: $(OBJECTS) $(obj)/piggy.o FORCE
-	$(call if_changed,ld)
-	@:
-
-$(obj)/vmlinux.bin: vmlinux FORCE
-	$(call if_changed,objcopy)
-
-$(obj)/vmlinux.bin.gz: $(obj)/vmlinux.bin FORCE
-	$(call if_changed,gzip)
-
-LDFLAGS_piggy.o := -r --format binary --oformat elf32-h8300 -T
-OBJCOPYFLAGS := -O binary
-
-$(obj)/piggy.o: $(obj)/vmlinux.scr $(obj)/vmlinux.bin.gz FORCE
-	$(call if_changed,ld)
diff --git a/arch/h8300/boot/compressed/head.S b/arch/h8300/boot/compressed/head.S
deleted file mode 100644
index 10e9a2d..0000000
--- a/arch/h8300/boot/compressed/head.S
+++ /dev/null
@@ -1,47 +0,0 @@
-/*
- *  linux/arch/h8300/boot/compressed/head.S
- *
- *  Copyright (C) 2006 Yoshinori Sato
- */
-
-	.h8300h
-#include <linux/linkage.h>
-
-#define SRAM_START 0xff4000
-
-	.section	.text..startup
-	.global	startup
-startup:
-	mov.l	#SRAM_START+0x8000, sp
-	mov.l	#__sbss, er0
-	mov.l	#__ebss, er1
-	sub.l	er0, er1
-	shlr	er1
-	shlr	er1
-	sub.l	er2, er2
-1:
-	mov.l	er2, @er0
-	adds	#4, er0
-	dec.l	#1, er1
-	bne	1b
-	jsr	@_decompress_kernel
-	jmp	@0x400000
-
-	.align	9
-fake_headers_as_bzImage:
-	.word	0
-	.ascii	"HdrS"		; header signature
-	.word	0x0202		; header version number (>= 0x0105)
-				; or else old loadlin-1.5 will fail)
-	.word	0		; default_switch
-	.word	0		; SETUPSEG
-	.word	0x1000
-	.word	0		; pointing to kernel version string
-	.byte	0		; = 0, old one (LILO, Loadlin,
-				; 0xTV: T=0 for LILO
-				;       V = version
-	.byte	1		; Load flags bzImage=1
-	.word	0x8000		; size to move, when setup is not
-	.long	0x100000	; 0x100000 = default for big kernel
-	.long	0		; address of loaded ramdisk image
-	.long	0		; its size in bytes
diff --git a/arch/h8300/boot/compressed/misc.c b/arch/h8300/boot/compressed/misc.c
deleted file mode 100644
index 4a1e3dd..0000000
--- a/arch/h8300/boot/compressed/misc.c
+++ /dev/null
@@ -1,180 +0,0 @@
-/*
- * arch/h8300/boot/compressed/misc.c
- *
- * This is a collection of several routines from gzip-1.0.3
- * adapted for Linux.
- *
- * malloc by Hannu Savolainen 1993 and Matthias Urlichs 1994
- *
- * Adapted for h8300 by Yoshinori Sato 2006
- */
-
-#include <asm/uaccess.h>
-
-/*
- * gzip declarations
- */
-
-#define OF(args)  args
-#define STATIC static
-
-#undef memset
-#undef memcpy
-#define memzero(s, n)     memset ((s), 0, (n))
-
-typedef unsigned char  uch;
-typedef unsigned short ush;
-typedef unsigned long  ulg;
-
-#define WSIZE 0x8000		/* Window size must be at least 32k, */
-				/* and a power of two */
-
-static uch *inbuf;	     /* input buffer */
-static uch window[WSIZE];    /* Sliding window buffer */
-
-static unsigned insize = 0;  /* valid bytes in inbuf */
-static unsigned inptr = 0;   /* index of next byte to be processed in inbuf */
-static unsigned outcnt = 0;  /* bytes in output buffer */
-
-/* gzip flag byte */
-#define ASCII_FLAG   0x01 /* bit 0 set: file probably ASCII text */
-#define CONTINUATION 0x02 /* bit 1 set: continuation of multi-part gzip file */
-#define EXTRA_FIELD  0x04 /* bit 2 set: extra field present */
-#define ORIG_NAME    0x08 /* bit 3 set: original file name present */
-#define COMMENT      0x10 /* bit 4 set: file comment present */
-#define ENCRYPTED    0x20 /* bit 5 set: file is encrypted */
-#define RESERVED     0xC0 /* bit 6,7:   reserved */
-
-#define get_byte()  (inptr < insize ? inbuf[inptr++] : fill_inbuf())
-
-/* Diagnostic functions */
-#ifdef DEBUG
-#  define Assert(cond,msg) {if(!(cond)) error(msg);}
-#  define Trace(x) fprintf x
-#  define Tracev(x) {if (verbose) fprintf x ;}
-#  define Tracevv(x) {if (verbose>1) fprintf x ;}
-#  define Tracec(c,x) {if (verbose && (c)) fprintf x ;}
-#  define Tracecv(c,x) {if (verbose>1 && (c)) fprintf x ;}
-#else
-#  define Assert(cond,msg)
-#  define Trace(x)
-#  define Tracev(x)
-#  define Tracevv(x)
-#  define Tracec(c,x)
-#  define Tracecv(c,x)
-#endif
-
-static int  fill_inbuf(void);
-static void flush_window(void);
-static void error(char *m);
-
-extern char input_data[];
-extern int input_len;
-
-static long bytes_out = 0;
-static uch *output_data;
-static unsigned long output_ptr = 0;
-
-static void error(char *m);
-
-int puts(const char *);
-
-extern int _end;
-static unsigned long free_mem_ptr;
-static unsigned long free_mem_end_ptr;
-
-#define HEAP_SIZE             0x10000
-
-#include "../../../../lib/inflate.c"
-
-#define SCR *((volatile unsigned char *)0xffff8a)
-#define TDR *((volatile unsigned char *)0xffff8b)
-#define SSR *((volatile unsigned char *)0xffff8c)
-
-int puts(const char *s)
-{
-	return 0;
-}
-
-void* memset(void* s, int c, size_t n)
-{
-	int i;
-	char *ss = (char*)s;
-
-	for (i=0;i<n;i++) ss[i] = c;
-	return s;
-}
-
-void* memcpy(void* __dest, __const void* __src,
-			    size_t __n)
-{
-	int i;
-	char *d = (char *)__dest, *s = (char *)__src;
-
-	for (i=0;i<__n;i++) d[i] = s[i];
-	return __dest;
-}
-
-/* ===========================================================================
- * Fill the input buffer. This is called only when the buffer is empty
- * and at least one byte is really needed.
- */
-static int fill_inbuf(void)
-{
-	if (insize != 0) {
-		error("ran out of input data");
-	}
-
-	inbuf = input_data;
-	insize = input_len;
-	inptr = 1;
-	return inbuf[0];
-}
-
-/* ===========================================================================
- * Write the output window window[0..outcnt-1] and update crc and bytes_out.
- * (Used for the decompressed data only.)
- */
-static void flush_window(void)
-{
-    ulg c = crc;         /* temporary variable */
-    unsigned n;
-    uch *in, *out, ch;
-
-    in = window;
-    out = &output_data[output_ptr];
-    for (n = 0; n < outcnt; n++) {
-	    ch = *out++ = *in++;
-	    c = crc_32_tab[((int)c ^ ch) & 0xff] ^ (c >> 8);
-    }
-    crc = c;
-    bytes_out += (ulg)outcnt;
-    output_ptr += (ulg)outcnt;
-    outcnt = 0;
-}
-
-static void error(char *x)
-{
-	puts("\n\n");
-	puts(x);
-	puts("\n\n -- System halted");
-
-	while(1);	/* Halt */
-}
-
-#define STACK_SIZE (4096)
-long user_stack [STACK_SIZE];
-long* stack_start = &user_stack[STACK_SIZE];
-
-void decompress_kernel(void)
-{
-	output_data = 0;
-	output_ptr = (unsigned long)0x400000;
-	free_mem_ptr = (unsigned long)&_end;
-	free_mem_end_ptr = free_mem_ptr + HEAP_SIZE;
-
-	makecrc();
-	puts("Uncompressing Linux... ");
-	gunzip();
-	puts("Ok, booting the kernel.\n");
-}
diff --git a/arch/h8300/boot/compressed/vmlinux.lds b/arch/h8300/boot/compressed/vmlinux.lds
deleted file mode 100644
index a0a3a0e..0000000
--- a/arch/h8300/boot/compressed/vmlinux.lds
+++ /dev/null
@@ -1,32 +0,0 @@
-SECTIONS
-{
-        .text :
-        {
-        __stext = . ;
-	__text = .;
-	       *(.text..startup)
-	       *(.text)
-        __etext = . ;
-        }
-
-	.rodata :
-	{
-		*(.rodata)
-	}
-        .data :
-
-        {
-        __sdata = . ;
-        ___data_start = . ;
-                *(.data.*)
-	}
-        .bss :
-        {
-        . = ALIGN(0x4) ;
-        __sbss = . ;
-                *(.bss*)
-        . = ALIGN(0x4) ;
-        __ebss = . ;
-        __end = . ;
-        }
-}
diff --git a/arch/h8300/boot/compressed/vmlinux.scr b/arch/h8300/boot/compressed/vmlinux.scr
deleted file mode 100644
index a0f6962..0000000
--- a/arch/h8300/boot/compressed/vmlinux.scr
+++ /dev/null
@@ -1,9 +0,0 @@
-SECTIONS
-{
-  .data : {
-	_input_len = .;
-	LONG(_input_data_end - _input_data) _input_data = .;
-	*(.data)
-	_input_data_end = .;
-	}
-}
diff --git a/arch/h8300/defconfig b/arch/h8300/defconfig
deleted file mode 100644
index 042425a..0000000
--- a/arch/h8300/defconfig
+++ /dev/null
@@ -1,42 +0,0 @@
-CONFIG_EXPERIMENTAL=y
-# CONFIG_LOCALVERSION_AUTO is not set
-CONFIG_LOG_BUF_SHIFT=14
-CONFIG_EXPERT=y
-# CONFIG_UID16 is not set
-# CONFIG_SYSCTL_SYSCALL is not set
-# CONFIG_KALLSYMS is not set
-# CONFIG_HOTPLUG is not set
-# CONFIG_BASE_FULL is not set
-# CONFIG_FUTEX is not set
-# CONFIG_EPOLL is not set
-# CONFIG_SIGNALFD is not set
-# CONFIG_TIMERFD is not set
-# CONFIG_EVENTFD is not set
-# CONFIG_VM_EVENT_COUNTERS is not set
-# CONFIG_COMPAT_BRK is not set
-CONFIG_SLOB=y
-# CONFIG_BLK_DEV_BSG is not set
-# CONFIG_IOSCHED_DEADLINE is not set
-# CONFIG_IOSCHED_CFQ is not set
-CONFIG_H83007=y
-CONFIG_BINFMT_FLAT=y
-CONFIG_BINFMT_ZFLAT=y
-CONFIG_BINFMT_MISC=y
-# CONFIG_PREVENT_FIRMWARE_BUILD is not set
-CONFIG_MTD=y
-CONFIG_MTD_PARTITIONS=y
-CONFIG_MTD_REDBOOT_PARTS=y
-CONFIG_MTD_CHAR=y
-CONFIG_MTD_RAM=y
-CONFIG_MTD_ROM=y
-CONFIG_MTD_UCLINUX=y
-# CONFIG_BLK_DEV is not set
-# CONFIG_INPUT is not set
-# CONFIG_SERIO is not set
-# CONFIG_HWMON is not set
-# CONFIG_USB_SUPPORT is not set
-# CONFIG_DNOTIFY is not set
-CONFIG_ROMFS_FS=y
-# CONFIG_ENABLE_WARN_DEPRECATED is not set
-# CONFIG_ENABLE_MUST_CHECK is not set
-# CONFIG_CRC32 is not set
diff --git a/arch/h8300/include/asm/Kbuild b/arch/h8300/include/asm/Kbuild
deleted file mode 100644
index 8ada3cf..0000000
--- a/arch/h8300/include/asm/Kbuild
+++ /dev/null
@@ -1,8 +0,0 @@
-
-generic-y += clkdev.h
-generic-y += exec.h
-generic-y += linkage.h
-generic-y += mmu.h
-generic-y += module.h
-generic-y += trace_clock.h
-generic-y += xor.h
diff --git a/arch/h8300/include/asm/asm-offsets.h b/arch/h8300/include/asm/asm-offsets.h
deleted file mode 100644
index d370ee3..0000000
--- a/arch/h8300/include/asm/asm-offsets.h
+++ /dev/null
@@ -1 +0,0 @@
-#include <generated/asm-offsets.h>
diff --git a/arch/h8300/include/asm/atomic.h b/arch/h8300/include/asm/atomic.h
deleted file mode 100644
index 40901e3..0000000
--- a/arch/h8300/include/asm/atomic.h
+++ /dev/null
@@ -1,146 +0,0 @@
-#ifndef __ARCH_H8300_ATOMIC__
-#define __ARCH_H8300_ATOMIC__
-
-#include <linux/types.h>
-#include <asm/cmpxchg.h>
-
-/*
- * Atomic operations that C can't guarantee us.  Useful for
- * resource counting etc..
- */
-
-#define ATOMIC_INIT(i)	{ (i) }
-
-#define atomic_read(v)		(*(volatile int *)&(v)->counter)
-#define atomic_set(v, i)	(((v)->counter) = i)
-
-#include <linux/kernel.h>
-
-static __inline__ int atomic_add_return(int i, atomic_t *v)
-{
-	unsigned long flags;
-	int ret;
-	local_irq_save(flags);
-	ret = v->counter += i;
-	local_irq_restore(flags);
-	return ret;
-}
-
-#define atomic_add(i, v) atomic_add_return(i, v)
-#define atomic_add_negative(a, v)	(atomic_add_return((a), (v)) < 0)
-
-static __inline__ int atomic_sub_return(int i, atomic_t *v)
-{
-	unsigned long flags;
-	int ret;
-	local_irq_save(flags);
-	ret = v->counter -= i;
-	local_irq_restore(flags);
-	return ret;
-}
-
-#define atomic_sub(i, v) atomic_sub_return(i, v)
-#define atomic_sub_and_test(i,v) (atomic_sub_return(i, v) == 0)
-
-static __inline__ int atomic_inc_return(atomic_t *v)
-{
-	unsigned long flags;
-	int ret;
-	local_irq_save(flags);
-	v->counter++;
-	ret = v->counter;
-	local_irq_restore(flags);
-	return ret;
-}
-
-#define atomic_inc(v) atomic_inc_return(v)
-
-/*
- * atomic_inc_and_test - increment and test
- * @v: pointer of type atomic_t
- *
- * Atomically increments @v by 1
- * and returns true if the result is zero, or false for all
- * other cases.
- */
-#define atomic_inc_and_test(v) (atomic_inc_return(v) == 0)
-
-static __inline__ int atomic_dec_return(atomic_t *v)
-{
-	unsigned long flags;
-	int ret;
-	local_irq_save(flags);
-	--v->counter;
-	ret = v->counter;
-	local_irq_restore(flags);
-	return ret;
-}
-
-#define atomic_dec(v) atomic_dec_return(v)
-
-static __inline__ int atomic_dec_and_test(atomic_t *v)
-{
-	unsigned long flags;
-	int ret;
-	local_irq_save(flags);
-	--v->counter;
-	ret = v->counter;
-	local_irq_restore(flags);
-	return ret == 0;
-}
-
-static inline int atomic_cmpxchg(atomic_t *v, int old, int new)
-{
-	int ret;
-	unsigned long flags;
-
-	local_irq_save(flags);
-	ret = v->counter;
-	if (likely(ret == old))
-		v->counter = new;
-	local_irq_restore(flags);
-	return ret;
-}
-
-static inline int __atomic_add_unless(atomic_t *v, int a, int u)
-{
-	int ret;
-	unsigned long flags;
-
-	local_irq_save(flags);
-	ret = v->counter;
-	if (ret != u)
-		v->counter += a;
-	local_irq_restore(flags);
-	return ret;
-}
-
-static __inline__ void atomic_clear_mask(unsigned long mask, unsigned long *v)
-{
-	__asm__ __volatile__("stc ccr,r1l\n\t"
-	                     "orc #0x80,ccr\n\t"
-	                     "mov.l %0,er0\n\t"
-	                     "and.l %1,er0\n\t"
-	                     "mov.l er0,%0\n\t"
-	                     "ldc r1l,ccr" 
-                             : "=m" (*v) : "g" (~(mask)) :"er0","er1");
-}
-
-static __inline__ void atomic_set_mask(unsigned long mask, unsigned long *v)
-{
-	__asm__ __volatile__("stc ccr,r1l\n\t"
-	                     "orc #0x80,ccr\n\t"
-	                     "mov.l %0,er0\n\t"
-	                     "or.l %1,er0\n\t"
-	                     "mov.l er0,%0\n\t"
-	                     "ldc r1l,ccr" 
-                             : "=m" (*v) : "g" (mask) :"er0","er1");
-}
-
-/* Atomic operations are already serializing */
-#define smp_mb__before_atomic_dec()    barrier()
-#define smp_mb__after_atomic_dec() barrier()
-#define smp_mb__before_atomic_inc()    barrier()
-#define smp_mb__after_atomic_inc() barrier()
-
-#endif /* __ARCH_H8300_ATOMIC __ */
diff --git a/arch/h8300/include/asm/barrier.h b/arch/h8300/include/asm/barrier.h
deleted file mode 100644
index 9e0aa9f..0000000
--- a/arch/h8300/include/asm/barrier.h
+++ /dev/null
@@ -1,29 +0,0 @@
-#ifndef _H8300_BARRIER_H
-#define _H8300_BARRIER_H
-
-#define nop()  asm volatile ("nop"::)
-
-/*
- * Force strict CPU ordering.
- * Not really required on H8...
- */
-#define mb()   asm volatile (""   : : :"memory")
-#define rmb()  asm volatile (""   : : :"memory")
-#define wmb()  asm volatile (""   : : :"memory")
-#define set_mb(var, value) do { xchg(&var, value); } while (0)
-
-#define read_barrier_depends()	do { } while (0)
-
-#ifdef CONFIG_SMP
-#define smp_mb()	mb()
-#define smp_rmb()	rmb()
-#define smp_wmb()	wmb()
-#define smp_read_barrier_depends()	read_barrier_depends()
-#else
-#define smp_mb()	barrier()
-#define smp_rmb()	barrier()
-#define smp_wmb()	barrier()
-#define smp_read_barrier_depends()	do { } while(0)
-#endif
-
-#endif /* _H8300_BARRIER_H */
diff --git a/arch/h8300/include/asm/bitops.h b/arch/h8300/include/asm/bitops.h
deleted file mode 100644
index eb34e0c..0000000
--- a/arch/h8300/include/asm/bitops.h
+++ /dev/null
@@ -1,211 +0,0 @@
-#ifndef _H8300_BITOPS_H
-#define _H8300_BITOPS_H
-
-/*
- * Copyright 1992, Linus Torvalds.
- * Copyright 2002, Yoshinori Sato
- */
-
-#include <linux/compiler.h>
-
-#ifdef __KERNEL__
-
-#ifndef _LINUX_BITOPS_H
-#error only <linux/bitops.h> can be included directly
-#endif
-
-/*
- * Function prototypes to keep gcc -Wall happy
- */
-
-/*
- * ffz = Find First Zero in word. Undefined if no zero exists,
- * so code should check against ~0UL first..
- */
-static __inline__ unsigned long ffz(unsigned long word)
-{
-	unsigned long result;
-
-	result = -1;
-	__asm__("1:\n\t"
-		"shlr.l %2\n\t"
-		"adds #1,%0\n\t"
-		"bcs 1b"
-		: "=r" (result)
-		: "0"  (result),"r" (word));
-	return result;
-}
-
-#define H8300_GEN_BITOP_CONST(OP,BIT)			    \
-	case BIT:					    \
-	__asm__(OP " #" #BIT ",@%0"::"r"(b_addr):"memory"); \
-	break;
-
-#define H8300_GEN_BITOP(FNAME,OP)				      \
-static __inline__ void FNAME(int nr, volatile unsigned long* addr)    \
-{								      \
-	volatile unsigned char *b_addr;				      \
-	b_addr = (volatile unsigned char *)addr + ((nr >> 3) ^ 3);    \
-	if (__builtin_constant_p(nr)) {				      \
-		switch(nr & 7) {				      \
-			H8300_GEN_BITOP_CONST(OP,0)		      \
-			H8300_GEN_BITOP_CONST(OP,1)		      \
-			H8300_GEN_BITOP_CONST(OP,2)		      \
-			H8300_GEN_BITOP_CONST(OP,3)		      \
-			H8300_GEN_BITOP_CONST(OP,4)		      \
-			H8300_GEN_BITOP_CONST(OP,5)		      \
-			H8300_GEN_BITOP_CONST(OP,6)		      \
-			H8300_GEN_BITOP_CONST(OP,7)		      \
-		}						      \
-	} else {						      \
-		__asm__(OP " %w0,@%1"::"r"(nr),"r"(b_addr):"memory"); \
-	}							      \
-}
-
-/*
- * clear_bit() doesn't provide any barrier for the compiler.
- */
-#define smp_mb__before_clear_bit()	barrier()
-#define smp_mb__after_clear_bit()	barrier()
-
-H8300_GEN_BITOP(set_bit	  ,"bset")
-H8300_GEN_BITOP(clear_bit ,"bclr")
-H8300_GEN_BITOP(change_bit,"bnot")
-#define __set_bit(nr,addr)    set_bit((nr),(addr))
-#define __clear_bit(nr,addr)  clear_bit((nr),(addr))
-#define __change_bit(nr,addr) change_bit((nr),(addr))
-
-#undef H8300_GEN_BITOP
-#undef H8300_GEN_BITOP_CONST
-
-static __inline__ int test_bit(int nr, const unsigned long* addr)
-{
-	return (*((volatile unsigned char *)addr + 
-               ((nr >> 3) ^ 3)) & (1UL << (nr & 7))) != 0;
-}
-
-#define __test_bit(nr, addr) test_bit(nr, addr)
-
-#define H8300_GEN_TEST_BITOP_CONST_INT(OP,BIT)			     \
-	case BIT:						     \
-	__asm__("stc ccr,%w1\n\t"				     \
-		"orc #0x80,ccr\n\t"				     \
-		"bld #" #BIT ",@%4\n\t"				     \
-		OP " #" #BIT ",@%4\n\t"				     \
-		"rotxl.l %0\n\t"				     \
-		"ldc %w1,ccr"					     \
-		: "=r"(retval),"=&r"(ccrsave),"=m"(*b_addr)	     \
-		: "0" (retval),"r" (b_addr)			     \
-		: "memory");                                         \
-        break;
-
-#define H8300_GEN_TEST_BITOP_CONST(OP,BIT)			     \
-	case BIT:						     \
-	__asm__("bld #" #BIT ",@%3\n\t"				     \
-		OP " #" #BIT ",@%3\n\t"				     \
-		"rotxl.l %0\n\t"				     \
-		: "=r"(retval),"=m"(*b_addr)			     \
-		: "0" (retval),"r" (b_addr)			     \
-		: "memory");                                         \
-        break;
-
-#define H8300_GEN_TEST_BITOP(FNNAME,OP)				     \
-static __inline__ int FNNAME(int nr, volatile void * addr)	     \
-{								     \
-	int retval = 0;						     \
-	char ccrsave;						     \
-	volatile unsigned char *b_addr;				     \
-	b_addr = (volatile unsigned char *)addr + ((nr >> 3) ^ 3);   \
-	if (__builtin_constant_p(nr)) {				     \
-		switch(nr & 7) {				     \
-			H8300_GEN_TEST_BITOP_CONST_INT(OP,0)	     \
-			H8300_GEN_TEST_BITOP_CONST_INT(OP,1)	     \
-			H8300_GEN_TEST_BITOP_CONST_INT(OP,2)	     \
-			H8300_GEN_TEST_BITOP_CONST_INT(OP,3)	     \
-			H8300_GEN_TEST_BITOP_CONST_INT(OP,4)	     \
-			H8300_GEN_TEST_BITOP_CONST_INT(OP,5)	     \
-			H8300_GEN_TEST_BITOP_CONST_INT(OP,6)	     \
-			H8300_GEN_TEST_BITOP_CONST_INT(OP,7)	     \
-		}						     \
-	} else {						     \
-		__asm__("stc ccr,%w1\n\t"			     \
-			"orc #0x80,ccr\n\t"			     \
-			"btst %w5,@%4\n\t"			     \
-			OP " %w5,@%4\n\t"			     \
-			"beq 1f\n\t"				     \
-			"inc.l #1,%0\n"				     \
-			"1:\n\t"				     \
-			"ldc %w1,ccr"				     \
-			: "=r"(retval),"=&r"(ccrsave),"=m"(*b_addr)  \
-			: "0" (retval),"r" (b_addr),"r"(nr)	     \
-			: "memory");				     \
-	}							     \
-	return retval;						     \
-}								     \
-								     \
-static __inline__ int __ ## FNNAME(int nr, volatile void * addr)     \
-{								     \
-	int retval = 0;						     \
-	volatile unsigned char *b_addr;				     \
-	b_addr = (volatile unsigned char *)addr + ((nr >> 3) ^ 3);   \
-	if (__builtin_constant_p(nr)) {				     \
-		switch(nr & 7) {				     \
-			H8300_GEN_TEST_BITOP_CONST(OP,0) 	     \
-			H8300_GEN_TEST_BITOP_CONST(OP,1) 	     \
-			H8300_GEN_TEST_BITOP_CONST(OP,2) 	     \
-			H8300_GEN_TEST_BITOP_CONST(OP,3) 	     \
-			H8300_GEN_TEST_BITOP_CONST(OP,4) 	     \
-			H8300_GEN_TEST_BITOP_CONST(OP,5) 	     \
-			H8300_GEN_TEST_BITOP_CONST(OP,6) 	     \
-			H8300_GEN_TEST_BITOP_CONST(OP,7) 	     \
-		}						     \
-	} else {						     \
-		__asm__("btst %w4,@%3\n\t"			     \
-			OP " %w4,@%3\n\t"			     \
-			"beq 1f\n\t"				     \
-			"inc.l #1,%0\n"				     \
-			"1:"					     \
-			: "=r"(retval),"=m"(*b_addr)		     \
-			: "0" (retval),"r" (b_addr),"r"(nr)	     \
-			: "memory");				     \
-	}							     \
-	return retval;						     \
-}
-
-H8300_GEN_TEST_BITOP(test_and_set_bit,	 "bset")
-H8300_GEN_TEST_BITOP(test_and_clear_bit, "bclr")
-H8300_GEN_TEST_BITOP(test_and_change_bit,"bnot")
-#undef H8300_GEN_TEST_BITOP_CONST
-#undef H8300_GEN_TEST_BITOP_CONST_INT
-#undef H8300_GEN_TEST_BITOP
-
-#include <asm-generic/bitops/ffs.h>
-
-static __inline__ unsigned long __ffs(unsigned long word)
-{
-	unsigned long result;
-
-	result = -1;
-	__asm__("1:\n\t"
-		"shlr.l %2\n\t"
-		"adds #1,%0\n\t"
-		"bcc 1b"
-		: "=r" (result)
-		: "0"(result),"r"(word));
-	return result;
-}
-
-#include <asm-generic/bitops/find.h>
-#include <asm-generic/bitops/sched.h>
-#include <asm-generic/bitops/hweight.h>
-#include <asm-generic/bitops/lock.h>
-#include <asm-generic/bitops/le.h>
-#include <asm-generic/bitops/ext2-atomic.h>
-
-#endif /* __KERNEL__ */
-
-#include <asm-generic/bitops/fls.h>
-#include <asm-generic/bitops/__fls.h>
-#include <asm-generic/bitops/fls64.h>
-
-#endif /* _H8300_BITOPS_H */
diff --git a/arch/h8300/include/asm/bootinfo.h b/arch/h8300/include/asm/bootinfo.h
deleted file mode 100644
index 5bed7e7..0000000
--- a/arch/h8300/include/asm/bootinfo.h
+++ /dev/null
@@ -1,2 +0,0 @@
-
-/* Nothing for h8300 */
diff --git a/arch/h8300/include/asm/bug.h b/arch/h8300/include/asm/bug.h
deleted file mode 100644
index 1e1be81..0000000
--- a/arch/h8300/include/asm/bug.h
+++ /dev/null
@@ -1,12 +0,0 @@
-#ifndef _H8300_BUG_H
-#define _H8300_BUG_H
-
-/* always true */
-#define is_valid_bugaddr(addr) (1)
-
-#include <asm-generic/bug.h>
-
-struct pt_regs;
-extern void die(const char *str, struct pt_regs *fp, unsigned long err);
-
-#endif
diff --git a/arch/h8300/include/asm/bugs.h b/arch/h8300/include/asm/bugs.h
deleted file mode 100644
index 1cb4afb..0000000
--- a/arch/h8300/include/asm/bugs.h
+++ /dev/null
@@ -1,16 +0,0 @@
-/*
- *  include/asm-h8300/bugs.h
- *
- *  Copyright (C) 1994  Linus Torvalds
- */
-
-/*
- * This is included by init/main.c to check for architecture-dependent bugs.
- *
- * Needs:
- *	void check_bugs(void);
- */
-
-static void check_bugs(void)
-{
-}
diff --git a/arch/h8300/include/asm/cache.h b/arch/h8300/include/asm/cache.h
deleted file mode 100644
index 05887a1..0000000
--- a/arch/h8300/include/asm/cache.h
+++ /dev/null
@@ -1,13 +0,0 @@
-#ifndef __ARCH_H8300_CACHE_H
-#define __ARCH_H8300_CACHE_H
-
-/* bytes per L1 cache line */
-#define        L1_CACHE_SHIFT  2
-#define        L1_CACHE_BYTES  (1 << L1_CACHE_SHIFT)
-
-/* m68k-elf-gcc  2.95.2 doesn't like these */
-
-#define __cacheline_aligned
-#define ____cacheline_aligned
-
-#endif
diff --git a/arch/h8300/include/asm/cachectl.h b/arch/h8300/include/asm/cachectl.h
deleted file mode 100644
index c464022..0000000
--- a/arch/h8300/include/asm/cachectl.h
+++ /dev/null
@@ -1,14 +0,0 @@
-#ifndef _H8300_CACHECTL_H
-#define _H8300_CACHECTL_H
-
-/* Definitions for the cacheflush system call.  */
-
-#define FLUSH_SCOPE_LINE    0	/* Flush a cache line */
-#define FLUSH_SCOPE_PAGE    0	/* Flush a page */
-#define FLUSH_SCOPE_ALL     0	/* Flush the whole cache -- superuser only */
-
-#define FLUSH_CACHE_DATA    0	/* Writeback and flush data cache */
-#define FLUSH_CACHE_INSN    0	/* Flush instruction cache */
-#define FLUSH_CACHE_BOTH    0	/* Flush both caches */
-
-#endif /* _H8300_CACHECTL_H */
diff --git a/arch/h8300/include/asm/cacheflush.h b/arch/h8300/include/asm/cacheflush.h
deleted file mode 100644
index 4cf2df2..0000000
--- a/arch/h8300/include/asm/cacheflush.h
+++ /dev/null
@@ -1,40 +0,0 @@
-/*
- * (C) Copyright 2002, Yoshinori Sato <ysato@users.sourceforge.jp>
- */
-
-#ifndef _ASM_H8300_CACHEFLUSH_H
-#define _ASM_H8300_CACHEFLUSH_H
-
-/*
- * Cache handling functions
- * No Cache memory all dummy functions
- */
-
-#define flush_cache_all()
-#define	flush_cache_mm(mm)
-#define	flush_cache_dup_mm(mm)		do { } while (0)
-#define	flush_cache_range(vma,a,b)
-#define	flush_cache_page(vma,p,pfn)
-#define ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE 0
-#define	flush_dcache_page(page)
-#define	flush_dcache_mmap_lock(mapping)
-#define	flush_dcache_mmap_unlock(mapping)
-#define	flush_icache()
-#define	flush_icache_page(vma,page)
-#define	flush_icache_range(start,len)
-#define flush_cache_vmap(start, end)
-#define flush_cache_vunmap(start, end)
-#define	cache_push_v(vaddr,len)
-#define	cache_push(paddr,len)
-#define	cache_clear(paddr,len)
-
-#define	flush_dcache_range(a,b)
-
-#define	flush_icache_user_range(vma,page,addr,len)
-
-#define copy_to_user_page(vma, page, vaddr, dst, src, len) \
-	memcpy(dst, src, len)
-#define copy_from_user_page(vma, page, vaddr, dst, src, len) \
-	memcpy(dst, src, len)
-
-#endif /* _ASM_H8300_CACHEFLUSH_H */
diff --git a/arch/h8300/include/asm/checksum.h b/arch/h8300/include/asm/checksum.h
deleted file mode 100644
index 98724e1..0000000
--- a/arch/h8300/include/asm/checksum.h
+++ /dev/null
@@ -1,102 +0,0 @@
-#ifndef _H8300_CHECKSUM_H
-#define _H8300_CHECKSUM_H
-
-/*
- * computes the checksum of a memory block at buff, length len,
- * and adds in "sum" (32-bit)
- *
- * returns a 32-bit number suitable for feeding into itself
- * or csum_tcpudp_magic
- *
- * this function must be called with even lengths, except
- * for the last fragment, which may be odd
- *
- * it's best to have buff aligned on a 32-bit boundary
- */
-__wsum csum_partial(const void *buff, int len, __wsum sum);
-
-/*
- * the same as csum_partial, but copies from src while it
- * checksums
- *
- * here even more important to align src and dst on a 32-bit (or even
- * better 64-bit) boundary
- */
-
-__wsum csum_partial_copy_nocheck(const void *src, void *dst, int len, __wsum sum);
-
-
-/*
- * the same as csum_partial_copy, but copies from user space.
- *
- * here even more important to align src and dst on a 32-bit (or even
- * better 64-bit) boundary
- */
-
-extern __wsum csum_partial_copy_from_user(const void __user *src, void *dst,
-						int len, __wsum sum, int *csum_err);
-
-__sum16 ip_fast_csum(const void *iph, unsigned int ihl);
-
-
-/*
- *	Fold a partial checksum
- */
-
-static inline __sum16 csum_fold(__wsum sum)
-{
-	__asm__("mov.l %0,er0\n\t"
-		"add.w e0,r0\n\t"
-		"xor.w e0,e0\n\t"
-		"rotxl.w e0\n\t"
-		"add.w e0,r0\n\t"
-		"sub.w e0,e0\n\t"
-		"mov.l er0,%0"
-		: "=r"(sum)
-		: "0"(sum)
-		: "er0");
-	return (__force __sum16)~sum;
-}
-
-
-/*
- * computes the checksum of the TCP/UDP pseudo-header
- * returns a 16-bit checksum, already complemented
- */
-
-static inline __wsum
-csum_tcpudp_nofold(__be32 saddr, __be32 daddr, unsigned short len,
-		  unsigned short proto, __wsum sum)
-{
-	__asm__ ("sub.l er0,er0\n\t"
-		 "add.l %2,%0\n\t"
-		 "addx	#0,r0l\n\t"
-		 "add.l	%3,%0\n\t"
-		 "addx	#0,r0l\n\t"
-		 "add.l %4,%0\n\t"
-		 "addx	#0,r0l\n\t"
-		 "add.l	er0,%0\n\t"
-		 "bcc	1f\n\t"
-		 "inc.l	#1,%0\n"
-		 "1:"
-		 : "=&r" (sum)
-		 : "0" (sum), "r" (daddr), "r" (saddr), "r" (len + proto)
-		 :"er0");
-	return sum;
-}
-
-static inline __sum16
-csum_tcpudp_magic(__be32 saddr, __be32 daddr, unsigned short len,
-		  unsigned short proto, __wsum sum)
-{
-	return csum_fold(csum_tcpudp_nofold(saddr,daddr,len,proto,sum));
-}
-
-/*
- * this routine is used for miscellaneous IP-like checksums, mainly
- * in icmp.c
- */
-
-extern __sum16 ip_compute_csum(const void *buff, int len);
-
-#endif /* _H8300_CHECKSUM_H */
diff --git a/arch/h8300/include/asm/cmpxchg.h b/arch/h8300/include/asm/cmpxchg.h
deleted file mode 100644
index cdb203e..0000000
--- a/arch/h8300/include/asm/cmpxchg.h
+++ /dev/null
@@ -1,60 +0,0 @@
-#ifndef __ARCH_H8300_CMPXCHG__
-#define __ARCH_H8300_CMPXCHG__
-
-#include <linux/irqflags.h>
-
-#define xchg(ptr,x) ((__typeof__(*(ptr)))__xchg((unsigned long)(x),(ptr),sizeof(*(ptr))))
-
-struct __xchg_dummy { unsigned long a[100]; };
-#define __xg(x) ((volatile struct __xchg_dummy *)(x))
-
-static inline unsigned long __xchg(unsigned long x, volatile void * ptr, int size)
-{
-  unsigned long tmp, flags;
-
-  local_irq_save(flags);
-
-  switch (size) {
-  case 1:
-    __asm__ __volatile__
-    ("mov.b %2,%0\n\t"
-     "mov.b %1,%2"
-    : "=&r" (tmp) : "r" (x), "m" (*__xg(ptr)) : "memory");
-    break;
-  case 2:
-    __asm__ __volatile__
-    ("mov.w %2,%0\n\t"
-     "mov.w %1,%2"
-    : "=&r" (tmp) : "r" (x), "m" (*__xg(ptr)) : "memory");
-    break;
-  case 4:
-    __asm__ __volatile__
-    ("mov.l %2,%0\n\t"
-     "mov.l %1,%2"
-    : "=&r" (tmp) : "r" (x), "m" (*__xg(ptr)) : "memory");
-    break;
-  default:
-    tmp = 0;	  
-  }
-  local_irq_restore(flags);
-  return tmp;
-}
-
-#include <asm-generic/cmpxchg-local.h>
-
-/*
- * cmpxchg_local and cmpxchg64_local are atomic wrt current CPU. Always make
- * them available.
- */
-#define cmpxchg_local(ptr, o, n)				  	       \
-	((__typeof__(*(ptr)))__cmpxchg_local_generic((ptr), (unsigned long)(o),\
-			(unsigned long)(n), sizeof(*(ptr))))
-#define cmpxchg64_local(ptr, o, n) __cmpxchg64_local_generic((ptr), (o), (n))
-
-#ifndef CONFIG_SMP
-#include <asm-generic/cmpxchg.h>
-#endif
-
-#define atomic_xchg(v, new) (xchg(&((v)->counter), new))
-
-#endif /* __ARCH_H8300_CMPXCHG__ */
diff --git a/arch/h8300/include/asm/cputime.h b/arch/h8300/include/asm/cputime.h
deleted file mode 100644
index 092e187..0000000
--- a/arch/h8300/include/asm/cputime.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef __H8300_CPUTIME_H
-#define __H8300_CPUTIME_H
-
-#include <asm-generic/cputime.h>
-
-#endif /* __H8300_CPUTIME_H */
diff --git a/arch/h8300/include/asm/current.h b/arch/h8300/include/asm/current.h
deleted file mode 100644
index 57d74ee..0000000
--- a/arch/h8300/include/asm/current.h
+++ /dev/null
@@ -1,25 +0,0 @@
-#ifndef _H8300_CURRENT_H
-#define _H8300_CURRENT_H
-/*
- *	current.h
- *	(C) Copyright 2000, Lineo, David McCullough <davidm@lineo.com>
- *	(C) Copyright 2002, Greg Ungerer (gerg@snapgear.com)
- *
- *	rather than dedicate a register (as the m68k source does), we
- *	just keep a global,  we should probably just change it all to be
- *	current and lose _current_task.
- */
-
-#include <linux/thread_info.h>
-#include <asm/thread_info.h>
-
-struct task_struct;
-
-static inline struct task_struct *get_current(void)
-{
-	return(current_thread_info()->task);
-}
-
-#define	current	get_current()
-
-#endif /* _H8300_CURRENT_H */
diff --git a/arch/h8300/include/asm/dbg.h b/arch/h8300/include/asm/dbg.h
deleted file mode 100644
index 2c6d1cb..0000000
--- a/arch/h8300/include/asm/dbg.h
+++ /dev/null
@@ -1,2 +0,0 @@
-#define DEBUG 1
-#define	BREAK asm volatile ("trap #3")
diff --git a/arch/h8300/include/asm/delay.h b/arch/h8300/include/asm/delay.h
deleted file mode 100644
index 743beba..0000000
--- a/arch/h8300/include/asm/delay.h
+++ /dev/null
@@ -1,38 +0,0 @@
-#ifndef _H8300_DELAY_H
-#define _H8300_DELAY_H
-
-#include <asm/param.h>
-
-/*
- * Copyright (C) 2002 Yoshinori Sato <ysato@sourceforge.jp>
- *
- * Delay routines, using a pre-computed "loops_per_second" value.
- */
-
-static inline void __delay(unsigned long loops)
-{
-	__asm__ __volatile__ ("1:\n\t"
-			      "dec.l #1,%0\n\t"
-			      "bne 1b"
-			      :"=r" (loops):"0"(loops));
-}
-
-/*
- * Use only for very small delays ( < 1 msec).  Should probably use a
- * lookup table, really, as the multiplications take much too long with
- * short delays.  This is a "reasonable" implementation, though (and the
- * first constant multiplications gets optimized away if the delay is
- * a constant)  
- */
-
-extern unsigned long loops_per_jiffy;
-
-static inline void udelay(unsigned long usecs)
-{
-	usecs *= 4295;		/* 2**32 / 1000000 */
-	usecs /= (loops_per_jiffy*HZ);
-	if (usecs)
-		__delay(usecs);
-}
-
-#endif /* _H8300_DELAY_H */
diff --git a/arch/h8300/include/asm/device.h b/arch/h8300/include/asm/device.h
deleted file mode 100644
index d8f9872..0000000
--- a/arch/h8300/include/asm/device.h
+++ /dev/null
@@ -1,7 +0,0 @@
-/*
- * Arch specific extensions to struct device
- *
- * This file is released under the GPLv2
- */
-#include <asm-generic/device.h>
-
diff --git a/arch/h8300/include/asm/div64.h b/arch/h8300/include/asm/div64.h
deleted file mode 100644
index 6cd978c..0000000
--- a/arch/h8300/include/asm/div64.h
+++ /dev/null
@@ -1 +0,0 @@
-#include <asm-generic/div64.h>
diff --git a/arch/h8300/include/asm/dma.h b/arch/h8300/include/asm/dma.h
deleted file mode 100644
index 3edbaaa..0000000
--- a/arch/h8300/include/asm/dma.h
+++ /dev/null
@@ -1,15 +0,0 @@
-#ifndef _H8300_DMA_H
-#define _H8300_DMA_H 
- 
-
-/*
- * Set number of channels of DMA on ColdFire for different implementations.
- */
-#define MAX_DMA_CHANNELS 0
-#define MAX_DMA_ADDRESS PAGE_OFFSET
-
-/* These are in kernel/dma.c: */
-extern int request_dma(unsigned int dmanr, const char *device_id);	/* reserve a DMA channel */
-extern void free_dma(unsigned int dmanr);	/* release it again */
- 
-#endif /* _H8300_DMA_H */
diff --git a/arch/h8300/include/asm/elf.h b/arch/h8300/include/asm/elf.h
deleted file mode 100644
index 6db7124..0000000
--- a/arch/h8300/include/asm/elf.h
+++ /dev/null
@@ -1,101 +0,0 @@
-#ifndef __ASMH8300_ELF_H
-#define __ASMH8300_ELF_H
-
-/*
- * ELF register definitions..
- */
-
-#include <asm/ptrace.h>
-#include <asm/user.h>
-
-typedef unsigned long elf_greg_t;
-
-#define ELF_NGREG (sizeof(struct user_regs_struct) / sizeof(elf_greg_t))
-typedef elf_greg_t elf_gregset_t[ELF_NGREG];
-typedef unsigned long elf_fpregset_t;
-
-/*
- * This is used to ensure we don't load something for the wrong architecture.
- */
-#define elf_check_arch(x) ((x)->e_machine == EM_H8_300)
-
-/*
- * These are used to set parameters in the core dumps.
- */
-#define ELF_CLASS	ELFCLASS32
-#define ELF_DATA	ELFDATA2MSB
-#define ELF_ARCH	EM_H8_300
-#if defined(__H8300H__)
-#define ELF_CORE_EFLAGS 0x810000
-#endif
-#if defined(__H8300S__)
-#define ELF_CORE_EFLAGS 0x820000
-#endif
-
-#define ELF_PLAT_INIT(_r)	_r->er1 = 0
-
-#define ELF_EXEC_PAGESIZE	4096
-
-/* This is the location that an ET_DYN program is loaded if exec'ed.  Typical
-   use of this is to invoke "./ld.so someprog" to test out a new version of
-   the loader.  We need to make sure that it is out of the way of the program
-   that it will "exec", and that there is sufficient room for the brk.  */
-
-#define ELF_ET_DYN_BASE         0xD0000000UL
-
-/* This yields a mask that user programs can use to figure out what
-   instruction set this cpu supports.  */
-
-#define ELF_HWCAP	(0)
-
-/* This yields a string that ld.so will use to load implementation
-   specific libraries for optimization.  This is more specific in
-   intent than poking at uname or /proc/cpuinfo.  */
-
-#define ELF_PLATFORM  (NULL)
-
-#define R_H8_NONE       0
-#define R_H8_DIR32      1
-#define R_H8_DIR32_28   2
-#define R_H8_DIR32_24   3
-#define R_H8_DIR32_16   4
-#define R_H8_DIR32U     6
-#define R_H8_DIR32U_28  7
-#define R_H8_DIR32U_24  8
-#define R_H8_DIR32U_20  9
-#define R_H8_DIR32U_16 10
-#define R_H8_DIR24     11
-#define R_H8_DIR24_20  12
-#define R_H8_DIR24_16  13
-#define R_H8_DIR24U    14
-#define R_H8_DIR24U_20 15
-#define R_H8_DIR24U_16 16
-#define R_H8_DIR16     17
-#define R_H8_DIR16U    18
-#define R_H8_DIR16S_32 19
-#define R_H8_DIR16S_28 20
-#define R_H8_DIR16S_24 21
-#define R_H8_DIR16S_20 22
-#define R_H8_DIR16S    23
-#define R_H8_DIR8      24
-#define R_H8_DIR8U     25
-#define R_H8_DIR8Z_32  26
-#define R_H8_DIR8Z_28  27
-#define R_H8_DIR8Z_24  28
-#define R_H8_DIR8Z_20  29
-#define R_H8_DIR8Z_16  30
-#define R_H8_PCREL16   31
-#define R_H8_PCREL8    32
-#define R_H8_BPOS      33
-#define R_H8_PCREL32   34
-#define R_H8_GOT32O    35
-#define R_H8_GOT16O    36
-#define R_H8_DIR16A8   59
-#define R_H8_DIR16R8   60
-#define R_H8_DIR24A8   61
-#define R_H8_DIR24R8   62
-#define R_H8_DIR32A16  63
-#define R_H8_ABS32     65
-#define R_H8_ABS32A16 127
-
-#endif
diff --git a/arch/h8300/include/asm/emergency-restart.h b/arch/h8300/include/asm/emergency-restart.h
deleted file mode 100644
index 108d8c4..0000000
--- a/arch/h8300/include/asm/emergency-restart.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _ASM_EMERGENCY_RESTART_H
-#define _ASM_EMERGENCY_RESTART_H
-
-#include <asm-generic/emergency-restart.h>
-
-#endif /* _ASM_EMERGENCY_RESTART_H */
diff --git a/arch/h8300/include/asm/fb.h b/arch/h8300/include/asm/fb.h
deleted file mode 100644
index c7df380..0000000
--- a/arch/h8300/include/asm/fb.h
+++ /dev/null
@@ -1,12 +0,0 @@
-#ifndef _ASM_FB_H_
-#define _ASM_FB_H_
-#include <linux/fb.h>
-
-#define fb_pgprotect(...) do {} while (0)
-
-static inline int fb_is_primary_device(struct fb_info *info)
-{
-	return 0;
-}
-
-#endif /* _ASM_FB_H_ */
diff --git a/arch/h8300/include/asm/flat.h b/arch/h8300/include/asm/flat.h
deleted file mode 100644
index bd12b31..0000000
--- a/arch/h8300/include/asm/flat.h
+++ /dev/null
@@ -1,26 +0,0 @@
-/*
- * include/asm-h8300/flat.h -- uClinux flat-format executables
- */
-
-#ifndef __H8300_FLAT_H__
-#define __H8300_FLAT_H__
-
-#define	flat_argvp_envp_on_stack()		1
-#define	flat_old_ram_flag(flags)		1
-#define	flat_reloc_valid(reloc, size)		((reloc) <= (size))
-#define	flat_set_persistent(relval, p)		0
-
-/*
- * on the H8 a couple of the relocations have an instruction in the
- * top byte.  As there can only be 24bits of address space,  we just
- * always preserve that 8bits at the top,  when it isn't an instruction
- * is is 0 (davidm@snapgear.com)
- */
-
-#define	flat_get_relocate_addr(rel)		(rel)
-#define flat_get_addr_from_rp(rp, relval, flags, persistent) \
-        (get_unaligned(rp) & ((flags & FLAT_FLAG_GOTPIC) ? 0xffffffff: 0x00ffffff))
-#define flat_put_addr_at_rp(rp, addr, rel) \
-	put_unaligned (((*(char *)(rp)) << 24) | ((addr) & 0x00ffffff), rp)
-
-#endif /* __H8300_FLAT_H__ */
diff --git a/arch/h8300/include/asm/fpu.h b/arch/h8300/include/asm/fpu.h
deleted file mode 100644
index 4fc416e..0000000
--- a/arch/h8300/include/asm/fpu.h
+++ /dev/null
@@ -1 +0,0 @@
-/* Nothing do */
diff --git a/arch/h8300/include/asm/ftrace.h b/arch/h8300/include/asm/ftrace.h
deleted file mode 100644
index 40a8c17..0000000
--- a/arch/h8300/include/asm/ftrace.h
+++ /dev/null
@@ -1 +0,0 @@
-/* empty */
diff --git a/arch/h8300/include/asm/futex.h b/arch/h8300/include/asm/futex.h
deleted file mode 100644
index 6a332a9..0000000
--- a/arch/h8300/include/asm/futex.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _ASM_FUTEX_H
-#define _ASM_FUTEX_H
-
-#include <asm-generic/futex.h>
-
-#endif
diff --git a/arch/h8300/include/asm/gpio-internal.h b/arch/h8300/include/asm/gpio-internal.h
deleted file mode 100644
index a714f0c..0000000
--- a/arch/h8300/include/asm/gpio-internal.h
+++ /dev/null
@@ -1,52 +0,0 @@
-#ifndef _H8300_GPIO_H
-#define _H8300_GPIO_H
-
-#define H8300_GPIO_P1 0
-#define H8300_GPIO_P2 1
-#define H8300_GPIO_P3 2
-#define H8300_GPIO_P4 3
-#define H8300_GPIO_P5 4
-#define H8300_GPIO_P6 5
-#define H8300_GPIO_P7 6
-#define H8300_GPIO_P8 7
-#define H8300_GPIO_P9 8
-#define H8300_GPIO_PA 9
-#define H8300_GPIO_PB 10
-#define H8300_GPIO_PC 11
-#define H8300_GPIO_PD 12
-#define H8300_GPIO_PE 13
-#define H8300_GPIO_PF 14
-#define H8300_GPIO_PG 15
-#define H8300_GPIO_PH 16
-
-#define H8300_GPIO_B7 0x80
-#define H8300_GPIO_B6 0x40
-#define H8300_GPIO_B5 0x20
-#define H8300_GPIO_B4 0x10
-#define H8300_GPIO_B3 0x08
-#define H8300_GPIO_B2 0x04
-#define H8300_GPIO_B1 0x02
-#define H8300_GPIO_B0 0x01
-
-#define H8300_GPIO_INPUT 0
-#define H8300_GPIO_OUTPUT 1
-
-#define H8300_GPIO_RESERVE(port, bits) \
-        h8300_reserved_gpio(port, bits)
-
-#define H8300_GPIO_FREE(port, bits) \
-        h8300_free_gpio(port, bits)
-
-#define H8300_GPIO_DDR(port, bit, dir) \
-        h8300_set_gpio_dir(((port) << 8) | (bit), dir)
-
-#define H8300_GPIO_GETDIR(port, bit) \
-        h8300_get_gpio_dir(((port) << 8) | (bit))
-
-extern int h8300_reserved_gpio(int port, int bits);
-extern int h8300_free_gpio(int port, int bits);
-extern int h8300_set_gpio_dir(int port_bit, int dir);
-extern int h8300_get_gpio_dir(int port_bit);
-extern int h8300_init_gpio(void);
-
-#endif
diff --git a/arch/h8300/include/asm/hardirq.h b/arch/h8300/include/asm/hardirq.h
deleted file mode 100644
index c2e1aa0..0000000
--- a/arch/h8300/include/asm/hardirq.h
+++ /dev/null
@@ -1,19 +0,0 @@
-#ifndef __H8300_HARDIRQ_H
-#define __H8300_HARDIRQ_H
-
-#include <asm/irq.h>
-
-#define HARDIRQ_BITS	8
-
-/*
- * The hardirq mask has to be large enough to have
- * space for potentially all IRQ sources in the system
- * nesting on a single CPU:
- */
-#if (1 << HARDIRQ_BITS) < NR_IRQS
-# error HARDIRQ_BITS is too low!
-#endif
-
-#include <asm-generic/hardirq.h>
-
-#endif
diff --git a/arch/h8300/include/asm/hw_irq.h b/arch/h8300/include/asm/hw_irq.h
deleted file mode 100644
index d75a5a1..0000000
--- a/arch/h8300/include/asm/hw_irq.h
+++ /dev/null
@@ -1 +0,0 @@
-/* Do Nothing */
diff --git a/arch/h8300/include/asm/io.h b/arch/h8300/include/asm/io.h
deleted file mode 100644
index c1a8df2..0000000
--- a/arch/h8300/include/asm/io.h
+++ /dev/null
@@ -1,358 +0,0 @@
-#ifndef _H8300_IO_H
-#define _H8300_IO_H
-
-#ifdef __KERNEL__
-
-#include <asm/virtconvert.h>
-
-#if defined(CONFIG_H83007) || defined(CONFIG_H83068)
-#include <asm/regs306x.h>
-#elif defined(CONFIG_H8S2678)
-#include <asm/regs267x.h>
-#else
-#error UNKNOWN CPU TYPE
-#endif
-
-
-/*
- * These are for ISA/PCI shared memory _only_ and should never be used
- * on any other type of memory, including Zorro memory. They are meant to
- * access the bus in the bus byte order which is little-endian!.
- *
- * readX/writeX() are used to access memory mapped devices. On some
- * architectures the memory mapped IO stuff needs to be accessed
- * differently. On the m68k architecture, we just read/write the
- * memory location directly.
- */
-/* ++roman: The assignments to temp. vars avoid that gcc sometimes generates
- * two accesses to memory, which may be undesirable for some devices.
- */
-
-/*
- * swap functions are sometimes needed to interface little-endian hardware
- */
-
-static inline unsigned short _swapw(volatile unsigned short v)
-{
-#ifndef H8300_IO_NOSWAP
-	unsigned short r;
-	__asm__("xor.b %w0,%x0\n\t"
-		"xor.b %x0,%w0\n\t"
-		"xor.b %w0,%x0"
-		:"=r"(r)
-		:"0"(v));
-	return r;
-#else
-	return v;
-#endif
-}
-
-static inline unsigned long _swapl(volatile unsigned long v)
-{
-#ifndef H8300_IO_NOSWAP
-	unsigned long r;
-	__asm__("xor.b %w0,%x0\n\t"
-		"xor.b %x0,%w0\n\t"
-		"xor.b %w0,%x0\n\t"
-		"xor.w %e0,%f0\n\t"
-		"xor.w %f0,%e0\n\t"
-		"xor.w %e0,%f0\n\t"
-		"xor.b %w0,%x0\n\t"
-		"xor.b %x0,%w0\n\t"
-		"xor.b %w0,%x0"
-		:"=r"(r)
-		:"0"(v));
-	return r;
-#else
-	return v;
-#endif
-}
-
-#define readb(addr) \
-    ({ unsigned char __v = \
-     *(volatile unsigned char *)((unsigned long)(addr) & 0x00ffffff); \
-     __v; })
-#define readw(addr) \
-    ({ unsigned short __v = \
-     *(volatile unsigned short *)((unsigned long)(addr) & 0x00ffffff); \
-     __v; })
-#define readl(addr) \
-    ({ unsigned long __v = \
-     *(volatile unsigned long *)((unsigned long)(addr) & 0x00ffffff); \
-     __v; })
-
-#define writeb(b,addr) (void)((*(volatile unsigned char *) \
-                             ((unsigned long)(addr) & 0x00ffffff)) = (b))
-#define writew(b,addr) (void)((*(volatile unsigned short *) \
-                             ((unsigned long)(addr) & 0x00ffffff)) = (b))
-#define writel(b,addr) (void)((*(volatile unsigned long *) \
-                             ((unsigned long)(addr) & 0x00ffffff)) = (b))
-#define readb_relaxed(addr) readb(addr)
-#define readw_relaxed(addr) readw(addr)
-#define readl_relaxed(addr) readl(addr)
-
-#define __raw_readb readb
-#define __raw_readw readw
-#define __raw_readl readl
-#define __raw_writeb writeb
-#define __raw_writew writew
-#define __raw_writel writel
-
-static inline int h8300_buswidth(unsigned int addr)
-{
-	return (*(volatile unsigned char *)ABWCR & (1 << ((addr >> 21) & 7))) == 0;
-}
-
-static inline void io_outsb(unsigned int addr, const void *buf, int len)
-{
-	volatile unsigned char  *ap_b = (volatile unsigned char *) addr;
-	volatile unsigned short *ap_w = (volatile unsigned short *) addr;
-	unsigned char *bp = (unsigned char *) buf;
-
-	if(h8300_buswidth(addr) && (addr & 1)) {
-		while (len--)
-			*ap_w = *bp++;
-	} else {
-		while (len--)
-			*ap_b = *bp++;
-	}
-}
-
-static inline void io_outsw(unsigned int addr, const void *buf, int len)
-{
-	volatile unsigned short *ap = (volatile unsigned short *) addr;
-	unsigned short *bp = (unsigned short *) buf;
-	while (len--)
-		*ap = _swapw(*bp++);
-}
-
-static inline void io_outsl(unsigned int addr, const void *buf, int len)
-{
-	volatile unsigned long *ap = (volatile unsigned long *) addr;
-	unsigned long *bp = (unsigned long *) buf;
-	while (len--)
-		*ap = _swapl(*bp++);
-}
-
-static inline void io_outsw_noswap(unsigned int addr, const void *buf, int len)
-{
-	volatile unsigned short *ap = (volatile unsigned short *) addr;
-	unsigned short *bp = (unsigned short *) buf;
-	while (len--)
-		*ap = *bp++;
-}
-
-static inline void io_outsl_noswap(unsigned int addr, const void *buf, int len)
-{
-	volatile unsigned long *ap = (volatile unsigned long *) addr;
-	unsigned long *bp = (unsigned long *) buf;
-	while (len--)
-		*ap = *bp++;
-}
-
-static inline void io_insb(unsigned int addr, void *buf, int len)
-{
-	volatile unsigned char  *ap_b;
-	volatile unsigned short *ap_w;
-	unsigned char *bp = (unsigned char *) buf;
-
-	if(h8300_buswidth(addr)) {
-		ap_w = (volatile unsigned short *)(addr & ~1);
-		while (len--)
-			*bp++ = *ap_w & 0xff;
-	} else {
-		ap_b = (volatile unsigned char *)addr;
-		while (len--)
-			*bp++ = *ap_b;
-	}
-}
-
-static inline void io_insw(unsigned int addr, void *buf, int len)
-{
-	volatile unsigned short *ap = (volatile unsigned short *) addr;
-	unsigned short *bp = (unsigned short *) buf;
-	while (len--)
-		*bp++ = _swapw(*ap);
-}
-
-static inline void io_insl(unsigned int addr, void *buf, int len)
-{
-	volatile unsigned long *ap = (volatile unsigned long *) addr;
-	unsigned long *bp = (unsigned long *) buf;
-	while (len--)
-		*bp++ = _swapl(*ap);
-}
-
-static inline void io_insw_noswap(unsigned int addr, void *buf, int len)
-{
-	volatile unsigned short *ap = (volatile unsigned short *) addr;
-	unsigned short *bp = (unsigned short *) buf;
-	while (len--)
-		*bp++ = *ap;
-}
-
-static inline void io_insl_noswap(unsigned int addr, void *buf, int len)
-{
-	volatile unsigned long *ap = (volatile unsigned long *) addr;
-	unsigned long *bp = (unsigned long *) buf;
-	while (len--)
-		*bp++ = *ap;
-}
-
-/*
- *	make the short names macros so specific devices
- *	can override them as required
- */
-
-#define memset_io(a,b,c)	memset((void *)(a),(b),(c))
-#define memcpy_fromio(a,b,c)	memcpy((a),(void *)(b),(c))
-#define memcpy_toio(a,b,c)	memcpy((void *)(a),(b),(c))
-
-#define mmiowb()
-
-#define inb(addr)    ((h8300_buswidth(addr))?readw((addr) & ~1) & 0xff:readb(addr))
-#define inw(addr)    _swapw(readw(addr))
-#define inl(addr)    _swapl(readl(addr))
-#define outb(x,addr) ((void)((h8300_buswidth(addr) && \
-                      ((addr) & 1))?writew(x,(addr) & ~1):writeb(x,addr)))
-#define outw(x,addr) ((void) writew(_swapw(x),addr))
-#define outl(x,addr) ((void) writel(_swapl(x),addr))
-
-#define inb_p(addr)    inb(addr)
-#define inw_p(addr)    inw(addr)
-#define inl_p(addr)    inl(addr)
-#define outb_p(x,addr) outb(x,addr)
-#define outw_p(x,addr) outw(x,addr)
-#define outl_p(x,addr) outl(x,addr)
-
-#define outsb(a,b,l) io_outsb(a,b,l)
-#define outsw(a,b,l) io_outsw(a,b,l)
-#define outsl(a,b,l) io_outsl(a,b,l)
-
-#define insb(a,b,l) io_insb(a,b,l)
-#define insw(a,b,l) io_insw(a,b,l)
-#define insl(a,b,l) io_insl(a,b,l)
-
-#define IO_SPACE_LIMIT 0xffffff
-
-
-/* Values for nocacheflag and cmode */
-#define IOMAP_FULL_CACHING		0
-#define IOMAP_NOCACHE_SER		1
-#define IOMAP_NOCACHE_NONSER		2
-#define IOMAP_WRITETHROUGH		3
-
-extern void *__ioremap(unsigned long physaddr, unsigned long size, int cacheflag);
-extern void __iounmap(void *addr, unsigned long size);
-
-static inline void *ioremap(unsigned long physaddr, unsigned long size)
-{
-	return __ioremap(physaddr, size, IOMAP_NOCACHE_SER);
-}
-static inline void *ioremap_nocache(unsigned long physaddr, unsigned long size)
-{
-	return __ioremap(physaddr, size, IOMAP_NOCACHE_SER);
-}
-static inline void *ioremap_writethrough(unsigned long physaddr, unsigned long size)
-{
-	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
-}
-static inline void *ioremap_fullcache(unsigned long physaddr, unsigned long size)
-{
-	return __ioremap(physaddr, size, IOMAP_FULL_CACHING);
-}
-
-extern void iounmap(void *addr);
-
-/* H8/300 internal I/O functions */
-static __inline__ unsigned char ctrl_inb(unsigned long addr)
-{
-	return *(volatile unsigned char*)addr;
-}
-
-static __inline__ unsigned short ctrl_inw(unsigned long addr)
-{
-	return *(volatile unsigned short*)addr;
-}
-
-static __inline__ unsigned long ctrl_inl(unsigned long addr)
-{
-	return *(volatile unsigned long*)addr;
-}
-
-static __inline__ void ctrl_outb(unsigned char b, unsigned long addr)
-{
-	*(volatile unsigned char*)addr = b;
-}
-
-static __inline__ void ctrl_outw(unsigned short b, unsigned long addr)
-{
-	*(volatile unsigned short*)addr = b;
-}
-
-static __inline__ void ctrl_outl(unsigned long b, unsigned long addr)
-{
-        *(volatile unsigned long*)addr = b;
-}
-
-static __inline__ void ctrl_bclr(int b, unsigned long addr)
-{
-	if (__builtin_constant_p(b))
-		switch (b) {
-		case 0: __asm__("bclr #0,@%0"::"r"(addr)); break;
-		case 1: __asm__("bclr #1,@%0"::"r"(addr)); break;
-		case 2: __asm__("bclr #2,@%0"::"r"(addr)); break;
-		case 3: __asm__("bclr #3,@%0"::"r"(addr)); break;
-		case 4: __asm__("bclr #4,@%0"::"r"(addr)); break;
-		case 5: __asm__("bclr #5,@%0"::"r"(addr)); break;
-		case 6: __asm__("bclr #6,@%0"::"r"(addr)); break;
-		case 7: __asm__("bclr #7,@%0"::"r"(addr)); break;
-		}
-	else
-		__asm__("bclr %w0,@%1"::"r"(b), "r"(addr));
-}
-
-static __inline__ void ctrl_bset(int b, unsigned long addr)
-{
-	if (__builtin_constant_p(b))
-		switch (b) {
-		case 0: __asm__("bset #0,@%0"::"r"(addr)); break;
-		case 1: __asm__("bset #1,@%0"::"r"(addr)); break;
-		case 2: __asm__("bset #2,@%0"::"r"(addr)); break;
-		case 3: __asm__("bset #3,@%0"::"r"(addr)); break;
-		case 4: __asm__("bset #4,@%0"::"r"(addr)); break;
-		case 5: __asm__("bset #5,@%0"::"r"(addr)); break;
-		case 6: __asm__("bset #6,@%0"::"r"(addr)); break;
-		case 7: __asm__("bset #7,@%0"::"r"(addr)); break;
-		}
-	else
-		__asm__("bset %w0,@%1"::"r"(b), "r"(addr));
-}
-
-/* Pages to physical address... */
-#define page_to_phys(page)      ((page - mem_map) << PAGE_SHIFT)
-#define page_to_bus(page)       ((page - mem_map) << PAGE_SHIFT)
-
-/*
- * Macros used for converting between virtual and physical mappings.
- */
-#define phys_to_virt(vaddr)	((void *) (vaddr))
-#define virt_to_phys(vaddr)	((unsigned long) (vaddr))
-
-#define virt_to_bus virt_to_phys
-#define bus_to_virt phys_to_virt
-
-/*
- * Convert a physical pointer to a virtual kernel pointer for /dev/mem
- * access
- */
-#define xlate_dev_mem_ptr(p)	__va(p)
-
-/*
- * Convert a virtual cached pointer to an uncached pointer
- */
-#define xlate_dev_kmem_ptr(p)	p
-
-#endif /* __KERNEL__ */
-
-#endif /* _H8300_IO_H */
diff --git a/arch/h8300/include/asm/irq.h b/arch/h8300/include/asm/irq.h
deleted file mode 100644
index 13d7c60..0000000
--- a/arch/h8300/include/asm/irq.h
+++ /dev/null
@@ -1,49 +0,0 @@
-#ifndef _H8300_IRQ_H_
-#define _H8300_IRQ_H_
-
-#include <asm/ptrace.h>
-
-#if defined(CONFIG_CPU_H8300H)
-#define NR_IRQS 64
-#define EXT_IRQ0 12
-#define EXT_IRQ1 13
-#define EXT_IRQ2 14
-#define EXT_IRQ3 15
-#define EXT_IRQ4 16
-#define EXT_IRQ5 17
-#define EXT_IRQ6 18
-#define EXT_IRQ7 19
-#define EXT_IRQS 5
-#define IER_REGS *(volatile unsigned char *)IER
-#endif
-#if defined(CONFIG_CPU_H8S)
-#define NR_IRQS 128
-#define EXT_IRQ0 16
-#define EXT_IRQ1 17
-#define EXT_IRQ2 18
-#define EXT_IRQ3 19
-#define EXT_IRQ4 20
-#define EXT_IRQ5 21
-#define EXT_IRQ6 22
-#define EXT_IRQ7 23
-#define EXT_IRQ8 24
-#define EXT_IRQ9 25
-#define EXT_IRQ10 26
-#define EXT_IRQ11 27
-#define EXT_IRQ12 28
-#define EXT_IRQ13 29
-#define EXT_IRQ14 30
-#define EXT_IRQ15 31
-#define EXT_IRQS 15
-
-#define IER_REGS *(volatile unsigned short *)IER
-#endif
-
-static __inline__ int irq_canonicalize(int irq)
-{
-	return irq;
-}
-
-typedef void (*h8300_vector)(void);
-
-#endif /* _H8300_IRQ_H_ */
diff --git a/arch/h8300/include/asm/irq_regs.h b/arch/h8300/include/asm/irq_regs.h
deleted file mode 100644
index 3dd9c0b..0000000
--- a/arch/h8300/include/asm/irq_regs.h
+++ /dev/null
@@ -1 +0,0 @@
-#include <asm-generic/irq_regs.h>
diff --git a/arch/h8300/include/asm/irqflags.h b/arch/h8300/include/asm/irqflags.h
deleted file mode 100644
index 9617cd5..0000000
--- a/arch/h8300/include/asm/irqflags.h
+++ /dev/null
@@ -1,43 +0,0 @@
-#ifndef _H8300_IRQFLAGS_H
-#define _H8300_IRQFLAGS_H
-
-static inline unsigned long arch_local_save_flags(void)
-{
-	unsigned long flags;
-	asm volatile ("stc ccr,%w0" : "=r" (flags));
-	return flags;
-}
-
-static inline void arch_local_irq_disable(void)
-{
-	asm volatile ("orc  #0x80,ccr" : : : "memory");
-}
-
-static inline void arch_local_irq_enable(void)
-{
-	asm volatile ("andc #0x7f,ccr" : : : "memory");
-}
-
-static inline unsigned long arch_local_irq_save(void)
-{
-	unsigned long flags = arch_local_save_flags();
-	arch_local_irq_disable();
-	return flags;
-}
-
-static inline void arch_local_irq_restore(unsigned long flags)
-{
-	asm volatile ("ldc %w0,ccr" : : "r" (flags) : "memory");
-}
-
-static inline bool arch_irqs_disabled_flags(unsigned long flags)
-{
-	return (flags & 0x80) == 0x80;
-}
-
-static inline bool arch_irqs_disabled(void)
-{
-	return arch_irqs_disabled_flags(arch_local_save_flags());
-}
-
-#endif /* _H8300_IRQFLAGS_H */
diff --git a/arch/h8300/include/asm/kdebug.h b/arch/h8300/include/asm/kdebug.h
deleted file mode 100644
index 6ece1b0..0000000
--- a/arch/h8300/include/asm/kdebug.h
+++ /dev/null
@@ -1 +0,0 @@
-#include <asm-generic/kdebug.h>
diff --git a/arch/h8300/include/asm/kmap_types.h b/arch/h8300/include/asm/kmap_types.h
deleted file mode 100644
index be12a71..0000000
--- a/arch/h8300/include/asm/kmap_types.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _ASM_H8300_KMAP_TYPES_H
-#define _ASM_H8300_KMAP_TYPES_H
-
-#include <asm-generic/kmap_types.h>
-
-#endif
diff --git a/arch/h8300/include/asm/local.h b/arch/h8300/include/asm/local.h
deleted file mode 100644
index fdd4efe..0000000
--- a/arch/h8300/include/asm/local.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _H8300_LOCAL_H_
-#define _H8300_LOCAL_H_
-
-#include <asm-generic/local.h>
-
-#endif
diff --git a/arch/h8300/include/asm/local64.h b/arch/h8300/include/asm/local64.h
deleted file mode 100644
index 36c93b5..0000000
--- a/arch/h8300/include/asm/local64.h
+++ /dev/null
@@ -1 +0,0 @@
-#include <asm-generic/local64.h>
diff --git a/arch/h8300/include/asm/mc146818rtc.h b/arch/h8300/include/asm/mc146818rtc.h
deleted file mode 100644
index ab9d964..0000000
--- a/arch/h8300/include/asm/mc146818rtc.h
+++ /dev/null
@@ -1,9 +0,0 @@
-/*
- * Machine dependent access functions for RTC registers.
- */
-#ifndef _H8300_MC146818RTC_H
-#define _H8300_MC146818RTC_H
-
-/* empty include file to satisfy the include in genrtc.c/ide-geometry.c */
-
-#endif /* _H8300_MC146818RTC_H */
diff --git a/arch/h8300/include/asm/mmu_context.h b/arch/h8300/include/asm/mmu_context.h
deleted file mode 100644
index f44b730..0000000
--- a/arch/h8300/include/asm/mmu_context.h
+++ /dev/null
@@ -1,32 +0,0 @@
-#ifndef __H8300_MMU_CONTEXT_H
-#define __H8300_MMU_CONTEXT_H
-
-#include <asm/setup.h>
-#include <asm/page.h>
-#include <asm/pgalloc.h>
-#include <asm-generic/mm_hooks.h>
-
-static inline void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk)
-{
-}
-
-static inline int
-init_new_context(struct task_struct *tsk, struct mm_struct *mm)
-{
-	// mm->context = virt_to_phys(mm->pgd);
-	return(0);
-}
-
-#define destroy_context(mm)		do { } while(0)
-#define deactivate_mm(tsk,mm)           do { } while(0)
-
-static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next, struct task_struct *tsk)
-{
-}
-
-static inline void activate_mm(struct mm_struct *prev_mm,
-			       struct mm_struct *next_mm)
-{
-}
-
-#endif
diff --git a/arch/h8300/include/asm/mutex.h b/arch/h8300/include/asm/mutex.h
deleted file mode 100644
index 458c1f7..0000000
--- a/arch/h8300/include/asm/mutex.h
+++ /dev/null
@@ -1,9 +0,0 @@
-/*
- * Pull in the generic implementation for the mutex fastpath.
- *
- * TODO: implement optimized primitives instead, or leave the generic
- * implementation in place, or pick the atomic_xchg() based generic
- * implementation. (see asm-generic/mutex-xchg.h for details)
- */
-
-#include <asm-generic/mutex-dec.h>
diff --git a/arch/h8300/include/asm/page.h b/arch/h8300/include/asm/page.h
deleted file mode 100644
index 837381a..0000000
--- a/arch/h8300/include/asm/page.h
+++ /dev/null
@@ -1,78 +0,0 @@
-#ifndef _H8300_PAGE_H
-#define _H8300_PAGE_H
-
-/* PAGE_SHIFT determines the page size */
-
-#define PAGE_SHIFT	(12)
-#define PAGE_SIZE	(1UL << PAGE_SHIFT)
-#define PAGE_MASK	(~(PAGE_SIZE-1))
-
-#include <asm/setup.h>
-
-#ifndef __ASSEMBLY__
- 
-#define get_user_page(vaddr)		__get_free_page(GFP_KERNEL)
-#define free_user_page(page, addr)	free_page(addr)
-
-#define clear_page(page)	memset((page), 0, PAGE_SIZE)
-#define copy_page(to,from)	memcpy((to), (from), PAGE_SIZE)
-
-#define clear_user_page(page, vaddr, pg)	clear_page(page)
-#define copy_user_page(to, from, vaddr, pg)	copy_page(to, from)
-
-#define __alloc_zeroed_user_highpage(movableflags, vma, vaddr) \
-	alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO | movableflags, vma, vaddr)
-#define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
-
-/*
- * These are used to make use of C type-checking..
- */
-typedef struct { unsigned long pte; } pte_t;
-typedef struct { unsigned long pmd[16]; } pmd_t;
-typedef struct { unsigned long pgd; } pgd_t;
-typedef struct { unsigned long pgprot; } pgprot_t;
-typedef struct page *pgtable_t;
-
-#define pte_val(x)	((x).pte)
-#define pmd_val(x)	((&x)->pmd[0])
-#define pgd_val(x)	((x).pgd)
-#define pgprot_val(x)	((x).pgprot)
-
-#define __pte(x)	((pte_t) { (x) } )
-#define __pmd(x)	((pmd_t) { (x) } )
-#define __pgd(x)	((pgd_t) { (x) } )
-#define __pgprot(x)	((pgprot_t) { (x) } )
-
-extern unsigned long memory_start;
-extern unsigned long memory_end;
-
-#endif /* !__ASSEMBLY__ */
-
-#include <asm/page_offset.h>
-
-#define PAGE_OFFSET		(PAGE_OFFSET_RAW)
-
-#ifndef __ASSEMBLY__
-
-#define __pa(vaddr)		virt_to_phys(vaddr)
-#define __va(paddr)		phys_to_virt((unsigned long)paddr)
-
-#define virt_to_pfn(kaddr)	(__pa(kaddr) >> PAGE_SHIFT)
-#define pfn_to_virt(pfn)	__va((pfn) << PAGE_SHIFT)
-
-#define MAP_NR(addr)		(((unsigned long)(addr)-PAGE_OFFSET) >> PAGE_SHIFT)
-#define virt_to_page(addr)	(mem_map + (((unsigned long)(addr)-PAGE_OFFSET) >> PAGE_SHIFT))
-#define page_to_virt(page)	((((page) - mem_map) << PAGE_SHIFT) + PAGE_OFFSET)
-#define pfn_valid(page)	        (page < max_mapnr)
-
-#define ARCH_PFN_OFFSET		(PAGE_OFFSET >> PAGE_SHIFT)
-
-#define	virt_addr_valid(kaddr)	(((void *)(kaddr) >= (void *)PAGE_OFFSET) && \
-				((void *)(kaddr) < (void *)memory_end))
-
-#endif /* __ASSEMBLY__ */
-
-#include <asm-generic/memory_model.h>
-#include <asm-generic/getorder.h>
-
-#endif /* _H8300_PAGE_H */
diff --git a/arch/h8300/include/asm/page_offset.h b/arch/h8300/include/asm/page_offset.h
deleted file mode 100644
index f870646..0000000
--- a/arch/h8300/include/asm/page_offset.h
+++ /dev/null
@@ -1,3 +0,0 @@
-
-#define PAGE_OFFSET_RAW		0x00000000
-
diff --git a/arch/h8300/include/asm/param.h b/arch/h8300/include/asm/param.h
deleted file mode 100644
index c3909e7..0000000
--- a/arch/h8300/include/asm/param.h
+++ /dev/null
@@ -1,9 +0,0 @@
-#ifndef _H8300_PARAM_H
-#define _H8300_PARAM_H
-
-#include <uapi/asm/param.h>
-
-#define HZ		CONFIG_HZ
-#define	USER_HZ		HZ
-#define	CLOCKS_PER_SEC	(USER_HZ)
-#endif /* _H8300_PARAM_H */
diff --git a/arch/h8300/include/asm/pci.h b/arch/h8300/include/asm/pci.h
deleted file mode 100644
index 0b2acaa..0000000
--- a/arch/h8300/include/asm/pci.h
+++ /dev/null
@@ -1,19 +0,0 @@
-#ifndef _ASM_H8300_PCI_H
-#define _ASM_H8300_PCI_H
-
-/*
- * asm-h8300/pci.h - H8/300 specific PCI declarations.
- *
- * Yoshinori Sato <ysato@users.sourceforge.jp>
- */
-
-#define pcibios_assign_all_busses()	0
-
-static inline void pcibios_penalize_isa_irq(int irq, int active)
-{
-	/* We don't do dynamic PCI IRQ allocation */
-}
-
-#define PCI_DMA_BUS_IS_PHYS	(1)
-
-#endif /* _ASM_H8300_PCI_H */
diff --git a/arch/h8300/include/asm/percpu.h b/arch/h8300/include/asm/percpu.h
deleted file mode 100644
index 72c03e3..0000000
--- a/arch/h8300/include/asm/percpu.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef __ARCH_H8300_PERCPU__
-#define __ARCH_H8300_PERCPU__
-
-#include <asm-generic/percpu.h>
-
-#endif /* __ARCH_H8300_PERCPU__ */
diff --git a/arch/h8300/include/asm/pgalloc.h b/arch/h8300/include/asm/pgalloc.h
deleted file mode 100644
index c2e89a2..0000000
--- a/arch/h8300/include/asm/pgalloc.h
+++ /dev/null
@@ -1,8 +0,0 @@
-#ifndef _H8300_PGALLOC_H
-#define _H8300_PGALLOC_H
-
-#include <asm/setup.h>
-
-#define check_pgt_cache()	do { } while (0)
-
-#endif /* _H8300_PGALLOC_H */
diff --git a/arch/h8300/include/asm/pgtable.h b/arch/h8300/include/asm/pgtable.h
deleted file mode 100644
index 7ca20f8..0000000
--- a/arch/h8300/include/asm/pgtable.h
+++ /dev/null
@@ -1,73 +0,0 @@
-#ifndef _H8300_PGTABLE_H
-#define _H8300_PGTABLE_H
-
-#include <asm-generic/4level-fixup.h>
-
-#include <linux/slab.h>
-#include <asm/processor.h>
-#include <asm/page.h>
-#include <asm/io.h>
-
-#define pgd_present(pgd)     (1)       /* pages are always present on NO_MM */
-#define pgd_none(pgd)		(0)
-#define pgd_bad(pgd)		(0)
-#define pgd_clear(pgdp)
-#define kern_addr_valid(addr)	(1)
-#define	pmd_offset(a, b)	((void *)0)
-#define pmd_none(pmd)           (1)
-#define pgd_offset_k(adrdress)  ((pgd_t *)0)
-#define pte_offset_kernel(dir, address) ((pte_t *)0)
-
-#define PAGE_NONE		__pgprot(0)    /* these mean nothing to NO_MM */
-#define PAGE_SHARED		__pgprot(0)    /* these mean nothing to NO_MM */
-#define PAGE_COPY		__pgprot(0)    /* these mean nothing to NO_MM */
-#define PAGE_READONLY	__pgprot(0)    /* these mean nothing to NO_MM */
-#define PAGE_KERNEL		__pgprot(0)    /* these mean nothing to NO_MM */
-
-extern void paging_init(void);
-#define swapper_pg_dir ((pgd_t *) 0)
-
-#define __swp_type(x)		(0)
-#define __swp_offset(x)		(0)
-#define __swp_entry(typ,off)	((swp_entry_t) { ((typ) | ((off) << 7)) })
-#define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) })
-#define __swp_entry_to_pte(x)	((pte_t) { (x).val })
-
-static inline int pte_file(pte_t pte) { return 0; }
-
-/*
- * ZERO_PAGE is a global shared page that is always zero: used
- * for zero-mapped memory areas etc..
- */
-#define ZERO_PAGE(vaddr)	(virt_to_page(0))
-
-/*
- * These would be in other places but having them here reduces the diffs.
- */
-extern unsigned int kobjsize(const void *objp);
-extern int is_in_rom(unsigned long);
-
-/*
- * No page table caches to initialise
- */
-#define pgtable_cache_init()   do { } while (0)
-
-/*
- * All 32bit addresses are effectively valid for vmalloc...
- * Sort of meaningless for non-VM targets.
- */
-#define	VMALLOC_START	0
-#define	VMALLOC_END	0xffffffff
-
-/*
- * All 32bit addresses are effectively valid for vmalloc...
- * Sort of meaningless for non-VM targets.
- */
-#define	VMALLOC_START	0
-#define	VMALLOC_END	0xffffffff
-
-#define arch_enter_lazy_cpu_mode()    do {} while (0)
-
-#include <asm-generic/pgtable.h>
-
-#endif /* _H8300_PGTABLE_H */
diff --git a/arch/h8300/include/asm/processor.h b/arch/h8300/include/asm/processor.h
deleted file mode 100644
index 4b0ca49..0000000
--- a/arch/h8300/include/asm/processor.h
+++ /dev/null
@@ -1,139 +0,0 @@
-/*
- * include/asm-h8300/processor.h
- *
- * Copyright (C) 2002 Yoshinori Sato
- *
- * Based on: linux/asm-m68nommu/processor.h
- *
- * Copyright (C) 1995 Hamish Macdonald
- */
-
-#ifndef __ASM_H8300_PROCESSOR_H
-#define __ASM_H8300_PROCESSOR_H
-
-/*
- * Default implementation of macro that returns current
- * instruction pointer ("program counter").
- */
-#define current_text_addr() ({ __label__ _l; _l: &&_l;})
-
-#include <linux/compiler.h>
-#include <asm/segment.h>
-#include <asm/fpu.h>
-#include <asm/ptrace.h>
-#include <asm/current.h>
-
-static inline unsigned long rdusp(void) {
-	extern unsigned int	sw_usp;
-	return(sw_usp);
-}
-
-static inline void wrusp(unsigned long usp) {
-	extern unsigned int	sw_usp;
-	sw_usp = usp;
-}
-
-/*
- * User space process size: 3.75GB. This is hardcoded into a few places,
- * so don't change it unless you know what you are doing.
- */
-#define TASK_SIZE	(0xFFFFFFFFUL)
-
-#ifdef __KERNEL__
-#define STACK_TOP	TASK_SIZE
-#define STACK_TOP_MAX	STACK_TOP
-#endif
-
-/*
- * This decides where the kernel will search for a free chunk of vm
- * space during mmap's. We won't be using it
- */
-#define TASK_UNMAPPED_BASE	0
-
-struct thread_struct {
-	unsigned long  ksp;		/* kernel stack pointer */
-	unsigned long  usp;		/* user stack pointer */
-	unsigned long  ccr;		/* saved status register */
-	unsigned long  esp0;            /* points to SR of stack frame */
-	struct {
-		unsigned short *addr;
-		unsigned short inst;
-	} breakinfo;
-};
-
-#define INIT_THREAD  {						\
-	.ksp  = sizeof(init_stack) + (unsigned long)init_stack, \
-	.usp  = 0,						\
-	.ccr  = PS_S,						\
-	.esp0 = 0,						\
-	.breakinfo = {						\
-		.addr = (unsigned short *)-1,			\
-		.inst = 0					\
-	}							\
-}
-
-/*
- * Do necessary setup to start up a newly executed thread.
- *
- * pass the data segment into user programs if it exists,
- * it can't hurt anything as far as I can tell
- */
-#if defined(__H8300H__)
-#define start_thread(_regs, _pc, _usp)			        \
-do {							        \
-  	(_regs)->pc = (_pc);				        \
-	(_regs)->ccr = 0x00;	   /* clear all flags */        \
-	(_regs)->er5 = current->mm->start_data;	/* GOT base */  \
-	wrusp((unsigned long)(_usp) - sizeof(unsigned long)*3);	\
-} while(0)
-#endif
-#if defined(__H8300S__)
-#define start_thread(_regs, _pc, _usp)			        \
-do {							        \
-	(_regs)->pc = (_pc);				        \
-	(_regs)->ccr = 0x00;	   /* clear kernel flag */      \
-	(_regs)->exr = 0x78;       /* enable all interrupts */  \
-	(_regs)->er5 = current->mm->start_data;	/* GOT base */  \
-	/* 14 = space for retaddr(4), vector(4), er0(4) and ext(2) on stack */ \
-	wrusp(((unsigned long)(_usp)) - 14);                    \
-} while(0)
-#endif
-
-/* Forward declaration, a strange C thing */
-struct task_struct;
-
-/* Free all resources held by a thread. */
-static inline void release_thread(struct task_struct *dead_task)
-{
-}
-
-/*
- * Free current thread data structures etc..
- */
-static inline void exit_thread(void)
-{
-}
-
-/*
- * Return saved PC of a blocked thread.
- */
-unsigned long thread_saved_pc(struct task_struct *tsk);
-unsigned long get_wchan(struct task_struct *p);
-
-#define	KSTK_EIP(tsk)	\
-    ({			\
-	unsigned long eip = 0;	 \
-	if ((tsk)->thread.esp0 > PAGE_SIZE && \
-	    MAP_NR((tsk)->thread.esp0) < max_mapnr) \
-	      eip = ((struct pt_regs *) (tsk)->thread.esp0)->pc; \
-	eip; })
-#define	KSTK_ESP(tsk)	((tsk) == current ? rdusp() : (tsk)->thread.usp)
-
-#define cpu_relax()    barrier()
-
-#define HARD_RESET_NOW() ({		\
-        local_irq_disable();		\
-        asm("jmp @@0");			\
-})
-
-#endif
diff --git a/arch/h8300/include/asm/ptrace.h b/arch/h8300/include/asm/ptrace.h
deleted file mode 100644
index c1826b9..0000000
--- a/arch/h8300/include/asm/ptrace.h
+++ /dev/null
@@ -1,33 +0,0 @@
-#ifndef _H8300_PTRACE_H
-#define _H8300_PTRACE_H
-
-#include <uapi/asm/ptrace.h>
-
-#ifndef __ASSEMBLY__
-#if defined(CONFIG_CPU_H8S)
-#endif
-#ifndef PS_S
-#define PS_S  (0x10)
-#endif
-
-#if defined(__H8300H__)
-#define H8300_REGS_NO 11
-#endif
-#if defined(__H8300S__)
-#define H8300_REGS_NO 12
-#endif
-
-/* Find the stack offset for a register, relative to thread.esp0. */
-#define PT_REG(reg)	((long)&((struct pt_regs *)0)->reg)
-
-#define arch_has_single_step()	(1)
-
-#define user_mode(regs) (!((regs)->ccr & PS_S))
-#define instruction_pointer(regs) ((regs)->pc)
-#define profile_pc(regs) instruction_pointer(regs)
-#define current_pt_regs() ((struct pt_regs *) \
-	(THREAD_SIZE + (unsigned long)current_thread_info()) - 1)
-#define signal_pt_regs() ((struct pt_regs *)current->thread.esp0)
-#define current_user_stack_pointer() rdusp()
-#endif /* __ASSEMBLY__ */
-#endif /* _H8300_PTRACE_H */
diff --git a/arch/h8300/include/asm/regs267x.h b/arch/h8300/include/asm/regs267x.h
deleted file mode 100644
index 1bff731..0000000
--- a/arch/h8300/include/asm/regs267x.h
+++ /dev/null
@@ -1,336 +0,0 @@
-/* internal Peripherals Register address define */
-/* CPU: H8/306x                                 */
-
-#if !defined(__REGS_H8S267x__)
-#define __REGS_H8S267x__ 
-
-#if defined(__KERNEL__)
-
-#define DASTCR 0xFEE01A
-#define DADR0  0xFFFFA4
-#define DADR1  0xFFFFA5
-#define DACR01 0xFFFFA6
-#define DADR2  0xFFFFA8
-#define DADR3  0xFFFFA9
-#define DACR23 0xFFFFAA
-
-#define ADDRA  0xFFFF90
-#define ADDRAH 0xFFFF90
-#define ADDRAL 0xFFFF91
-#define ADDRB  0xFFFF92
-#define ADDRBH 0xFFFF92
-#define ADDRBL 0xFFFF93
-#define ADDRC  0xFFFF94
-#define ADDRCH 0xFFFF94
-#define ADDRCL 0xFFFF95
-#define ADDRD  0xFFFF96
-#define ADDRDH 0xFFFF96
-#define ADDRDL 0xFFFF97
-#define ADDRE  0xFFFF98
-#define ADDREH 0xFFFF98
-#define ADDREL 0xFFFF99
-#define ADDRF  0xFFFF9A
-#define ADDRFH 0xFFFF9A
-#define ADDRFL 0xFFFF9B
-#define ADDRG  0xFFFF9C
-#define ADDRGH 0xFFFF9C
-#define ADDRGL 0xFFFF9D
-#define ADDRH  0xFFFF9E
-#define ADDRHH 0xFFFF9E
-#define ADDRHL 0xFFFF9F
-
-#define ADCSR  0xFFFFA0
-#define ADCR   0xFFFFA1
-
-#define ABWCR  0xFFFEC0
-#define ASTCR  0xFFFEC1
-#define WTCRAH 0xFFFEC2
-#define WTCRAL 0xFFFEC3
-#define WTCRBH 0xFFFEC4
-#define WTCRBL 0xFFFEC5
-#define RDNCR  0xFFFEC6
-#define CSACRH 0xFFFEC8
-#define CSACRL 0xFFFEC9
-#define BROMCRH 0xFFFECA
-#define BROMCRL 0xFFFECB
-#define BCR    0xFFFECC
-#define DRAMCR 0xFFFED0
-#define DRACCR 0xFFFED2
-#define REFCR  0xFFFED4
-#define RTCNT  0xFFFED6
-#define RTCOR  0xFFFED7
-
-#define MAR0AH  0xFFFEE0
-#define MAR0AL  0xFFFEE2
-#define IOAR0A  0xFFFEE4
-#define ETCR0A  0xFFFEE6
-#define MAR0BH  0xFFFEE8
-#define MAR0BL  0xFFFEEA
-#define IOAR0B  0xFFFEEC
-#define ETCR0B  0xFFFEEE
-#define MAR1AH  0xFFFEF0
-#define MAR1AL  0xFFFEF2
-#define IOAR1A  0xFFFEF4
-#define ETCR1A  0xFFFEF6
-#define MAR1BH  0xFFFEF8
-#define MAR1BL  0xFFFEFA
-#define IOAR1B  0xFFFEFC
-#define ETCR1B  0xFFFEFE
-#define DMAWER  0xFFFF20
-#define DMATCR  0xFFFF21
-#define DMACR0A 0xFFFF22
-#define DMACR0B 0xFFFF23
-#define DMACR1A 0xFFFF24
-#define DMACR1B 0xFFFF25
-#define DMABCRH 0xFFFF26
-#define DMABCRL 0xFFFF27
-
-#define EDSAR0  0xFFFDC0
-#define EDDAR0  0xFFFDC4
-#define EDTCR0  0xFFFDC8
-#define EDMDR0  0xFFFDCC
-#define EDMDR0H 0xFFFDCC
-#define EDMDR0L 0xFFFDCD
-#define EDACR0  0xFFFDCE
-#define EDSAR1  0xFFFDD0
-#define EDDAR1  0xFFFDD4
-#define EDTCR1  0xFFFDD8
-#define EDMDR1  0xFFFDDC
-#define EDMDR1H 0xFFFDDC
-#define EDMDR1L 0xFFFDDD
-#define EDACR1  0xFFFDDE
-#define EDSAR2  0xFFFDE0
-#define EDDAR2  0xFFFDE4
-#define EDTCR2  0xFFFDE8
-#define EDMDR2  0xFFFDEC
-#define EDMDR2H 0xFFFDEC
-#define EDMDR2L 0xFFFDED
-#define EDACR2  0xFFFDEE
-#define EDSAR3  0xFFFDF0
-#define EDDAR3  0xFFFDF4
-#define EDTCR3  0xFFFDF8
-#define EDMDR3  0xFFFDFC
-#define EDMDR3H 0xFFFDFC
-#define EDMDR3L 0xFFFDFD
-#define EDACR3  0xFFFDFE
-
-#define IPRA  0xFFFE00
-#define IPRB  0xFFFE02
-#define IPRC  0xFFFE04
-#define IPRD  0xFFFE06
-#define IPRE  0xFFFE08
-#define IPRF  0xFFFE0A
-#define IPRG  0xFFFE0C
-#define IPRH  0xFFFE0E
-#define IPRI  0xFFFE10
-#define IPRJ  0xFFFE12
-#define IPRK  0xFFFE14
-#define ITSR  0xFFFE16
-#define SSIER 0xFFFE18
-#define ISCRH 0xFFFE1A
-#define ISCRL 0xFFFE1C
-
-#define INTCR 0xFFFF31
-#define IER   0xFFFF32
-#define IERH  0xFFFF32
-#define IERL  0xFFFF33
-#define ISR   0xFFFF34
-#define ISRH  0xFFFF34
-#define ISRL  0xFFFF35
-
-#define P1DDR 0xFFFE20
-#define P2DDR 0xFFFE21
-#define P3DDR 0xFFFE22
-#define P4DDR 0xFFFE23
-#define P5DDR 0xFFFE24
-#define P6DDR 0xFFFE25
-#define P7DDR 0xFFFE26
-#define P8DDR 0xFFFE27
-#define P9DDR 0xFFFE28
-#define PADDR 0xFFFE29
-#define PBDDR 0xFFFE2A
-#define PCDDR 0xFFFE2B
-#define PDDDR 0xFFFE2C
-#define PEDDR 0xFFFE2D
-#define PFDDR 0xFFFE2E
-#define PGDDR 0xFFFE2F
-#define PHDDR 0xFFFF74
-
-#define PFCR0 0xFFFE32
-#define PFCR1 0xFFFE33
-#define PFCR2 0xFFFE34
-
-#define PAPCR 0xFFFE36
-#define PBPCR 0xFFFE37
-#define PCPCR 0xFFFE38
-#define PDPCR 0xFFFE39
-#define PEPCR 0xFFFE3A
-
-#define P3ODR 0xFFFE3C
-#define PAODR 0xFFFE3D
-
-#define P1DR  0xFFFF60
-#define P2DR  0xFFFF61
-#define P3DR  0xFFFF62
-#define P4DR  0xFFFF63
-#define P5DR  0xFFFF64
-#define P6DR  0xFFFF65
-#define P7DR  0xFFFF66
-#define P8DR  0xFFFF67
-#define P9DR  0xFFFF68
-#define PADR  0xFFFF69
-#define PBDR  0xFFFF6A
-#define PCDR  0xFFFF6B
-#define PDDR  0xFFFF6C
-#define PEDR  0xFFFF6D
-#define PFDR  0xFFFF6E
-#define PGDR  0xFFFF6F
-#define PHDR  0xFFFF72
-
-#define PORT1 0xFFFF50
-#define PORT2 0xFFFF51
-#define PORT3 0xFFFF52
-#define PORT4 0xFFFF53
-#define PORT5 0xFFFF54
-#define PORT6 0xFFFF55
-#define PORT7 0xFFFF56
-#define PORT8 0xFFFF57
-#define PORT9 0xFFFF58
-#define PORTA 0xFFFF59
-#define PORTB 0xFFFF5A
-#define PORTC 0xFFFF5B
-#define PORTD 0xFFFF5C
-#define PORTE 0xFFFF5D
-#define PORTF 0xFFFF5E
-#define PORTG 0xFFFF5F
-#define PORTH 0xFFFF70
-
-#define PCR   0xFFFF46
-#define PMR   0xFFFF47
-#define NDERH 0xFFFF48
-#define NDERL 0xFFFF49
-#define PODRH 0xFFFF4A
-#define PODRL 0xFFFF4B
-#define NDRH1 0xFFFF4C
-#define NDRL1 0xFFFF4D
-#define NDRH2 0xFFFF4E
-#define NDRL2 0xFFFF4F
-
-#define SMR0  0xFFFF78
-#define BRR0  0xFFFF79
-#define SCR0  0xFFFF7A
-#define TDR0  0xFFFF7B
-#define SSR0  0xFFFF7C
-#define RDR0  0xFFFF7D
-#define SCMR0 0xFFFF7E
-#define SMR1  0xFFFF80
-#define BRR1  0xFFFF81
-#define SCR1  0xFFFF82
-#define TDR1  0xFFFF83
-#define SSR1  0xFFFF84
-#define RDR1  0xFFFF85
-#define SCMR1 0xFFFF86
-#define SMR2  0xFFFF88
-#define BRR2  0xFFFF89
-#define SCR2  0xFFFF8A
-#define TDR2  0xFFFF8B
-#define SSR2  0xFFFF8C
-#define RDR2  0xFFFF8D
-#define SCMR2 0xFFFF8E
-
-#define IRCR0 0xFFFE1E
-#define SEMR  0xFFFDA8
-
-#define MDCR    0xFFFF3E
-#define SYSCR   0xFFFF3D
-#define MSTPCRH 0xFFFF40
-#define MSTPCRL 0xFFFF41
-#define FLMCR1  0xFFFFC8
-#define FLMCR2  0xFFFFC9
-#define EBR1    0xFFFFCA
-#define EBR2    0xFFFFCB
-#define CTGARC_RAMCR   0xFFFECE
-#define SBYCR   0xFFFF3A
-#define SCKCR   0xFFFF3B
-#define PLLCR   0xFFFF45
-
-#define TSTR   0xFFFFC0
-#define TSNC   0XFFFFC1
-
-#define TCR0   0xFFFFD0
-#define TMDR0  0xFFFFD1
-#define TIORH0 0xFFFFD2
-#define TIORL0 0xFFFFD3
-#define TIER0  0xFFFFD4
-#define TSR0   0xFFFFD5
-#define TCNT0  0xFFFFD6
-#define GRA0   0xFFFFD8
-#define GRB0   0xFFFFDA
-#define GRC0   0xFFFFDC
-#define GRD0   0xFFFFDE
-#define TCR1   0xFFFFE0
-#define TMDR1  0xFFFFE1
-#define TIORH1 0xFFFFE2
-#define TIORL1 0xFFFFE3
-#define TIER1  0xFFFFE4
-#define TSR1   0xFFFFE5
-#define TCNT1  0xFFFFE6
-#define GRA1   0xFFFFE8
-#define GRB1   0xFFFFEA
-#define TCR2   0xFFFFF0
-#define TMDR2  0xFFFFF1
-#define TIORH2 0xFFFFF2
-#define TIORL2 0xFFFFF3
-#define TIER2  0xFFFFF4
-#define TSR2   0xFFFFF5
-#define TCNT2  0xFFFFF6
-#define GRA2   0xFFFFF8
-#define GRB2   0xFFFFFA
-#define TCR3   0xFFFE80
-#define TMDR3  0xFFFE81
-#define TIORH3 0xFFFE82
-#define TIORL3 0xFFFE83
-#define TIER3  0xFFFE84
-#define TSR3   0xFFFE85
-#define TCNT3  0xFFFE86
-#define GRA3   0xFFFE88
-#define GRB3   0xFFFE8A
-#define GRC3   0xFFFE8C
-#define GRD3   0xFFFE8E
-#define TCR4   0xFFFE90
-#define TMDR4  0xFFFE91
-#define TIORH4 0xFFFE92
-#define TIORL4 0xFFFE93
-#define TIER4  0xFFFE94
-#define TSR4   0xFFFE95
-#define TCNT4  0xFFFE96
-#define GRA4   0xFFFE98
-#define GRB4   0xFFFE9A
-#define TCR5   0xFFFEA0
-#define TMDR5  0xFFFEA1
-#define TIORH5 0xFFFEA2
-#define TIORL5 0xFFFEA3
-#define TIER5  0xFFFEA4
-#define TSR5   0xFFFEA5
-#define TCNT5  0xFFFEA6
-#define GRA5   0xFFFEA8
-#define GRB5   0xFFFEAA
-
-#define _8TCR0   0xFFFFB0
-#define _8TCR1   0xFFFFB1
-#define _8TCSR0  0xFFFFB2
-#define _8TCSR1  0xFFFFB3
-#define _8TCORA0 0xFFFFB4
-#define _8TCORA1 0xFFFFB5
-#define _8TCORB0 0xFFFFB6
-#define _8TCORB1 0xFFFFB7
-#define _8TCNT0  0xFFFFB8
-#define _8TCNT1  0xFFFFB9
-
-#define TCSR    0xFFFFBC
-#define TCNT    0xFFFFBD
-#define RSTCSRW 0xFFFFBE
-#define RSTCSRR 0xFFFFBF
-
-#endif /* __KERNEL__ */
-#endif /* __REGS_H8S267x__ */
diff --git a/arch/h8300/include/asm/regs306x.h b/arch/h8300/include/asm/regs306x.h
deleted file mode 100644
index 027dd63..0000000
--- a/arch/h8300/include/asm/regs306x.h
+++ /dev/null
@@ -1,212 +0,0 @@
-/* internal Peripherals Register address define */
-/* CPU: H8/306x                                 */
-
-#if !defined(__REGS_H8306x__)
-#define __REGS_H8306x__ 
-
-#if defined(__KERNEL__)
-
-#define DASTCR 0xFEE01A
-#define DADR0  0xFEE09C
-#define DADR1  0xFEE09D
-#define DACR   0xFEE09E
-
-#define ADDRAH 0xFFFFE0
-#define ADDRAL 0xFFFFE1
-#define ADDRBH 0xFFFFE2
-#define ADDRBL 0xFFFFE3
-#define ADDRCH 0xFFFFE4
-#define ADDRCL 0xFFFFE5
-#define ADDRDH 0xFFFFE6
-#define ADDRDL 0xFFFFE7
-#define ADCSR  0xFFFFE8
-#define ADCR   0xFFFFE9
-
-#define BRCR   0xFEE013
-#define ADRCR  0xFEE01E
-#define CSCR   0xFEE01F
-#define ABWCR  0xFEE020
-#define ASTCR  0xFEE021
-#define WCRH   0xFEE022
-#define WCRL   0xFEE023
-#define BCR    0xFEE024
-#define DRCRA  0xFEE026
-#define DRCRB  0xFEE027
-#define RTMCSR 0xFEE028
-#define RTCNT  0xFEE029
-#define RTCOR  0xFEE02A
-
-#define MAR0AR  0xFFFF20
-#define MAR0AE  0xFFFF21
-#define MAR0AH  0xFFFF22
-#define MAR0AL  0xFFFF23
-#define ETCR0AL 0xFFFF24
-#define ETCR0AH 0xFFFF25
-#define IOAR0A  0xFFFF26
-#define DTCR0A  0xFFFF27
-#define MAR0BR  0xFFFF28
-#define MAR0BE  0xFFFF29
-#define MAR0BH  0xFFFF2A
-#define MAR0BL  0xFFFF2B
-#define ETCR0BL 0xFFFF2C
-#define ETCR0BH 0xFFFF2D
-#define IOAR0B  0xFFFF2E
-#define DTCR0B  0xFFFF2F
-#define MAR1AR  0xFFFF30
-#define MAR1AE  0xFFFF31
-#define MAR1AH  0xFFFF32
-#define MAR1AL  0xFFFF33
-#define ETCR1AL 0xFFFF34
-#define ETCR1AH 0xFFFF35
-#define IOAR1A  0xFFFF36
-#define DTCR1A  0xFFFF37
-#define MAR1BR  0xFFFF38
-#define MAR1BE  0xFFFF39
-#define MAR1BH  0xFFFF3A
-#define MAR1BL  0xFFFF3B
-#define ETCR1BL 0xFFFF3C
-#define ETCR1BH 0xFFFF3D
-#define IOAR1B  0xFFFF3E
-#define DTCR1B  0xFFFF3F
-
-#define ISCR 0xFEE014
-#define IER  0xFEE015
-#define ISR  0xFEE016
-#define IPRA 0xFEE018
-#define IPRB 0xFEE019
-
-#define P1DDR 0xFEE000
-#define P2DDR 0xFEE001
-#define P3DDR 0xFEE002
-#define P4DDR 0xFEE003
-#define P5DDR 0xFEE004
-#define P6DDR 0xFEE005
-/*#define P7DDR 0xFEE006*/
-#define P8DDR 0xFEE007
-#define P9DDR 0xFEE008
-#define PADDR 0xFEE009
-#define PBDDR 0xFEE00A
-
-#define P1DR  0xFFFFD0
-#define P2DR  0xFFFFD1
-#define P3DR  0xFFFFD2
-#define P4DR  0xFFFFD3
-#define P5DR  0xFFFFD4
-#define P6DR  0xFFFFD5
-/*#define P7DR  0xFFFFD6*/
-#define P8DR  0xFFFFD7
-#define P9DR  0xFFFFD8
-#define PADR  0xFFFFD9
-#define PBDR  0xFFFFDA
-
-#define P2CR  0xFEE03C
-#define P4CR  0xFEE03E
-#define P5CR  0xFEE03F
-
-#define SMR0  0xFFFFB0
-#define BRR0  0xFFFFB1
-#define SCR0  0xFFFFB2
-#define TDR0  0xFFFFB3
-#define SSR0  0xFFFFB4
-#define RDR0  0xFFFFB5
-#define SCMR0 0xFFFFB6
-#define SMR1  0xFFFFB8
-#define BRR1  0xFFFFB9
-#define SCR1  0xFFFFBA
-#define TDR1  0xFFFFBB
-#define SSR1  0xFFFFBC
-#define RDR1  0xFFFFBD
-#define SCMR1 0xFFFFBE
-#define SMR2  0xFFFFC0
-#define BRR2  0xFFFFC1
-#define SCR2  0xFFFFC2
-#define TDR2  0xFFFFC3
-#define SSR2  0xFFFFC4
-#define RDR2  0xFFFFC5
-#define SCMR2 0xFFFFC6
-
-#define MDCR   0xFEE011
-#define SYSCR  0xFEE012
-#define DIVCR  0xFEE01B
-#define MSTCRH 0xFEE01C
-#define MSTCRL 0xFEE01D
-#define FLMCR1 0xFEE030
-#define FLMCR2 0xFEE031
-#define EBR1   0xFEE032
-#define EBR2   0xFEE033
-#define RAMCR  0xFEE077
-
-#define TSTR   0xFFFF60
-#define TSNC   0XFFFF61
-#define TMDR   0xFFFF62
-#define TOLR   0xFFFF63
-#define TISRA  0xFFFF64
-#define TISRB  0xFFFF65
-#define TISRC  0xFFFF66
-#define TCR0   0xFFFF68
-#define TIOR0  0xFFFF69
-#define TCNT0H 0xFFFF6A
-#define TCNT0L 0xFFFF6B
-#define GRA0H  0xFFFF6C
-#define GRA0L  0xFFFF6D
-#define GRB0H  0xFFFF6E
-#define GRB0L  0xFFFF6F
-#define TCR1   0xFFFF70
-#define TIOR1  0xFFFF71
-#define TCNT1H 0xFFFF72
-#define TCNT1L 0xFFFF73
-#define GRA1H  0xFFFF74
-#define GRA1L  0xFFFF75
-#define GRB1H  0xFFFF76
-#define GRB1L  0xFFFF77
-#define TCR3   0xFFFF78
-#define TIOR3  0xFFFF79
-#define TCNT3H 0xFFFF7A
-#define TCNT3L 0xFFFF7B
-#define GRA3H  0xFFFF7C
-#define GRA3L  0xFFFF7D
-#define GRB3H  0xFFFF7E
-#define GRB3L  0xFFFF7F
-
-#define _8TCR0  0xFFFF80
-#define _8TCR1  0xFFFF81
-#define _8TCSR0 0xFFFF82
-#define _8TCSR1 0xFFFF83
-#define TCORA0 0xFFFF84
-#define TCORA1 0xFFFF85
-#define TCORB0 0xFFFF86
-#define TCORB1 0xFFFF87
-#define _8TCNT0 0xFFFF88
-#define _8TCNT1 0xFFFF89
-
-#define _8TCR2  0xFFFF90
-#define _8TCR3  0xFFFF91
-#define _8TCSR2 0xFFFF92
-#define _8TCSR3 0xFFFF93
-#define TCORA2 0xFFFF94
-#define TCORA3 0xFFFF95
-#define TCORB2 0xFFFF96
-#define TCORB3 0xFFFF97
-#define _8TCNT2 0xFFFF98
-#define _8TCNT3 0xFFFF99
-
-#define TCSR   0xFFFF8C
-#define TCNT   0xFFFF8D
-#define RSTCSR 0xFFFF8F
-
-#define TPMR  0xFFFFA0
-#define TPCR  0xFFFFA1
-#define NDERB 0xFFFFA2
-#define NDERA 0xFFFFA3
-#define NDRB1 0xFFFFA4
-#define NDRA1 0xFFFFA5
-#define NDRB2 0xFFFFA6
-#define NDRA2 0xFFFFA7
-
-#define TCSR    0xFFFF8C
-#define TCNT    0xFFFF8D
-#define RSTCSRW 0xFFFF8E
-#define RSTCSRR 0xFFFF8F
-
-#endif /* __KERNEL__ */
-#endif /* __REGS_H8306x__ */
diff --git a/arch/h8300/include/asm/scatterlist.h b/arch/h8300/include/asm/scatterlist.h
deleted file mode 100644
index 82130ed..0000000
--- a/arch/h8300/include/asm/scatterlist.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _H8300_SCATTERLIST_H
-#define _H8300_SCATTERLIST_H
-
-#include <asm-generic/scatterlist.h>
-
-#endif /* !(_H8300_SCATTERLIST_H) */
diff --git a/arch/h8300/include/asm/sections.h b/arch/h8300/include/asm/sections.h
deleted file mode 100644
index a81743e..0000000
--- a/arch/h8300/include/asm/sections.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _H8300_SECTIONS_H_
-#define _H8300_SECTIONS_H_
-
-#include <asm-generic/sections.h>
-
-#endif
diff --git a/arch/h8300/include/asm/segment.h b/arch/h8300/include/asm/segment.h
deleted file mode 100644
index b79a82d..0000000
--- a/arch/h8300/include/asm/segment.h
+++ /dev/null
@@ -1,49 +0,0 @@
-#ifndef _H8300_SEGMENT_H
-#define _H8300_SEGMENT_H
-
-/* define constants */
-#define USER_DATA     (1)
-#ifndef __USER_DS
-#define __USER_DS     (USER_DATA)
-#endif
-#define USER_PROGRAM  (2)
-#define SUPER_DATA    (3)
-#ifndef __KERNEL_DS
-#define __KERNEL_DS   (SUPER_DATA)
-#endif
-#define SUPER_PROGRAM (4)
-
-#ifndef __ASSEMBLY__
-
-typedef struct {
-	unsigned long seg;
-} mm_segment_t;
-
-#define MAKE_MM_SEG(s)	((mm_segment_t) { (s) })
-#define USER_DS		MAKE_MM_SEG(__USER_DS)
-#define KERNEL_DS	MAKE_MM_SEG(__KERNEL_DS)
-
-/*
- * Get/set the SFC/DFC registers for MOVES instructions
- */
-
-static inline mm_segment_t get_fs(void)
-{
-    return USER_DS;
-}
-
-static inline mm_segment_t get_ds(void)
-{
-    /* return the supervisor data space code */
-    return KERNEL_DS;
-}
-
-static inline void set_fs(mm_segment_t val)
-{
-}
-
-#define segment_eq(a,b)	((a).seg == (b).seg)
-
-#endif /* __ASSEMBLY__ */
-
-#endif /* _H8300_SEGMENT_H */
diff --git a/arch/h8300/include/asm/sh_bios.h b/arch/h8300/include/asm/sh_bios.h
deleted file mode 100644
index b6bb6e5..0000000
--- a/arch/h8300/include/asm/sh_bios.h
+++ /dev/null
@@ -1,29 +0,0 @@
-/* eCos HAL interface header */
-
-#ifndef SH_BIOS_H
-#define SH_BIOS_H
-
-#define HAL_IF_VECTOR_TABLE 0xfffe20
-#define CALL_IF_SET_CONSOLE_COMM  13
-#define QUERY_CURRENT -1
-#define MANGLER       -3
-
-/* Checking for GDB stub active */
-/* suggestion Jonathan Larmour */
-static int sh_bios_in_gdb_mode(void)
-{
-	static int gdb_active = -1;
-	if (gdb_active == -1) {
-		int (*set_console_comm)(int);
-		set_console_comm = ((void **)HAL_IF_VECTOR_TABLE)[CALL_IF_SET_CONSOLE_COMM];
-		gdb_active = (set_console_comm(QUERY_CURRENT) == MANGLER);
-	}
-	return gdb_active;
-}
-
-static void sh_bios_gdb_detach(void)
-{
-
-}
-
-#endif
diff --git a/arch/h8300/include/asm/shm.h b/arch/h8300/include/asm/shm.h
deleted file mode 100644
index ed6623c..0000000
--- a/arch/h8300/include/asm/shm.h
+++ /dev/null
@@ -1,31 +0,0 @@
-#ifndef _H8300_SHM_H
-#define _H8300_SHM_H
-
-
-/* format of page table entries that correspond to shared memory pages
-   currently out in swap space (see also mm/swap.c):
-   bits 0-1 (PAGE_PRESENT) is  = 0
-   bits 8..2 (SWP_TYPE) are = SHM_SWP_TYPE
-   bits 31..9 are used like this:
-   bits 15..9 (SHM_ID) the id of the shared memory segment
-   bits 30..16 (SHM_IDX) the index of the page within the shared memory segment
-                    (actually only bits 25..16 get used since SHMMAX is so low)
-   bit 31 (SHM_READ_ONLY) flag whether the page belongs to a read-only attach
-*/
-/* on the m68k both bits 0 and 1 must be zero */
-/* format on the sun3 is similar, but bits 30, 31 are set to zero and all
-   others are reduced by 2. --m */
-
-#ifndef CONFIG_SUN3
-#define SHM_ID_SHIFT	9
-#else
-#define SHM_ID_SHIFT	7
-#endif
-#define _SHM_ID_BITS	7
-#define SHM_ID_MASK	((1<<_SHM_ID_BITS)-1)
-
-#define SHM_IDX_SHIFT	(SHM_ID_SHIFT+_SHM_ID_BITS)
-#define _SHM_IDX_BITS	15
-#define SHM_IDX_MASK	((1<<_SHM_IDX_BITS)-1)
-
-#endif /* _H8300_SHM_H */
diff --git a/arch/h8300/include/asm/shmparam.h b/arch/h8300/include/asm/shmparam.h
deleted file mode 100644
index d186395..0000000
--- a/arch/h8300/include/asm/shmparam.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _H8300_SHMPARAM_H
-#define _H8300_SHMPARAM_H
-
-#define	SHMLBA PAGE_SIZE		 /* attach addr a multiple of this */
-
-#endif /* _H8300_SHMPARAM_H */
diff --git a/arch/h8300/include/asm/signal.h b/arch/h8300/include/asm/signal.h
deleted file mode 100644
index 6341e36..0000000
--- a/arch/h8300/include/asm/signal.h
+++ /dev/null
@@ -1,24 +0,0 @@
-#ifndef _H8300_SIGNAL_H
-#define _H8300_SIGNAL_H
-
-#include <uapi/asm/signal.h>
-
-/* Most things should be clean enough to redefine this at will, if care
-   is taken to make libc match.  */
-
-#define _NSIG		64
-#define _NSIG_BPW	32
-#define _NSIG_WORDS	(_NSIG / _NSIG_BPW)
-
-typedef unsigned long old_sigset_t;		/* at least 32 bits */
-
-typedef struct {
-	unsigned long sig[_NSIG_WORDS];
-} sigset_t;
-
-#define __ARCH_HAS_SA_RESTORER
-
-#include <asm/sigcontext.h>
-#undef __HAVE_ARCH_SIG_BITOPS
-
-#endif /* _H8300_SIGNAL_H */
diff --git a/arch/h8300/include/asm/smp.h b/arch/h8300/include/asm/smp.h
deleted file mode 100644
index 9e9bd7e..0000000
--- a/arch/h8300/include/asm/smp.h
+++ /dev/null
@@ -1 +0,0 @@
-/* nothing required here yet */
diff --git a/arch/h8300/include/asm/spinlock.h b/arch/h8300/include/asm/spinlock.h
deleted file mode 100644
index d5407fa..0000000
--- a/arch/h8300/include/asm/spinlock.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef __H8300_SPINLOCK_H
-#define __H8300_SPINLOCK_H
-
-#error "H8/300 doesn't do SMP yet"
-
-#endif
diff --git a/arch/h8300/include/asm/string.h b/arch/h8300/include/asm/string.h
deleted file mode 100644
index ca50348..0000000
--- a/arch/h8300/include/asm/string.h
+++ /dev/null
@@ -1,44 +0,0 @@
-#ifndef _H8300_STRING_H_
-#define _H8300_STRING_H_
-
-#ifdef __KERNEL__ /* only set these up for kernel code */
-
-#include <asm/setup.h>
-#include <asm/page.h>
-
-#define __HAVE_ARCH_MEMSET
-extern void * memset(void * s, int c, size_t count);
-
-#define __HAVE_ARCH_MEMCPY
-extern void * memcpy(void *d, const void *s, size_t count);
-
-#else /* KERNEL */
-
-/*
- *	let user libraries deal with these,
- *	IMHO the kernel has no place defining these functions for user apps
- */
-
-#define __HAVE_ARCH_STRCPY 1
-#define __HAVE_ARCH_STRNCPY 1
-#define __HAVE_ARCH_STRCAT 1
-#define __HAVE_ARCH_STRNCAT 1
-#define __HAVE_ARCH_STRCMP 1
-#define __HAVE_ARCH_STRNCMP 1
-#define __HAVE_ARCH_STRNICMP 1
-#define __HAVE_ARCH_STRCHR 1
-#define __HAVE_ARCH_STRRCHR 1
-#define __HAVE_ARCH_STRSTR 1
-#define __HAVE_ARCH_STRLEN 1
-#define __HAVE_ARCH_STRNLEN 1
-#define __HAVE_ARCH_MEMSET 1
-#define __HAVE_ARCH_MEMCPY 1
-#define __HAVE_ARCH_MEMMOVE 1
-#define __HAVE_ARCH_MEMSCAN 1
-#define __HAVE_ARCH_MEMCMP 1
-#define __HAVE_ARCH_MEMCHR 1
-#define __HAVE_ARCH_STRTOK 1
-
-#endif /* KERNEL */
-
-#endif /* _M68K_STRING_H_ */
diff --git a/arch/h8300/include/asm/switch_to.h b/arch/h8300/include/asm/switch_to.h
deleted file mode 100644
index cdd8731..0000000
--- a/arch/h8300/include/asm/switch_to.h
+++ /dev/null
@@ -1,50 +0,0 @@
-#ifndef _H8300_SWITCH_TO_H
-#define _H8300_SWITCH_TO_H
-
-/*
- * switch_to(n) should switch tasks to task ptr, first checking that
- * ptr isn't the current task, in which case it does nothing.  This
- * also clears the TS-flag if the task we switched to has used the
- * math co-processor latest.
- */
-/*
- * switch_to() saves the extra registers, that are not saved
- * automatically by SAVE_SWITCH_STACK in resume(), ie. d0-d5 and
- * a0-a1. Some of these are used by schedule() and its predecessors
- * and so we might get see unexpected behaviors when a task returns
- * with unexpected register values.
- *
- * syscall stores these registers itself and none of them are used
- * by syscall after the function in the syscall has been called.
- *
- * Beware that resume now expects *next to be in d1 and the offset of
- * tss to be in a1. This saves a few instructions as we no longer have
- * to push them onto the stack and read them back right after.
- *
- * 02/17/96 - Jes Sorensen (jds@kom.auc.dk)
- *
- * Changed 96/09/19 by Andreas Schwab
- * pass prev in a0, next in a1, offset of tss in d1, and whether
- * the mm structures are shared in d2 (to avoid atc flushing).
- *
- * H8/300 Porting 2002/09/04 Yoshinori Sato
- */
-
-asmlinkage void resume(void);
-#define switch_to(prev,next,last) {                         \
-  void *_last;						    \
-  __asm__ __volatile__(					    \
-  			"mov.l	%1, er0\n\t"		    \
-			"mov.l	%2, er1\n\t"		    \
-                        "mov.l  %3, er2\n\t"                \
-			"jsr @_resume\n\t"                  \
-                        "mov.l  er2,%0\n\t"                 \
-		       : "=r" (_last)			    \
-		       : "r" (&(prev->thread)),		    \
-			 "r" (&(next->thread)),		    \
-                         "g" (prev)                         \
-		       : "cc", "er0", "er1", "er2", "er3"); \
-  (last) = _last; 					    \
-}
-
-#endif /* _H8300_SWITCH_TO_H */
diff --git a/arch/h8300/include/asm/target_time.h b/arch/h8300/include/asm/target_time.h
deleted file mode 100644
index 9f2a9aa..0000000
--- a/arch/h8300/include/asm/target_time.h
+++ /dev/null
@@ -1,4 +0,0 @@
-extern int platform_timer_setup(void (*timer_int)(int, void *, struct pt_regs *));
-extern void platform_timer_eoi(void);
-extern void platform_gettod(unsigned int *year, unsigned int *mon, unsigned int *day, 
-                            unsigned int *hour, unsigned int *min, unsigned int *sec);
diff --git a/arch/h8300/include/asm/termios.h b/arch/h8300/include/asm/termios.h
deleted file mode 100644
index 93a63df..0000000
--- a/arch/h8300/include/asm/termios.h
+++ /dev/null
@@ -1,50 +0,0 @@
-#ifndef _H8300_TERMIOS_H
-#define _H8300_TERMIOS_H
-
-#include <uapi/asm/termios.h>
-
-/*	intr=^C		quit=^|		erase=del	kill=^U
-	eof=^D		vtime=\0	vmin=\1		sxtc=\0
-	start=^Q	stop=^S		susp=^Z		eol=\0
-	reprint=^R	discard=^U	werase=^W	lnext=^V
-	eol2=\0
-*/
-#define INIT_C_CC "\003\034\177\025\004\0\1\0\021\023\032\0\022\017\027\026\0"
-
-/*
- * Translate a "termio" structure into a "termios". Ugh.
- */
-#define user_termio_to_kernel_termios(termios, termio) \
-({ \
-	unsigned short tmp; \
-	get_user(tmp, &(termio)->c_iflag); \
-	(termios)->c_iflag = (0xffff0000 & ((termios)->c_iflag)) | tmp; \
-	get_user(tmp, &(termio)->c_oflag); \
-	(termios)->c_oflag = (0xffff0000 & ((termios)->c_oflag)) | tmp; \
-	get_user(tmp, &(termio)->c_cflag); \
-	(termios)->c_cflag = (0xffff0000 & ((termios)->c_cflag)) | tmp; \
-	get_user(tmp, &(termio)->c_lflag); \
-	(termios)->c_lflag = (0xffff0000 & ((termios)->c_lflag)) | tmp; \
-	get_user((termios)->c_line, &(termio)->c_line); \
-	copy_from_user((termios)->c_cc, (termio)->c_cc, NCC); \
-})
-
-/*
- * Translate a "termios" structure into a "termio". Ugh.
- */
-#define kernel_termios_to_user_termio(termio, termios) \
-({ \
-	put_user((termios)->c_iflag, &(termio)->c_iflag); \
-	put_user((termios)->c_oflag, &(termio)->c_oflag); \
-	put_user((termios)->c_cflag, &(termio)->c_cflag); \
-	put_user((termios)->c_lflag, &(termio)->c_lflag); \
-	put_user((termios)->c_line,  &(termio)->c_line); \
-	copy_to_user((termio)->c_cc, (termios)->c_cc, NCC); \
-})
-
-#define user_termios_to_kernel_termios(k, u) copy_from_user(k, u, sizeof(struct termios2))
-#define kernel_termios_to_user_termios(u, k) copy_to_user(u, k, sizeof(struct termios2))
-#define user_termios_to_kernel_termios_1(k, u) copy_from_user(k, u, sizeof(struct termios))
-#define kernel_termios_to_user_termios_1(u, k) copy_to_user(u, k, sizeof(struct termios))
-
-#endif /* _H8300_TERMIOS_H */
diff --git a/arch/h8300/include/asm/thread_info.h b/arch/h8300/include/asm/thread_info.h
deleted file mode 100644
index ec2f777..0000000
--- a/arch/h8300/include/asm/thread_info.h
+++ /dev/null
@@ -1,103 +0,0 @@
-/* thread_info.h: h8300 low-level thread information
- * adapted from the i386 and PPC versions by Yoshinori Sato <ysato@users.sourceforge.jp>
- *
- * Copyright (C) 2002  David Howells (dhowells@redhat.com)
- * - Incorporating suggestions made by Linus Torvalds and Dave Miller
- */
-
-#ifndef _ASM_THREAD_INFO_H
-#define _ASM_THREAD_INFO_H
-
-#include <asm/page.h>
-
-#ifdef __KERNEL__
-
-#ifndef __ASSEMBLY__
-
-/*
- * low level task data.
- * If you change this, change the TI_* offsets below to match.
- */
-struct thread_info {
-	struct task_struct *task;		/* main task structure */
-	struct exec_domain *exec_domain;	/* execution domain */
-	unsigned long	   flags;		/* low level flags */
-	int		   cpu;			/* cpu we're on */
-	int		   preempt_count;	/* 0 => preemptable, <0 => BUG */
-	struct restart_block restart_block;
-};
-
-/*
- * macros/functions for gaining access to the thread information structure
- */
-#define INIT_THREAD_INFO(tsk)			\
-{						\
-	.task =		&tsk,			\
-	.exec_domain =	&default_exec_domain,	\
-	.flags =	0,			\
-	.cpu =		0,			\
-	.preempt_count = INIT_PREEMPT_COUNT,	\
-	.restart_block	= {			\
-		.fn = do_no_restart_syscall,	\
-	},					\
-}
-
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
-
-/*
- * Size of kernel stack for each process. This must be a power of 2...
- */
-#define THREAD_SIZE_ORDER	1
-#define THREAD_SIZE		8192	/* 2 pages */
-
-
-/* how to get the thread information struct from C */
-static inline struct thread_info *current_thread_info(void)
-{
-	struct thread_info *ti;
-	__asm__(
-		"mov.l	sp, %0 \n\t"
-		"and.l	%1, %0"
-		: "=&r"(ti)
-		: "i" (~(THREAD_SIZE-1))
-		);
-	return ti;
-}
-
-#endif /* __ASSEMBLY__ */
-
-/*
- * Offsets in thread_info structure, used in assembly code
- */
-#define TI_TASK		0
-#define TI_EXECDOMAIN	4
-#define TI_FLAGS	8
-#define TI_CPU		12
-#define TI_PRE_COUNT	16
-
-#define	PREEMPT_ACTIVE	0x4000000
-
-/*
- * thread information flag bit numbers
- */
-#define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_SIGPENDING		1	/* signal pending */
-#define TIF_NEED_RESCHED	2	/* rescheduling necessary */
-#define TIF_MEMDIE		4	/* is terminating due to OOM killer */
-#define TIF_RESTORE_SIGMASK	5	/* restore signal mask in do_signal() */
-#define TIF_NOTIFY_RESUME	6	/* callback before returning to user */
-
-/* as above, but as bit values */
-#define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
-#define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
-#define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
-
-#define _TIF_WORK_MASK		(_TIF_SIGPENDING | _TIF_NEED_RESCHED | \
-				 _TIF_NOTIFY_RESUME)
-
-#endif /* __KERNEL__ */
-
-#endif /* _ASM_THREAD_INFO_H */
diff --git a/arch/h8300/include/asm/timer.h b/arch/h8300/include/asm/timer.h
deleted file mode 100644
index def8046..0000000
--- a/arch/h8300/include/asm/timer.h
+++ /dev/null
@@ -1,25 +0,0 @@
-#ifndef __H8300_TIMER_H
-#define __H8300_TIMER_H
-
-void h8300_timer_tick(void);
-void h8300_timer_setup(void);
-void h8300_gettod(unsigned int *year, unsigned int *mon, unsigned int *day,
-		   unsigned int *hour, unsigned int *min, unsigned int *sec);
-
-#define TIMER_FREQ (CONFIG_CPU_CLOCK*10000) /* Timer input freq. */
-
-#define calc_param(cnt, div, rate, limit)			\
-do {								\
-	cnt = TIMER_FREQ / HZ;					\
-	for (div = 0; div < ARRAY_SIZE(divide_rate); div++) {	\
-		if (rate[div] == 0)				\
-			continue;				\
-		if ((cnt / rate[div]) > limit)			\
-			break;					\
-	}							\
-	if (div == ARRAY_SIZE(divide_rate))			\
-		panic("Timer counter overflow");		\
-	cnt /= divide_rate[div];				\
-} while(0)
-
-#endif
diff --git a/arch/h8300/include/asm/timex.h b/arch/h8300/include/asm/timex.h
deleted file mode 100644
index 23e6701..0000000
--- a/arch/h8300/include/asm/timex.h
+++ /dev/null
@@ -1,19 +0,0 @@
-/*
- * linux/include/asm-h8300/timex.h
- *
- * H8/300 architecture timex specifications
- */
-#ifndef _ASM_H8300_TIMEX_H
-#define _ASM_H8300_TIMEX_H
-
-#define CLOCK_TICK_RATE (CONFIG_CPU_CLOCK*1000/8192) /* Timer input freq. */
-
-typedef unsigned long cycles_t;
-extern short h8300_timer_count;
-
-static inline cycles_t get_cycles(void)
-{
-	return 0;
-}
-
-#endif
diff --git a/arch/h8300/include/asm/tlb.h b/arch/h8300/include/asm/tlb.h
deleted file mode 100644
index 7f07430..0000000
--- a/arch/h8300/include/asm/tlb.h
+++ /dev/null
@@ -1,8 +0,0 @@
-#ifndef __H8300_TLB_H__
-#define __H8300_TLB_H__
-
-#define tlb_flush(tlb)	do { } while(0)
-
-#include <asm-generic/tlb.h>
-
-#endif
diff --git a/arch/h8300/include/asm/tlbflush.h b/arch/h8300/include/asm/tlbflush.h
deleted file mode 100644
index 41c148a..0000000
--- a/arch/h8300/include/asm/tlbflush.h
+++ /dev/null
@@ -1,55 +0,0 @@
-#ifndef _H8300_TLBFLUSH_H
-#define _H8300_TLBFLUSH_H
-
-/*
- * Copyright (C) 2000 Lineo, David McCullough <davidm@uclinux.org>
- * Copyright (C) 2000-2002, Greg Ungerer <gerg@snapgear.com>
- */
-
-#include <asm/setup.h>
-
-/*
- * flush all user-space atc entries.
- */
-static inline void __flush_tlb(void)
-{
-	BUG();
-}
-
-static inline void __flush_tlb_one(unsigned long addr)
-{
-	BUG();
-}
-
-#define flush_tlb() __flush_tlb()
-
-/*
- * flush all atc entries (both kernel and user-space entries).
- */
-static inline void flush_tlb_all(void)
-{
-	BUG();
-}
-
-static inline void flush_tlb_mm(struct mm_struct *mm)
-{
-	BUG();
-}
-
-static inline void flush_tlb_page(struct vm_area_struct *vma, unsigned long addr)
-{
-	BUG();
-}
-
-static inline void flush_tlb_range(struct mm_struct *mm,
-				   unsigned long start, unsigned long end)
-{
-	BUG();
-}
-
-static inline void flush_tlb_kernel_page(unsigned long addr)
-{
-	BUG();
-}
-
-#endif /* _H8300_TLBFLUSH_H */
diff --git a/arch/h8300/include/asm/topology.h b/arch/h8300/include/asm/topology.h
deleted file mode 100644
index fdc1219..0000000
--- a/arch/h8300/include/asm/topology.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _ASM_H8300_TOPOLOGY_H
-#define _ASM_H8300_TOPOLOGY_H
-
-#include <asm-generic/topology.h>
-
-#endif /* _ASM_H8300_TOPOLOGY_H */
diff --git a/arch/h8300/include/asm/traps.h b/arch/h8300/include/asm/traps.h
deleted file mode 100644
index 41cf6be..0000000
--- a/arch/h8300/include/asm/traps.h
+++ /dev/null
@@ -1,37 +0,0 @@
-/*
- *  linux/include/asm-h8300/traps.h
- *
- *  Copyright (C) 2003 Yoshinori Sato <ysato@users.sourceforge.jp>
- *
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file COPYING in the main directory of this archive
- * for more details.
- */
-
-#ifndef _H8300_TRAPS_H
-#define _H8300_TRAPS_H
-
-extern void system_call(void);
-extern void interrupt_entry(void);
-extern void trace_break(void);
-
-#define JMP_OP 0x5a000000
-#define JSR_OP 0x5e000000
-#define VECTOR(address) ((JMP_OP)|((unsigned long)address))
-#define REDIRECT(address) ((JSR_OP)|((unsigned long)address))
-
-#define TRACE_VEC 5
-
-#define TRAP0_VEC 8
-#define TRAP1_VEC 9
-#define TRAP2_VEC 10
-#define TRAP3_VEC 11
-
-#if defined(__H8300H__)
-#define NR_TRAPS 12
-#endif
-#if defined(__H8300S__)
-#define NR_TRAPS 16
-#endif
-
-#endif /* _H8300_TRAPS_H */
diff --git a/arch/h8300/include/asm/types.h b/arch/h8300/include/asm/types.h
deleted file mode 100644
index c012707..0000000
--- a/arch/h8300/include/asm/types.h
+++ /dev/null
@@ -1,9 +0,0 @@
-#ifndef _H8300_TYPES_H
-#define _H8300_TYPES_H
-
-#include <uapi/asm/types.h>
-
-
-#define BITS_PER_LONG 32
-
-#endif /* _H8300_TYPES_H */
diff --git a/arch/h8300/include/asm/uaccess.h b/arch/h8300/include/asm/uaccess.h
deleted file mode 100644
index 8725d1a..0000000
--- a/arch/h8300/include/asm/uaccess.h
+++ /dev/null
@@ -1,163 +0,0 @@
-#ifndef __H8300_UACCESS_H
-#define __H8300_UACCESS_H
-
-/*
- * User space memory access functions
- */
-#include <linux/sched.h>
-#include <linux/mm.h>
-#include <linux/string.h>
-
-#include <asm/segment.h>
-
-#define VERIFY_READ	0
-#define VERIFY_WRITE	1
-
-/* We let the MMU do all checking */
-#define access_ok(type, addr, size) __access_ok((unsigned long)addr,size)
-static inline int __access_ok(unsigned long addr, unsigned long size)
-{
-#define	RANGE_CHECK_OK(addr, size, lower, upper) \
-	(((addr) >= (lower)) && (((addr) + (size)) < (upper)))
-
-	extern unsigned long _ramend;
-	return(RANGE_CHECK_OK(addr, size, 0L, (unsigned long)&_ramend));
-}
-
-/*
- * The exception table consists of pairs of addresses: the first is the
- * address of an instruction that is allowed to fault, and the second is
- * the address at which the program should continue.  No registers are
- * modified, so it is entirely up to the continuation code to figure out
- * what to do.
- *
- * All the routines below use bits of fixup code that are out of line
- * with the main instruction path.  This means when everything is well,
- * we don't even have to jump over them.  Further, they do not intrude
- * on our cache or tlb entries.
- */
-
-struct exception_table_entry
-{
-	unsigned long insn, fixup;
-};
-
-/* Returns 0 if exception not found and fixup otherwise.  */
-extern unsigned long search_exception_table(unsigned long);
-
-
-/*
- * These are the main single-value transfer routines.  They automatically
- * use the right size if we just have the right pointer type.
- */
-
-#define put_user(x, ptr)				\
-({							\
-    int __pu_err = 0;					\
-    typeof(*(ptr)) __pu_val = (x);			\
-    switch (sizeof (*(ptr))) {				\
-    case 1:						\
-    case 2:						\
-    case 4:						\
-	*(ptr) = (__pu_val);   	        		\
-	break;						\
-    case 8:						\
-	memcpy(ptr, &__pu_val, sizeof (*(ptr)));        \
-	break;						\
-    default:						\
-	__pu_err = __put_user_bad();			\
-	break;						\
-    }							\
-    __pu_err;						\
-})
-#define __put_user(x, ptr) put_user(x, ptr)
-
-extern int __put_user_bad(void);
-
-/*
- * Tell gcc we read from memory instead of writing: this is because
- * we do not write to any memory gcc knows about, so there are no
- * aliasing issues.
- */
-
-#define __ptr(x) ((unsigned long *)(x))
-
-/*
- * Tell gcc we read from memory instead of writing: this is because
- * we do not write to any memory gcc knows about, so there are no
- * aliasing issues.
- */
-
-#define get_user(x, ptr)					\
-({								\
-    int __gu_err = 0;						\
-    typeof(*(ptr)) __gu_val = *ptr;				\
-    switch (sizeof(*(ptr))) {					\
-    case 1:							\
-    case 2:							\
-    case 4:							\
-    case 8: 							\
-	break;							\
-    default:							\
-	__gu_err = __get_user_bad();				\
-	break;							\
-    }								\
-    (x) = __gu_val;						\
-    __gu_err;							\
-})
-#define __get_user(x, ptr) get_user(x, ptr)
-
-extern int __get_user_bad(void);
-
-#define copy_from_user(to, from, n)		(memcpy(to, from, n), 0)
-#define copy_to_user(to, from, n)		(memcpy(to, from, n), 0)
-
-#define __copy_from_user(to, from, n) copy_from_user(to, from, n)
-#define __copy_to_user(to, from, n) copy_to_user(to, from, n)
-#define __copy_to_user_inatomic __copy_to_user
-#define __copy_from_user_inatomic __copy_from_user
-
-#define copy_to_user_ret(to,from,n,retval) ({ if (copy_to_user(to,from,n)) return retval; })
-
-#define copy_from_user_ret(to,from,n,retval) ({ if (copy_from_user(to,from,n)) return retval; })
-
-/*
- * Copy a null terminated string from userspace.
- */
-
-static inline long
-strncpy_from_user(char *dst, const char *src, long count)
-{
-	char *tmp;
-	strncpy(dst, src, count);
-	for (tmp = dst; *tmp && count > 0; tmp++, count--)
-		;
-	return(tmp - dst); /* DAVIDM should we count a NUL ?  check getname */
-}
-
-/*
- * Return the size of a string (including the ending 0)
- *
- * Return 0 on exception, a value greater than N if too long
- */
-static inline long strnlen_user(const char *src, long n)
-{
-	return(strlen(src) + 1); /* DAVIDM make safer */
-}
-
-#define strlen_user(str) strnlen_user(str, 32767)
-
-/*
- * Zero Userspace
- */
-
-static inline unsigned long
-clear_user(void *to, unsigned long n)
-{
-	memset(to, 0, n);
-	return 0;
-}
-
-#define __clear_user	clear_user
-
-#endif /* _H8300_UACCESS_H */
diff --git a/arch/h8300/include/asm/ucontext.h b/arch/h8300/include/asm/ucontext.h
deleted file mode 100644
index 0bcf8f8..0000000
--- a/arch/h8300/include/asm/ucontext.h
+++ /dev/null
@@ -1,12 +0,0 @@
-#ifndef _H8300_UCONTEXT_H
-#define _H8300_UCONTEXT_H
-
-struct ucontext {
-	unsigned long	  uc_flags;
-	struct ucontext  *uc_link;
-	stack_t		  uc_stack;
-	struct sigcontext uc_mcontext;
-	sigset_t	  uc_sigmask;	/* mask last for extensibility */
-};
-
-#endif
diff --git a/arch/h8300/include/asm/unaligned.h b/arch/h8300/include/asm/unaligned.h
deleted file mode 100644
index b8d06c7..0000000
--- a/arch/h8300/include/asm/unaligned.h
+++ /dev/null
@@ -1,11 +0,0 @@
-#ifndef _ASM_H8300_UNALIGNED_H
-#define _ASM_H8300_UNALIGNED_H
-
-#include <linux/unaligned/be_memmove.h>
-#include <linux/unaligned/le_byteshift.h>
-#include <linux/unaligned/generic.h>
-
-#define get_unaligned	__get_unaligned_be
-#define put_unaligned	__put_unaligned_be
-
-#endif /* _ASM_H8300_UNALIGNED_H */
diff --git a/arch/h8300/include/asm/unistd.h b/arch/h8300/include/asm/unistd.h
deleted file mode 100644
index ab671ec..0000000
--- a/arch/h8300/include/asm/unistd.h
+++ /dev/null
@@ -1,36 +0,0 @@
-#ifndef _ASM_H8300_UNISTD_H_
-#define _ASM_H8300_UNISTD_H_
-
-#include <uapi/asm/unistd.h>
-
-
-#define NR_syscalls 321
-
-#define __ARCH_WANT_OLD_READDIR
-#define __ARCH_WANT_OLD_STAT
-#define __ARCH_WANT_STAT64
-#define __ARCH_WANT_SYS_ALARM
-#define __ARCH_WANT_SYS_GETHOSTNAME
-#define __ARCH_WANT_SYS_IPC
-#define __ARCH_WANT_SYS_PAUSE
-#define __ARCH_WANT_SYS_SGETMASK
-#define __ARCH_WANT_SYS_SIGNAL
-#define __ARCH_WANT_SYS_TIME
-#define __ARCH_WANT_SYS_UTIME
-#define __ARCH_WANT_SYS_WAITPID
-#define __ARCH_WANT_SYS_SOCKETCALL
-#define __ARCH_WANT_SYS_FADVISE64
-#define __ARCH_WANT_SYS_GETPGRP
-#define __ARCH_WANT_SYS_LLSEEK
-#define __ARCH_WANT_SYS_NICE
-#define __ARCH_WANT_SYS_OLD_GETRLIMIT
-#define __ARCH_WANT_SYS_OLD_MMAP
-#define __ARCH_WANT_SYS_OLD_SELECT
-#define __ARCH_WANT_SYS_OLDUMOUNT
-#define __ARCH_WANT_SYS_SIGPENDING
-#define __ARCH_WANT_SYS_SIGPROCMASK
-#define __ARCH_WANT_SYS_FORK
-#define __ARCH_WANT_SYS_VFORK
-#define __ARCH_WANT_SYS_CLONE
-
-#endif /* _ASM_H8300_UNISTD_H_ */
diff --git a/arch/h8300/include/asm/user.h b/arch/h8300/include/asm/user.h
deleted file mode 100644
index 14a9e18..0000000
--- a/arch/h8300/include/asm/user.h
+++ /dev/null
@@ -1,75 +0,0 @@
-#ifndef _H8300_USER_H
-#define _H8300_USER_H
-
-#include <asm/page.h>
-
-/* Core file format: The core file is written in such a way that gdb
-   can understand it and provide useful information to the user (under
-   linux we use the 'trad-core' bfd).  There are quite a number of
-   obstacles to being able to view the contents of the floating point
-   registers, and until these are solved you will not be able to view the
-   contents of them.  Actually, you can read in the core file and look at
-   the contents of the user struct to find out what the floating point
-   registers contain.
-   The actual file contents are as follows:
-   UPAGE: 1 page consisting of a user struct that tells gdb what is present
-   in the file.  Directly after this is a copy of the task_struct, which
-   is currently not used by gdb, but it may come in useful at some point.
-   All of the registers are stored as part of the upage.  The upage should
-   always be only one page.
-   DATA: The data area is stored.  We use current->end_text to
-   current->brk to pick up all of the user variables, plus any memory
-   that may have been malloced.  No attempt is made to determine if a page
-   is demand-zero or if a page is totally unused, we just cover the entire
-   range.  All of the addresses are rounded in such a way that an integral
-   number of pages is written.
-   STACK: We need the stack information in order to get a meaningful
-   backtrace.  We need to write the data from (esp) to
-   current->start_stack, so we round each of these off in order to be able
-   to write an integer number of pages.
-   The minimum core file size is 3 pages, or 12288 bytes.
-*/
-
-/* This is the old layout of "struct pt_regs" as of Linux 1.x, and
-   is still the layout used by user (the new pt_regs doesn't have
-   all registers). */
-struct user_regs_struct {
-	long er1,er2,er3,er4,er5,er6;
-	long er0;
-	long usp;
-	long orig_er0;
-	short ccr;
-	long pc;
-};
-
-	
-/* When the kernel dumps core, it starts by dumping the user struct -
-   this will be used by gdb to figure out where the data and stack segments
-   are within the file, and what virtual addresses to use. */
-struct user{
-/* We start with the registers, to mimic the way that "memory" is returned
-   from the ptrace(3,...) function.  */
-  struct user_regs_struct regs;	/* Where the registers are actually stored */
-/* ptrace does not yet supply these.  Someday.... */
-/* The rest of this junk is to help gdb figure out what goes where */
-  unsigned long int u_tsize;	/* Text segment size (pages). */
-  unsigned long int u_dsize;	/* Data segment size (pages). */
-  unsigned long int u_ssize;	/* Stack segment size (pages). */
-  unsigned long start_code;     /* Starting virtual address of text. */
-  unsigned long start_stack;	/* Starting virtual address of stack area.
-				   This is actually the bottom of the stack,
-				   the top of the stack is always found in the
-				   esp register.  */
-  long int signal;     		/* Signal that caused the core dump. */
-  int reserved;			/* No longer used */
-  unsigned long u_ar0;		/* Used by gdb to help find the values for */
-				/* the registers. */
-  unsigned long magic;		/* To uniquely identify a core file */
-  char u_comm[32];		/* User command that was responsible */
-};
-#define NBPG PAGE_SIZE
-#define UPAGES 1
-#define HOST_TEXT_START_ADDR (u.start_code)
-#define HOST_STACK_END_ADDR (u.start_stack + u.u_ssize * NBPG)
-
-#endif
diff --git a/arch/h8300/include/asm/virtconvert.h b/arch/h8300/include/asm/virtconvert.h
deleted file mode 100644
index 19cfd62..0000000
--- a/arch/h8300/include/asm/virtconvert.h
+++ /dev/null
@@ -1,20 +0,0 @@
-#ifndef __H8300_VIRT_CONVERT__
-#define __H8300_VIRT_CONVERT__
-
-/*
- * Macros used for converting between virtual and physical mappings.
- */
-
-#ifdef __KERNEL__
-
-#include <asm/setup.h>
-#include <asm/page.h>
-
-#define phys_to_virt(vaddr)	((void *) (vaddr))
-#define virt_to_phys(vaddr)	((unsigned long) (vaddr))
-
-#define virt_to_bus virt_to_phys
-#define bus_to_virt phys_to_virt
-
-#endif
-#endif
diff --git a/arch/h8300/include/uapi/asm/Kbuild b/arch/h8300/include/uapi/asm/Kbuild
deleted file mode 100644
index 040178c..0000000
--- a/arch/h8300/include/uapi/asm/Kbuild
+++ /dev/null
@@ -1,34 +0,0 @@
-# UAPI Header export list
-include include/uapi/asm-generic/Kbuild.asm
-
-header-y += auxvec.h
-header-y += bitsperlong.h
-header-y += byteorder.h
-header-y += errno.h
-header-y += fcntl.h
-header-y += ioctl.h
-header-y += ioctls.h
-header-y += ipcbuf.h
-header-y += kvm_para.h
-header-y += mman.h
-header-y += msgbuf.h
-header-y += param.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += ptrace.h
-header-y += resource.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += shmbuf.h
-header-y += sigcontext.h
-header-y += siginfo.h
-header-y += signal.h
-header-y += socket.h
-header-y += sockios.h
-header-y += stat.h
-header-y += statfs.h
-header-y += swab.h
-header-y += termbits.h
-header-y += termios.h
-header-y += types.h
-header-y += unistd.h
diff --git a/arch/h8300/include/uapi/asm/auxvec.h b/arch/h8300/include/uapi/asm/auxvec.h
deleted file mode 100644
index 1d36fe38..0000000
--- a/arch/h8300/include/uapi/asm/auxvec.h
+++ /dev/null
@@ -1,4 +0,0 @@
-#ifndef __ASMH8300_AUXVEC_H
-#define __ASMH8300_AUXVEC_H
-
-#endif
diff --git a/arch/h8300/include/uapi/asm/bitsperlong.h b/arch/h8300/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 6dc0bb0..0000000
--- a/arch/h8300/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1 +0,0 @@
-#include <asm-generic/bitsperlong.h>
diff --git a/arch/h8300/include/uapi/asm/byteorder.h b/arch/h8300/include/uapi/asm/byteorder.h
deleted file mode 100644
index 13539da..0000000
--- a/arch/h8300/include/uapi/asm/byteorder.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _H8300_BYTEORDER_H
-#define _H8300_BYTEORDER_H
-
-#include <linux/byteorder/big_endian.h>
-
-#endif /* _H8300_BYTEORDER_H */
diff --git a/arch/h8300/include/uapi/asm/errno.h b/arch/h8300/include/uapi/asm/errno.h
deleted file mode 100644
index 0c2f564..0000000
--- a/arch/h8300/include/uapi/asm/errno.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _H8300_ERRNO_H
-#define _H8300_ERRNO_H
-
-#include <asm-generic/errno.h>
-
-#endif /* _H8300_ERRNO_H */
diff --git a/arch/h8300/include/uapi/asm/fcntl.h b/arch/h8300/include/uapi/asm/fcntl.h
deleted file mode 100644
index 1952cb2e..0000000
--- a/arch/h8300/include/uapi/asm/fcntl.h
+++ /dev/null
@@ -1,11 +0,0 @@
-#ifndef _H8300_FCNTL_H
-#define _H8300_FCNTL_H
-
-#define O_DIRECTORY	040000	/* must be a directory */
-#define O_NOFOLLOW	0100000	/* don't follow links */
-#define O_DIRECT	0200000	/* direct disk access hint - currently ignored */
-#define O_LARGEFILE	0400000
-
-#include <asm-generic/fcntl.h>
-
-#endif /* _H8300_FCNTL_H */
diff --git a/arch/h8300/include/uapi/asm/ioctl.h b/arch/h8300/include/uapi/asm/ioctl.h
deleted file mode 100644
index b279fe0..0000000
--- a/arch/h8300/include/uapi/asm/ioctl.h
+++ /dev/null
@@ -1 +0,0 @@
-#include <asm-generic/ioctl.h>
diff --git a/arch/h8300/include/uapi/asm/ioctls.h b/arch/h8300/include/uapi/asm/ioctls.h
deleted file mode 100644
index 30eaed2..0000000
--- a/arch/h8300/include/uapi/asm/ioctls.h
+++ /dev/null
@@ -1,8 +0,0 @@
-#ifndef __ARCH_H8300_IOCTLS_H__
-#define __ARCH_H8300_IOCTLS_H__
-
-#define FIOQSIZE	0x545E
-
-#include <asm-generic/ioctls.h>
-
-#endif /* __ARCH_H8300_IOCTLS_H__ */
diff --git a/arch/h8300/include/uapi/asm/ipcbuf.h b/arch/h8300/include/uapi/asm/ipcbuf.h
deleted file mode 100644
index 84c7e51..0000000
--- a/arch/h8300/include/uapi/asm/ipcbuf.h
+++ /dev/null
@@ -1 +0,0 @@
-#include <asm-generic/ipcbuf.h>
diff --git a/arch/h8300/include/uapi/asm/kvm_para.h b/arch/h8300/include/uapi/asm/kvm_para.h
deleted file mode 100644
index 14fab8f..0000000
--- a/arch/h8300/include/uapi/asm/kvm_para.h
+++ /dev/null
@@ -1 +0,0 @@
-#include <asm-generic/kvm_para.h>
diff --git a/arch/h8300/include/uapi/asm/mman.h b/arch/h8300/include/uapi/asm/mman.h
deleted file mode 100644
index 8eebf89..0000000
--- a/arch/h8300/include/uapi/asm/mman.h
+++ /dev/null
@@ -1 +0,0 @@
-#include <asm-generic/mman.h>
diff --git a/arch/h8300/include/uapi/asm/msgbuf.h b/arch/h8300/include/uapi/asm/msgbuf.h
deleted file mode 100644
index 6b148cd..0000000
--- a/arch/h8300/include/uapi/asm/msgbuf.h
+++ /dev/null
@@ -1,31 +0,0 @@
-#ifndef _H8300_MSGBUF_H
-#define _H8300_MSGBUF_H
-
-/* 
- * The msqid64_ds structure for H8/300 architecture.
- * Note extra padding because this structure is passed back and forth
- * between kernel and user space.
- *
- * Pad space is left for:
- * - 64-bit time_t to solve y2038 problem
- * - 2 miscellaneous 32-bit values
- */
-
-struct msqid64_ds {
-	struct ipc64_perm msg_perm;
-	__kernel_time_t msg_stime;	/* last msgsnd time */
-	unsigned long	__unused1;
-	__kernel_time_t msg_rtime;	/* last msgrcv time */
-	unsigned long	__unused2;
-	__kernel_time_t msg_ctime;	/* last change time */
-	unsigned long	__unused3;
-	unsigned long  msg_cbytes;	/* current number of bytes on queue */
-	unsigned long  msg_qnum;	/* number of messages in queue */
-	unsigned long  msg_qbytes;	/* max number of bytes on queue */
-	__kernel_pid_t msg_lspid;	/* pid of last msgsnd */
-	__kernel_pid_t msg_lrpid;	/* last receive pid */
-	unsigned long  __unused4;
-	unsigned long  __unused5;
-};
-
-#endif /* _H8300_MSGBUF_H */
diff --git a/arch/h8300/include/uapi/asm/param.h b/arch/h8300/include/uapi/asm/param.h
deleted file mode 100644
index 3dd18ae..0000000
--- a/arch/h8300/include/uapi/asm/param.h
+++ /dev/null
@@ -1,16 +0,0 @@
-#ifndef _UAPI_H8300_PARAM_H
-#define _UAPI_H8300_PARAM_H
-
-#ifndef __KERNEL__
-#define HZ		100
-#endif
-
-#define EXEC_PAGESIZE	4096
-
-#ifndef NOGROUP
-#define NOGROUP		(-1)
-#endif
-
-#define MAXHOSTNAMELEN	64	/* max length of hostname */
-
-#endif /* _UAPI_H8300_PARAM_H */
diff --git a/arch/h8300/include/uapi/asm/poll.h b/arch/h8300/include/uapi/asm/poll.h
deleted file mode 100644
index f61540c..0000000
--- a/arch/h8300/include/uapi/asm/poll.h
+++ /dev/null
@@ -1,11 +0,0 @@
-#ifndef __H8300_POLL_H
-#define __H8300_POLL_H
-
-#define POLLWRNORM	POLLOUT
-#define POLLWRBAND	256
-
-#include <asm-generic/poll.h>
-
-#undef POLLREMOVE
-
-#endif
diff --git a/arch/h8300/include/uapi/asm/posix_types.h b/arch/h8300/include/uapi/asm/posix_types.h
deleted file mode 100644
index 91e62ba..0000000
--- a/arch/h8300/include/uapi/asm/posix_types.h
+++ /dev/null
@@ -1,26 +0,0 @@
-#ifndef __ARCH_H8300_POSIX_TYPES_H
-#define __ARCH_H8300_POSIX_TYPES_H
-
-/*
- * This file is generally used by user-level software, so you need to
- * be a little careful about namespace pollution etc.  Also, we cannot
- * assume GCC is being used.
- */
-
-typedef unsigned short	__kernel_mode_t;
-#define __kernel_mode_t __kernel_mode_t
-
-typedef unsigned short	__kernel_ipc_pid_t;
-#define __kernel_ipc_pid_t __kernel_ipc_pid_t
-
-typedef unsigned short	__kernel_uid_t;
-typedef unsigned short	__kernel_gid_t;
-#define __kernel_uid_t __kernel_uid_t
-
-typedef unsigned short	__kernel_old_uid_t;
-typedef unsigned short	__kernel_old_gid_t;
-#define __kernel_old_uid_t __kernel_old_uid_t
-
-#include <asm-generic/posix_types.h>
-
-#endif
diff --git a/arch/h8300/include/uapi/asm/ptrace.h b/arch/h8300/include/uapi/asm/ptrace.h
deleted file mode 100644
index ef39ec5..0000000
--- a/arch/h8300/include/uapi/asm/ptrace.h
+++ /dev/null
@@ -1,44 +0,0 @@
-#ifndef _UAPI_H8300_PTRACE_H
-#define _UAPI_H8300_PTRACE_H
-
-#ifndef __ASSEMBLY__
-
-#define PT_ER1	   0
-#define PT_ER2	   1
-#define PT_ER3	   2
-#define PT_ER4	   3
-#define PT_ER5	   4
-#define PT_ER6	   5
-#define PT_ER0	   6
-#define PT_ORIG_ER0	   7
-#define PT_CCR	   8
-#define PT_PC	   9
-#define PT_USP	   10
-#define PT_EXR     12
-
-/* this struct defines the way the registers are stored on the
-   stack during a system call. */
-
-struct pt_regs {
-	long     retpc;
-	long     er4;
-	long     er5;
-	long     er6;
-	long     er3;
-	long     er2;
-	long     er1;
-	long     orig_er0;
-	unsigned short ccr;
-	long     er0;
-	long     vector;
-#if defined(CONFIG_CPU_H8S)
-	unsigned short exr;
-#endif
-	unsigned long  pc;
-} __attribute__((aligned(2),packed));
-
-#define PTRACE_GETREGS            12
-#define PTRACE_SETREGS            13
-
-#endif /* __ASSEMBLY__ */
-#endif /* _UAPI_H8300_PTRACE_H */
diff --git a/arch/h8300/include/uapi/asm/resource.h b/arch/h8300/include/uapi/asm/resource.h
deleted file mode 100644
index 46c5f43..0000000
--- a/arch/h8300/include/uapi/asm/resource.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _H8300_RESOURCE_H
-#define _H8300_RESOURCE_H
-
-#include <asm-generic/resource.h>
-
-#endif /* _H8300_RESOURCE_H */
diff --git a/arch/h8300/include/uapi/asm/sembuf.h b/arch/h8300/include/uapi/asm/sembuf.h
deleted file mode 100644
index e04a3ec..0000000
--- a/arch/h8300/include/uapi/asm/sembuf.h
+++ /dev/null
@@ -1,25 +0,0 @@
-#ifndef _H8300_SEMBUF_H
-#define _H8300_SEMBUF_H
-
-/* 
- * The semid64_ds structure for m68k architecture.
- * Note extra padding because this structure is passed back and forth
- * between kernel and user space.
- *
- * Pad space is left for:
- * - 64-bit time_t to solve y2038 problem
- * - 2 miscellaneous 32-bit values
- */
-
-struct semid64_ds {
-	struct ipc64_perm sem_perm;		/* permissions .. see ipc.h */
-	__kernel_time_t	sem_otime;		/* last semop time */
-	unsigned long	__unused1;
-	__kernel_time_t	sem_ctime;		/* last change time */
-	unsigned long	__unused2;
-	unsigned long	sem_nsems;		/* no. of semaphores in array */
-	unsigned long	__unused3;
-	unsigned long	__unused4;
-};
-
-#endif /* _H8300_SEMBUF_H */
diff --git a/arch/h8300/include/uapi/asm/setup.h b/arch/h8300/include/uapi/asm/setup.h
deleted file mode 100644
index e2c600e..0000000
--- a/arch/h8300/include/uapi/asm/setup.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef __H8300_SETUP_H
-#define __H8300_SETUP_H
-
-#define COMMAND_LINE_SIZE	512
-
-#endif
diff --git a/arch/h8300/include/uapi/asm/shmbuf.h b/arch/h8300/include/uapi/asm/shmbuf.h
deleted file mode 100644
index 64e7799..0000000
--- a/arch/h8300/include/uapi/asm/shmbuf.h
+++ /dev/null
@@ -1,42 +0,0 @@
-#ifndef _H8300_SHMBUF_H
-#define _H8300_SHMBUF_H
-
-/* 
- * The shmid64_ds structure for m68k architecture.
- * Note extra padding because this structure is passed back and forth
- * between kernel and user space.
- *
- * Pad space is left for:
- * - 64-bit time_t to solve y2038 problem
- * - 2 miscellaneous 32-bit values
- */
-
-struct shmid64_ds {
-	struct ipc64_perm	shm_perm;	/* operation perms */
-	size_t			shm_segsz;	/* size of segment (bytes) */
-	__kernel_time_t		shm_atime;	/* last attach time */
-	unsigned long		__unused1;
-	__kernel_time_t		shm_dtime;	/* last detach time */
-	unsigned long		__unused2;
-	__kernel_time_t		shm_ctime;	/* last change time */
-	unsigned long		__unused3;
-	__kernel_pid_t		shm_cpid;	/* pid of creator */
-	__kernel_pid_t		shm_lpid;	/* pid of last operator */
-	unsigned long		shm_nattch;	/* no. of current attaches */
-	unsigned long		__unused4;
-	unsigned long		__unused5;
-};
-
-struct shminfo64 {
-	unsigned long	shmmax;
-	unsigned long	shmmin;
-	unsigned long	shmmni;
-	unsigned long	shmseg;
-	unsigned long	shmall;
-	unsigned long	__unused1;
-	unsigned long	__unused2;
-	unsigned long	__unused3;
-	unsigned long	__unused4;
-};
-
-#endif /* _H8300_SHMBUF_H */
diff --git a/arch/h8300/include/uapi/asm/sigcontext.h b/arch/h8300/include/uapi/asm/sigcontext.h
deleted file mode 100644
index e4b8150..0000000
--- a/arch/h8300/include/uapi/asm/sigcontext.h
+++ /dev/null
@@ -1,18 +0,0 @@
-#ifndef _ASM_H8300_SIGCONTEXT_H
-#define _ASM_H8300_SIGCONTEXT_H
-
-struct sigcontext {
-	unsigned long  sc_mask; 	/* old sigmask */
-	unsigned long  sc_usp;		/* old user stack pointer */
-	unsigned long  sc_er0;
-	unsigned long  sc_er1;
-	unsigned long  sc_er2;
-	unsigned long  sc_er3;
-	unsigned long  sc_er4;
-	unsigned long  sc_er5;
-	unsigned long  sc_er6;
-	unsigned short sc_ccr;
-	unsigned long  sc_pc;
-};
-
-#endif
diff --git a/arch/h8300/include/uapi/asm/siginfo.h b/arch/h8300/include/uapi/asm/siginfo.h
deleted file mode 100644
index bc8fbea..0000000
--- a/arch/h8300/include/uapi/asm/siginfo.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _H8300_SIGINFO_H
-#define _H8300_SIGINFO_H
-
-#include <asm-generic/siginfo.h>
-
-#endif
diff --git a/arch/h8300/include/uapi/asm/signal.h b/arch/h8300/include/uapi/asm/signal.h
deleted file mode 100644
index af3a6c3..0000000
--- a/arch/h8300/include/uapi/asm/signal.h
+++ /dev/null
@@ -1,115 +0,0 @@
-#ifndef _UAPI_H8300_SIGNAL_H
-#define _UAPI_H8300_SIGNAL_H
-
-#include <linux/types.h>
-
-/* Avoid too many header ordering problems.  */
-struct siginfo;
-
-#ifndef __KERNEL__
-/* Here we must cater to libcs that poke about in kernel headers.  */
-
-#define NSIG		32
-typedef unsigned long sigset_t;
-
-#endif /* __KERNEL__ */
-
-#define SIGHUP		 1
-#define SIGINT		 2
-#define SIGQUIT		 3
-#define SIGILL		 4
-#define SIGTRAP		 5
-#define SIGABRT		 6
-#define SIGIOT		 6
-#define SIGBUS		 7
-#define SIGFPE		 8
-#define SIGKILL		 9
-#define SIGUSR1		10
-#define SIGSEGV		11
-#define SIGUSR2		12
-#define SIGPIPE		13
-#define SIGALRM		14
-#define SIGTERM		15
-#define SIGSTKFLT	16
-#define SIGCHLD		17
-#define SIGCONT		18
-#define SIGSTOP		19
-#define SIGTSTP		20
-#define SIGTTIN		21
-#define SIGTTOU		22
-#define SIGURG		23
-#define SIGXCPU		24
-#define SIGXFSZ		25
-#define SIGVTALRM	26
-#define SIGPROF		27
-#define SIGWINCH	28
-#define SIGIO		29
-#define SIGPOLL		SIGIO
-/*
-#define SIGLOST		29
-*/
-#define SIGPWR		30
-#define SIGSYS		31
-#define	SIGUNUSED	31
-
-/* These should not be considered constants from userland.  */
-#define SIGRTMIN	32
-#define SIGRTMAX	_NSIG
-
-/*
- * SA_FLAGS values:
- *
- * SA_ONSTACK indicates that a registered stack_t will be used.
- * SA_RESTART flag to get restarting signals (which were the default long ago)
- * SA_NOCLDSTOP flag to turn off SIGCHLD when children stop.
- * SA_RESETHAND clears the handler when the signal is delivered.
- * SA_NOCLDWAIT flag on SIGCHLD to inhibit zombies.
- * SA_NODEFER prevents the current signal from being masked in the handler.
- *
- * SA_ONESHOT and SA_NOMASK are the historical Linux names for the Single
- * Unix names RESETHAND and NODEFER respectively.
- */
-#define SA_NOCLDSTOP	0x00000001
-#define SA_NOCLDWAIT	0x00000002 /* not supported yet */
-#define SA_SIGINFO	0x00000004
-#define SA_ONSTACK	0x08000000
-#define SA_RESTART	0x10000000
-#define SA_NODEFER	0x40000000
-#define SA_RESETHAND	0x80000000
-
-#define SA_NOMASK	SA_NODEFER
-#define SA_ONESHOT	SA_RESETHAND
-
-#define SA_RESTORER	0x04000000
-
-#define MINSIGSTKSZ	2048
-#define SIGSTKSZ	8192
-
-#include <asm-generic/signal-defs.h>
-
-#ifndef __KERNEL__
-/* Here we must cater to libcs that poke about in kernel headers.  */
-
-struct sigaction {
-	union {
-	  __sighandler_t _sa_handler;
-	  void (*_sa_sigaction)(int, struct siginfo *, void *);
-	} _u;
-	sigset_t sa_mask;
-	unsigned long sa_flags;
-	void (*sa_restorer)(void);
-};
-
-#define sa_handler	_u._sa_handler
-#define sa_sigaction	_u._sa_sigaction
-
-#endif /* __KERNEL__ */
-
-typedef struct sigaltstack {
-	void *ss_sp;
-	int ss_flags;
-	size_t ss_size;
-} stack_t;
-
-
-#endif /* _UAPI_H8300_SIGNAL_H */
diff --git a/arch/h8300/include/uapi/asm/socket.h b/arch/h8300/include/uapi/asm/socket.h
deleted file mode 100644
index 9490758..0000000
--- a/arch/h8300/include/uapi/asm/socket.h
+++ /dev/null
@@ -1,79 +0,0 @@
-#ifndef _ASM_SOCKET_H
-#define _ASM_SOCKET_H
-
-#include <asm/sockios.h>
-
-/* For setsockoptions(2) */
-#define SOL_SOCKET	1
-
-#define SO_DEBUG	1
-#define SO_REUSEADDR	2
-#define SO_TYPE		3
-#define SO_ERROR	4
-#define SO_DONTROUTE	5
-#define SO_BROADCAST	6
-#define SO_SNDBUF	7
-#define SO_RCVBUF	8
-#define SO_SNDBUFFORCE	32
-#define SO_RCVBUFFORCE	33
-#define SO_KEEPALIVE	9
-#define SO_OOBINLINE	10
-#define SO_NO_CHECK	11
-#define SO_PRIORITY	12
-#define SO_LINGER	13
-#define SO_BSDCOMPAT	14
-#define SO_REUSEPORT	15
-#define SO_PASSCRED	16
-#define SO_PEERCRED	17
-#define SO_RCVLOWAT	18
-#define SO_SNDLOWAT	19
-#define SO_RCVTIMEO	20
-#define SO_SNDTIMEO	21
-
-/* Security levels - as per NRL IPv6 - don't actually do anything */
-#define SO_SECURITY_AUTHENTICATION		22
-#define SO_SECURITY_ENCRYPTION_TRANSPORT	23
-#define SO_SECURITY_ENCRYPTION_NETWORK		24
-
-#define SO_BINDTODEVICE	25
-
-/* Socket filtering */
-#define SO_ATTACH_FILTER        26
-#define SO_DETACH_FILTER        27
-#define SO_GET_FILTER		SO_ATTACH_FILTER
-
-#define SO_PEERNAME             28
-#define SO_TIMESTAMP		29
-#define SCM_TIMESTAMP		SO_TIMESTAMP
-
-#define SO_ACCEPTCONN		30
-
-#define SO_PEERSEC		31
-#define SO_PASSSEC		34
-#define SO_TIMESTAMPNS		35
-#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
-
-#define SO_MARK			36
-
-#define SO_TIMESTAMPING		37
-#define SCM_TIMESTAMPING	SO_TIMESTAMPING
-
-#define SO_PROTOCOL		38
-#define SO_DOMAIN		39
-
-#define SO_RXQ_OVFL             40
-
-#define SO_WIFI_STATUS		41
-#define SCM_WIFI_STATUS		SO_WIFI_STATUS
-#define SO_PEEK_OFF		42
-
-/* Instruct lower device to use last 4-bytes of skb data as FCS */
-#define SO_NOFCS		43
-
-#define SO_LOCK_FILTER		44
-
-#define SO_SELECT_ERR_QUEUE	45
-
-#define SO_BUSY_POLL		46
-
-#endif /* _ASM_SOCKET_H */
diff --git a/arch/h8300/include/uapi/asm/sockios.h b/arch/h8300/include/uapi/asm/sockios.h
deleted file mode 100644
index e9c7ec8..0000000
--- a/arch/h8300/include/uapi/asm/sockios.h
+++ /dev/null
@@ -1,13 +0,0 @@
-#ifndef __ARCH_H8300_SOCKIOS__
-#define __ARCH_H8300_SOCKIOS__
-
-/* Socket-level I/O control calls. */
-#define FIOSETOWN 	0x8901
-#define SIOCSPGRP	0x8902
-#define FIOGETOWN	0x8903
-#define SIOCGPGRP	0x8904
-#define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
-#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
-
-#endif /* __ARCH_H8300_SOCKIOS__ */
diff --git a/arch/h8300/include/uapi/asm/stat.h b/arch/h8300/include/uapi/asm/stat.h
deleted file mode 100644
index 62c3cc2..0000000
--- a/arch/h8300/include/uapi/asm/stat.h
+++ /dev/null
@@ -1,78 +0,0 @@
-#ifndef _H8300_STAT_H
-#define _H8300_STAT_H
-
-struct __old_kernel_stat {
-	unsigned short st_dev;
-	unsigned short st_ino;
-	unsigned short st_mode;
-	unsigned short st_nlink;
-	unsigned short st_uid;
-	unsigned short st_gid;
-	unsigned short st_rdev;
-	unsigned long  st_size;
-	unsigned long  st_atime;
-	unsigned long  st_mtime;
-	unsigned long  st_ctime;
-};
-
-struct stat {
-	unsigned short st_dev;
-	unsigned short __pad1;
-	unsigned long st_ino;
-	unsigned short st_mode;
-	unsigned short st_nlink;
-	unsigned short st_uid;
-	unsigned short st_gid;
-	unsigned short st_rdev;
-	unsigned short __pad2;
-	unsigned long  st_size;
-	unsigned long  st_blksize;
-	unsigned long  st_blocks;
-	unsigned long  st_atime;
-	unsigned long  __unused1;
-	unsigned long  st_mtime;
-	unsigned long  __unused2;
-	unsigned long  st_ctime;
-	unsigned long  __unused3;
-	unsigned long  __unused4;
-	unsigned long  __unused5;
-};
-
-/* This matches struct stat64 in glibc2.1, hence the absolutely
- * insane amounts of padding around dev_t's.
- */
-struct stat64 {
-	unsigned long long	st_dev;
-	unsigned char	__pad1[2];
-
-#define STAT64_HAS_BROKEN_ST_INO	1
-	unsigned long	__st_ino;
-
-	unsigned int	st_mode;
-	unsigned int	st_nlink;
-
-	unsigned long	st_uid;
-	unsigned long	st_gid;
-
-	unsigned long long	st_rdev;
-	unsigned char	__pad3[2];
-
-	long long	st_size;
-	unsigned long	st_blksize;
-
-	unsigned long	__pad4;		/* future possible st_blocks high bits */
-	unsigned long	st_blocks;	/* Number 512-byte blocks allocated. */
-
-	unsigned long	st_atime;
-	unsigned long	st_atime_nsec;
-
-	unsigned long	st_mtime;
-	unsigned long	st_mtime_nsec;
-
-	unsigned long	st_ctime;
-	unsigned long	st_ctime_nsec;
-
-	unsigned long long	st_ino;
-};
-
-#endif /* _H8300_STAT_H */
diff --git a/arch/h8300/include/uapi/asm/statfs.h b/arch/h8300/include/uapi/asm/statfs.h
deleted file mode 100644
index b96efa7..0000000
--- a/arch/h8300/include/uapi/asm/statfs.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _H8300_STATFS_H
-#define _H8300_STATFS_H
-
-#include <asm-generic/statfs.h>
-
-#endif /* _H8300_STATFS_H */
diff --git a/arch/h8300/include/uapi/asm/swab.h b/arch/h8300/include/uapi/asm/swab.h
deleted file mode 100644
index 39abbf5..0000000
--- a/arch/h8300/include/uapi/asm/swab.h
+++ /dev/null
@@ -1,10 +0,0 @@
-#ifndef _H8300_SWAB_H
-#define _H8300_SWAB_H
-
-#include <linux/types.h>
-
-#if defined(__GNUC__) && !defined(__STRICT_ANSI__) || defined(__KERNEL__)
-#  define __SWAB_64_THRU_32__
-#endif
-
-#endif /* _H8300_SWAB_H */
diff --git a/arch/h8300/include/uapi/asm/termbits.h b/arch/h8300/include/uapi/asm/termbits.h
deleted file mode 100644
index 3287a62..0000000
--- a/arch/h8300/include/uapi/asm/termbits.h
+++ /dev/null
@@ -1,201 +0,0 @@
-#ifndef __ARCH_H8300_TERMBITS_H__
-#define __ARCH_H8300_TERMBITS_H__
-
-#include <linux/posix_types.h>
-
-typedef unsigned char	cc_t;
-typedef unsigned int	speed_t;
-typedef unsigned int	tcflag_t;
-
-#define NCCS 19
-struct termios {
-	tcflag_t c_iflag;		/* input mode flags */
-	tcflag_t c_oflag;		/* output mode flags */
-	tcflag_t c_cflag;		/* control mode flags */
-	tcflag_t c_lflag;		/* local mode flags */
-	cc_t c_line;			/* line discipline */
-	cc_t c_cc[NCCS];		/* control characters */
-};
-
-struct termios2 {
-	tcflag_t c_iflag;		/* input mode flags */
-	tcflag_t c_oflag;		/* output mode flags */
-	tcflag_t c_cflag;		/* control mode flags */
-	tcflag_t c_lflag;		/* local mode flags */
-	cc_t c_line;			/* line discipline */
-	cc_t c_cc[NCCS];		/* control characters */
-	speed_t c_ispeed;		/* input speed */
-	speed_t c_ospeed;		/* output speed */
-};
-
-struct ktermios {
-	tcflag_t c_iflag;		/* input mode flags */
-	tcflag_t c_oflag;		/* output mode flags */
-	tcflag_t c_cflag;		/* control mode flags */
-	tcflag_t c_lflag;		/* local mode flags */
-	cc_t c_line;			/* line discipline */
-	cc_t c_cc[NCCS];		/* control characters */
-	speed_t c_ispeed;		/* input speed */
-	speed_t c_ospeed;		/* output speed */
-};
-
-/* c_cc characters */
-#define VINTR 0
-#define VQUIT 1
-#define VERASE 2
-#define VKILL 3
-#define VEOF 4
-#define VTIME 5
-#define VMIN 6
-#define VSWTC 7
-#define VSTART 8
-#define VSTOP 9
-#define VSUSP 10
-#define VEOL 11
-#define VREPRINT 12
-#define VDISCARD 13
-#define VWERASE 14
-#define VLNEXT 15
-#define VEOL2 16
-
-
-/* c_iflag bits */
-#define IGNBRK	0000001
-#define BRKINT	0000002
-#define IGNPAR	0000004
-#define PARMRK	0000010
-#define INPCK	0000020
-#define ISTRIP	0000040
-#define INLCR	0000100
-#define IGNCR	0000200
-#define ICRNL	0000400
-#define IUCLC	0001000
-#define IXON	0002000
-#define IXANY	0004000
-#define IXOFF	0010000
-#define IMAXBEL	0020000
-#define IUTF8	0040000
-
-/* c_oflag bits */
-#define OPOST	0000001
-#define OLCUC	0000002
-#define ONLCR	0000004
-#define OCRNL	0000010
-#define ONOCR	0000020
-#define ONLRET	0000040
-#define OFILL	0000100
-#define OFDEL	0000200
-#define NLDLY	0000400
-#define   NL0	0000000
-#define   NL1	0000400
-#define CRDLY	0003000
-#define   CR0	0000000
-#define   CR1	0001000
-#define   CR2	0002000
-#define   CR3	0003000
-#define TABDLY	0014000
-#define   TAB0	0000000
-#define   TAB1	0004000
-#define   TAB2	0010000
-#define   TAB3	0014000
-#define   XTABS	0014000
-#define BSDLY	0020000
-#define   BS0	0000000
-#define   BS1	0020000
-#define VTDLY	0040000
-#define   VT0	0000000
-#define   VT1	0040000
-#define FFDLY	0100000
-#define   FF0	0000000
-#define   FF1	0100000
-
-/* c_cflag bit meaning */
-#define CBAUD	0010017
-#define  B0	0000000		/* hang up */
-#define  B50	0000001
-#define  B75	0000002
-#define  B110	0000003
-#define  B134	0000004
-#define  B150	0000005
-#define  B200	0000006
-#define  B300	0000007
-#define  B600	0000010
-#define  B1200	0000011
-#define  B1800	0000012
-#define  B2400	0000013
-#define  B4800	0000014
-#define  B9600	0000015
-#define  B19200	0000016
-#define  B38400	0000017
-#define EXTA B19200
-#define EXTB B38400
-#define CSIZE	0000060
-#define   CS5	0000000
-#define   CS6	0000020
-#define   CS7	0000040
-#define   CS8	0000060
-#define CSTOPB	0000100
-#define CREAD	0000200
-#define PARENB	0000400
-#define PARODD	0001000
-#define HUPCL	0002000
-#define CLOCAL	0004000
-#define CBAUDEX 0010000
-#define    BOTHER 0010000
-#define    B57600 0010001
-#define   B115200 0010002
-#define   B230400 0010003
-#define   B460800 0010004
-#define   B500000 0010005
-#define   B576000 0010006
-#define   B921600 0010007
-#define  B1000000 0010010
-#define  B1152000 0010011
-#define  B1500000 0010012
-#define  B2000000 0010013
-#define  B2500000 0010014
-#define  B3000000 0010015
-#define  B3500000 0010016
-#define  B4000000 0010017
-#define CIBAUD	  002003600000		/* input baud rate */
-#define CMSPAR	  010000000000		/* mark or space (stick) parity */
-#define CRTSCTS	  020000000000		/* flow control */
-
-#define IBSHIFT	  16			/* shift from CBAUD to CIBAUD */
-
-/* c_lflag bits */
-#define ISIG	0000001
-#define ICANON	0000002
-#define XCASE	0000004
-#define ECHO	0000010
-#define ECHOE	0000020
-#define ECHOK	0000040
-#define ECHONL	0000100
-#define NOFLSH	0000200
-#define TOSTOP	0000400
-#define ECHOCTL	0001000
-#define ECHOPRT	0002000
-#define ECHOKE	0004000
-#define FLUSHO	0010000
-#define PENDIN	0040000
-#define IEXTEN	0100000
-#define EXTPROC	0200000
-
-
-/* tcflow() and TCXONC use these */
-#define	TCOOFF		0
-#define	TCOON		1
-#define	TCIOFF		2
-#define	TCION		3
-
-/* tcflush() and TCFLSH use these */
-#define	TCIFLUSH	0
-#define	TCOFLUSH	1
-#define	TCIOFLUSH	2
-
-/* tcsetattr uses these */
-#define	TCSANOW		0
-#define	TCSADRAIN	1
-#define	TCSAFLUSH	2
-
-#endif /* __ARCH_H8300_TERMBITS_H__ */
diff --git a/arch/h8300/include/uapi/asm/termios.h b/arch/h8300/include/uapi/asm/termios.h
deleted file mode 100644
index 5a67d7e..0000000
--- a/arch/h8300/include/uapi/asm/termios.h
+++ /dev/null
@@ -1,44 +0,0 @@
-#ifndef _UAPI_H8300_TERMIOS_H
-#define _UAPI_H8300_TERMIOS_H
-
-#include <asm/termbits.h>
-#include <asm/ioctls.h>
- 
-struct winsize {
-	unsigned short ws_row;
-	unsigned short ws_col;
-	unsigned short ws_xpixel;
-	unsigned short ws_ypixel;
-};
-
-#define NCC 8
-struct termio {
-	unsigned short c_iflag;		/* input mode flags */
-	unsigned short c_oflag;		/* output mode flags */
-	unsigned short c_cflag;		/* control mode flags */
-	unsigned short c_lflag;		/* local mode flags */
-	unsigned char c_line;		/* line discipline */
-	unsigned char c_cc[NCC];	/* control characters */
-};
-
-
-/* modem lines */
-#define TIOCM_LE	0x001
-#define TIOCM_DTR	0x002
-#define TIOCM_RTS	0x004
-#define TIOCM_ST	0x008
-#define TIOCM_SR	0x010
-#define TIOCM_CTS	0x020
-#define TIOCM_CAR	0x040
-#define TIOCM_RNG	0x080
-#define TIOCM_DSR	0x100
-#define TIOCM_CD	TIOCM_CAR
-#define TIOCM_RI	TIOCM_RNG
-#define TIOCM_OUT1	0x2000
-#define TIOCM_OUT2	0x4000
-#define TIOCM_LOOP	0x8000
-
-/* ioctl (fd, TIOCSERGETLSR, &result) where result may be as below */
-
-
-#endif /* _UAPI_H8300_TERMIOS_H */
diff --git a/arch/h8300/include/uapi/asm/types.h b/arch/h8300/include/uapi/asm/types.h
deleted file mode 100644
index 9ec9d4c..0000000
--- a/arch/h8300/include/uapi/asm/types.h
+++ /dev/null
@@ -1 +0,0 @@
-#include <asm-generic/int-ll64.h>
diff --git a/arch/h8300/include/uapi/asm/unistd.h b/arch/h8300/include/uapi/asm/unistd.h
deleted file mode 100644
index 8cb5d42..0000000
--- a/arch/h8300/include/uapi/asm/unistd.h
+++ /dev/null
@@ -1,330 +0,0 @@
-#ifndef _UAPI_ASM_H8300_UNISTD_H_
-#define _UAPI_ASM_H8300_UNISTD_H_
-
-/*
- * This file contains the system call numbers.
- */
-
-#define __NR_restart_syscall      0
-#define __NR_exit		  1
-#define __NR_fork		  2
-#define __NR_read		  3
-#define __NR_write		  4
-#define __NR_open		  5
-#define __NR_close		  6
-#define __NR_waitpid		  7
-#define __NR_creat		  8
-#define __NR_link		  9
-#define __NR_unlink		 10
-#define __NR_execve		 11
-#define __NR_chdir		 12
-#define __NR_time		 13
-#define __NR_mknod		 14
-#define __NR_chmod		 15
-#define __NR_lchown		 16
-#define __NR_break		 17
-#define __NR_oldstat		 18
-#define __NR_lseek		 19
-#define __NR_getpid		 20
-#define __NR_mount		 21
-#define __NR_umount		 22
-#define __NR_setuid		 23
-#define __NR_getuid		 24
-#define __NR_stime		 25
-#define __NR_ptrace		 26
-#define __NR_alarm		 27
-#define __NR_oldfstat		 28
-#define __NR_pause		 29
-#define __NR_utime		 30
-#define __NR_stty		 31
-#define __NR_gtty		 32
-#define __NR_access		 33
-#define __NR_nice		 34
-#define __NR_ftime		 35
-#define __NR_sync		 36
-#define __NR_kill		 37
-#define __NR_rename		 38
-#define __NR_mkdir		 39
-#define __NR_rmdir		 40
-#define __NR_dup		 41
-#define __NR_pipe		 42
-#define __NR_times		 43
-#define __NR_prof		 44
-#define __NR_brk		 45
-#define __NR_setgid		 46
-#define __NR_getgid		 47
-#define __NR_signal		 48
-#define __NR_geteuid		 49
-#define __NR_getegid		 50
-#define __NR_acct		 51
-#define __NR_umount2		 52
-#define __NR_lock		 53
-#define __NR_ioctl		 54
-#define __NR_fcntl		 55
-#define __NR_mpx		 56
-#define __NR_setpgid		 57
-#define __NR_ulimit		 58
-#define __NR_oldolduname	 59
-#define __NR_umask		 60
-#define __NR_chroot		 61
-#define __NR_ustat		 62
-#define __NR_dup2		 63
-#define __NR_getppid		 64
-#define __NR_getpgrp		 65
-#define __NR_setsid		 66
-#define __NR_sigaction		 67
-#define __NR_sgetmask		 68
-#define __NR_ssetmask		 69
-#define __NR_setreuid		 70
-#define __NR_setregid		 71
-#define __NR_sigsuspend		 72
-#define __NR_sigpending		 73
-#define __NR_sethostname	 74
-#define __NR_setrlimit		 75
-#define __NR_getrlimit		 76
-#define __NR_getrusage		 77
-#define __NR_gettimeofday	 78
-#define __NR_settimeofday	 79
-#define __NR_getgroups		 80
-#define __NR_setgroups		 81
-#define __NR_select		 82
-#define __NR_symlink		 83
-#define __NR_oldlstat		 84
-#define __NR_readlink		 85
-#define __NR_uselib		 86
-#define __NR_swapon		 87
-#define __NR_reboot		 88
-#define __NR_readdir		 89
-#define __NR_mmap		 90
-#define __NR_munmap		 91
-#define __NR_truncate		 92
-#define __NR_ftruncate		 93
-#define __NR_fchmod		 94
-#define __NR_fchown		 95
-#define __NR_getpriority	 96
-#define __NR_setpriority	 97
-#define __NR_profil		 98
-#define __NR_statfs		 99
-#define __NR_fstatfs		100
-#define __NR_ioperm		101
-#define __NR_socketcall		102
-#define __NR_syslog		103
-#define __NR_setitimer		104
-#define __NR_getitimer		105
-#define __NR_stat		106
-#define __NR_lstat		107
-#define __NR_fstat		108
-#define __NR_olduname		109
-#define __NR_iopl		110
-#define __NR_vhangup		111
-#define __NR_idle		112
-#define __NR_vm86old		113
-#define __NR_wait4		114
-#define __NR_swapoff		115
-#define __NR_sysinfo		116
-#define __NR_ipc		117
-#define __NR_fsync		118
-#define __NR_sigreturn		119
-#define __NR_clone		120
-#define __NR_setdomainname	121
-#define __NR_uname		122
-#define __NR_modify_ldt		123
-#define __NR_adjtimex		124
-#define __NR_mprotect		125
-#define __NR_sigprocmask	126
-#define __NR_create_module	127
-#define __NR_init_module	128
-#define __NR_delete_module	129
-#define __NR_get_kernel_syms	130
-#define __NR_quotactl		131
-#define __NR_getpgid		132
-#define __NR_fchdir		133
-#define __NR_bdflush		134
-#define __NR_sysfs		135
-#define __NR_personality	136
-#define __NR_afs_syscall	137 /* Syscall for Andrew File System */
-#define __NR_setfsuid		138
-#define __NR_setfsgid		139
-#define __NR__llseek		140
-#define __NR_getdents		141
-#define __NR__newselect		142
-#define __NR_flock		143
-#define __NR_msync		144
-#define __NR_readv		145
-#define __NR_writev		146
-#define __NR_getsid		147
-#define __NR_fdatasync		148
-#define __NR__sysctl		149
-#define __NR_mlock		150
-#define __NR_munlock		151
-#define __NR_mlockall		152
-#define __NR_munlockall		153
-#define __NR_sched_setparam		154
-#define __NR_sched_getparam		155
-#define __NR_sched_setscheduler		156
-#define __NR_sched_getscheduler		157
-#define __NR_sched_yield		158
-#define __NR_sched_get_priority_max	159
-#define __NR_sched_get_priority_min	160
-#define __NR_sched_rr_get_interval	161
-#define __NR_nanosleep		162
-#define __NR_mremap		163
-#define __NR_setresuid		164
-#define __NR_getresuid		165
-#define __NR_vm86		166
-#define __NR_query_module	167
-#define __NR_poll		168
-#define __NR_nfsservctl		169
-#define __NR_setresgid		170
-#define __NR_getresgid		171
-#define __NR_prctl		172
-#define __NR_rt_sigreturn	173
-#define __NR_rt_sigaction	174
-#define __NR_rt_sigprocmask	175
-#define __NR_rt_sigpending	176
-#define __NR_rt_sigtimedwait	177
-#define __NR_rt_sigqueueinfo	178
-#define __NR_rt_sigsuspend	179
-#define __NR_pread64		180
-#define __NR_pwrite64		181
-#define __NR_chown		182
-#define __NR_getcwd		183
-#define __NR_capget		184
-#define __NR_capset		185
-#define __NR_sigaltstack	186
-#define __NR_sendfile		187
-#define __NR_getpmsg		188	/* some people actually want streams */
-#define __NR_putpmsg		189	/* some people actually want streams */
-#define __NR_vfork		190
-#define __NR_ugetrlimit		191
-#define __NR_mmap2		192
-#define __NR_truncate64		193
-#define __NR_ftruncate64	194
-#define __NR_stat64		195
-#define __NR_lstat64		196
-#define __NR_fstat64		197
-#define __NR_lchown32		198
-#define __NR_getuid32		199
-#define __NR_getgid32		200
-#define __NR_geteuid32		201
-#define __NR_getegid32		202
-#define __NR_setreuid32		203
-#define __NR_setregid32		204
-#define __NR_getgroups32	205
-#define __NR_setgroups32	206
-#define __NR_fchown32		207
-#define __NR_setresuid32	208
-#define __NR_getresuid32	209
-#define __NR_setresgid32	210
-#define __NR_getresgid32	211
-#define __NR_chown32		212
-#define __NR_setuid32		213
-#define __NR_setgid32		214
-#define __NR_setfsuid32		215
-#define __NR_setfsgid32		216
-#define __NR_pivot_root		217
-#define __NR_mincore		218
-#define __NR_madvise		219
-#define __NR_madvise1		219
-#define __NR_getdents64		220
-#define __NR_fcntl64		221
-/* 223 is unused */
-#define __NR_gettid		224
-#define __NR_readahead		225
-#define __NR_setxattr		226
-#define __NR_lsetxattr		227
-#define __NR_fsetxattr		228
-#define __NR_getxattr		229
-#define __NR_lgetxattr		230
-#define __NR_fgetxattr		231
-#define __NR_listxattr		232
-#define __NR_llistxattr		233
-#define __NR_flistxattr		234
-#define __NR_removexattr	235
-#define __NR_lremovexattr	236
-#define __NR_fremovexattr	237
-#define __NR_tkill		238
-#define __NR_sendfile64		239
-#define __NR_futex		240
-#define __NR_sched_setaffinity	241
-#define __NR_sched_getaffinity	242
-#define __NR_set_thread_area	243
-#define __NR_get_thread_area	244
-#define __NR_io_setup		245
-#define __NR_io_destroy		246
-#define __NR_io_getevents	247
-#define __NR_io_submit		248
-#define __NR_io_cancel		249
-#define __NR_fadvise64		250
-/* 251 is available for reuse (was briefly sys_set_zone_reclaim) */
-#define __NR_exit_group		252
-#define __NR_lookup_dcookie	253
-#define __NR_epoll_create	254
-#define __NR_epoll_ctl		255
-#define __NR_epoll_wait		256
-#define __NR_remap_file_pages	257
-#define __NR_set_tid_address	258
-#define __NR_timer_create	259
-#define __NR_timer_settime	(__NR_timer_create+1)
-#define __NR_timer_gettime	(__NR_timer_create+2)
-#define __NR_timer_getoverrun	(__NR_timer_create+3)
-#define __NR_timer_delete	(__NR_timer_create+4)
-#define __NR_clock_settime	(__NR_timer_create+5)
-#define __NR_clock_gettime	(__NR_timer_create+6)
-#define __NR_clock_getres	(__NR_timer_create+7)
-#define __NR_clock_nanosleep	(__NR_timer_create+8)
-#define __NR_statfs64		268
-#define __NR_fstatfs64		269
-#define __NR_tgkill		270
-#define __NR_utimes		271
-#define __NR_fadvise64_64	272
-#define __NR_vserver		273
-#define __NR_mbind		274
-#define __NR_get_mempolicy	275
-#define __NR_set_mempolicy	276
-#define __NR_mq_open 		277
-#define __NR_mq_unlink		(__NR_mq_open+1)
-#define __NR_mq_timedsend	(__NR_mq_open+2)
-#define __NR_mq_timedreceive	(__NR_mq_open+3)
-#define __NR_mq_notify		(__NR_mq_open+4)
-#define __NR_mq_getsetattr	(__NR_mq_open+5)
-#define __NR_kexec_load		283
-#define __NR_waitid		284
-/* #define __NR_sys_setaltroot	285 */
-#define __NR_add_key		286
-#define __NR_request_key	287
-#define __NR_keyctl		288
-#define __NR_ioprio_set		289
-#define __NR_ioprio_get		290
-#define __NR_inotify_init	291
-#define __NR_inotify_add_watch	292
-#define __NR_inotify_rm_watch	293
-#define __NR_migrate_pages	294
-#define __NR_openat		295
-#define __NR_mkdirat		296
-#define __NR_mknodat		297
-#define __NR_fchownat		298
-#define __NR_futimesat		299
-#define __NR_fstatat64		300
-#define __NR_unlinkat		301
-#define __NR_renameat		302
-#define __NR_linkat		303
-#define __NR_symlinkat		304
-#define __NR_readlinkat		305
-#define __NR_fchmodat		306
-#define __NR_faccessat		307
-#define __NR_pselect6		308
-#define __NR_ppoll		309
-#define __NR_unshare		310
-#define __NR_set_robust_list	311
-#define __NR_get_robust_list	312
-#define __NR_splice		313
-#define __NR_sync_file_range	314
-#define __NR_tee		315
-#define __NR_vmsplice		316
-#define __NR_move_pages		317
-#define __NR_getcpu		318
-#define __NR_epoll_pwait	319
-#define __NR_setns		320
-
-#endif /* _UAPI_ASM_H8300_UNISTD_H_ */
diff --git a/arch/h8300/kernel/Makefile b/arch/h8300/kernel/Makefile
deleted file mode 100644
index 1cc57f8..0000000
--- a/arch/h8300/kernel/Makefile
+++ /dev/null
@@ -1,12 +0,0 @@
-#
-# Makefile for the linux kernel.
-#
-
-extra-y := vmlinux.lds
-
-obj-y := process.o traps.o ptrace.o irq.o \
-	 sys_h8300.o time.o signal.o \
-         setup.o gpio.o syscalls.o \
-	 entry.o timer/
-
-obj-$(CONFIG_MODULES) += module.o h8300_ksyms.o 
diff --git a/arch/h8300/kernel/asm-offsets.c b/arch/h8300/kernel/asm-offsets.c
deleted file mode 100644
index fd961e0..0000000
--- a/arch/h8300/kernel/asm-offsets.c
+++ /dev/null
@@ -1,60 +0,0 @@
-/*
- * This program is used to generate definitions needed by
- * assembly language modules.
- *
- * We use the technique used in the OSF Mach kernel code:
- * generate asm statements containing #defines,
- * compile this file to assembler, and then extract the
- * #defines from the assembly-language output.
- */
-
-#include <linux/stddef.h>
-#include <linux/sched.h>
-#include <linux/kernel_stat.h>
-#include <linux/ptrace.h>
-#include <linux/hardirq.h>
-#include <linux/kbuild.h>
-#include <asm/bootinfo.h>
-#include <asm/irq.h>
-#include <asm/ptrace.h>
-
-int main(void)
-{
-	/* offsets into the task struct */
-	DEFINE(TASK_STATE, offsetof(struct task_struct, state));
-	DEFINE(TASK_FLAGS, offsetof(struct task_struct, flags));
-	DEFINE(TASK_PTRACE, offsetof(struct task_struct, ptrace));
-	DEFINE(TASK_BLOCKED, offsetof(struct task_struct, blocked));
-	DEFINE(TASK_THREAD, offsetof(struct task_struct, thread));
-	DEFINE(TASK_THREAD_INFO, offsetof(struct task_struct, stack));
-	DEFINE(TASK_MM, offsetof(struct task_struct, mm));
-	DEFINE(TASK_ACTIVE_MM, offsetof(struct task_struct, active_mm));
-
-	/* offsets into the irq_cpustat_t struct */
-	DEFINE(CPUSTAT_SOFTIRQ_PENDING, offsetof(irq_cpustat_t, __softirq_pending));
-
-	/* offsets into the thread struct */
-	DEFINE(THREAD_KSP, offsetof(struct thread_struct, ksp));
-	DEFINE(THREAD_USP, offsetof(struct thread_struct, usp));
-	DEFINE(THREAD_CCR, offsetof(struct thread_struct, ccr));
-
-	/* offsets into the pt_regs struct */
-	DEFINE(LER0,  offsetof(struct pt_regs, er0)      - sizeof(long));
-	DEFINE(LER1,  offsetof(struct pt_regs, er1)      - sizeof(long));
-	DEFINE(LER2,  offsetof(struct pt_regs, er2)      - sizeof(long));
-	DEFINE(LER3,  offsetof(struct pt_regs, er3)      - sizeof(long));
-	DEFINE(LER4,  offsetof(struct pt_regs, er4)      - sizeof(long));
-	DEFINE(LER5,  offsetof(struct pt_regs, er5)      - sizeof(long));
-	DEFINE(LER6,  offsetof(struct pt_regs, er6)      - sizeof(long));
-	DEFINE(LORIG, offsetof(struct pt_regs, orig_er0) - sizeof(long));
-	DEFINE(LCCR,  offsetof(struct pt_regs, ccr)      - sizeof(long));
-	DEFINE(LVEC,  offsetof(struct pt_regs, vector)   - sizeof(long));
-#if defined(__H8300S__)
-	DEFINE(LEXR,  offsetof(struct pt_regs, exr)      - sizeof(long));
-#endif
-	DEFINE(LRET,  offsetof(struct pt_regs, pc)       - sizeof(long));
-
-	DEFINE(PT_PTRACED, PT_PTRACED);
-
-	return 0;
-}
diff --git a/arch/h8300/kernel/entry.S b/arch/h8300/kernel/entry.S
deleted file mode 100644
index 94bd30f..0000000
--- a/arch/h8300/kernel/entry.S
+++ /dev/null
@@ -1,402 +0,0 @@
-/* -*- mode: asm -*-
- *
- *  linux/arch/h8300/platform/h8300h/entry.S
- *
- *  Yoshinori Sato <ysato@users.sourceforge.jp>
- *  David McCullough <davidm@snapgear.com>
- *
- */
-
-/*
- *  entry.S
- *  include exception/interrupt gateway
- *          system call entry
- */
-
-#include <linux/sys.h>
-#include <asm/unistd.h>
-#include <asm/setup.h>
-#include <asm/segment.h>
-#include <asm/linkage.h>
-#include <asm/asm-offsets.h>
-#include <asm/thread_info.h>
-#include <asm/errno.h>
-
-#if defined(CONFIG_CPU_H8300H)
-#define USERRET 8
-INTERRUPTS = 64
-	.h8300h
-	.macro	SHLL2 reg
-	shll.l	\reg
-	shll.l	\reg
-	.endm
-	.macro	SHLR2 reg
-	shlr.l	\reg
-	shlr.l	\reg
-	.endm
-	.macro	SAVEREGS
-	mov.l	er0,@-sp
-	mov.l	er1,@-sp
-	mov.l	er2,@-sp
-	mov.l	er3,@-sp
-	.endm
-	.macro	RESTOREREGS
-	mov.l	@sp+,er3
-	mov.l	@sp+,er2
-	.endm
-	.macro	SAVEEXR
-	.endm
-	.macro	RESTOREEXR
-	.endm
-#endif
-#if defined(CONFIG_CPU_H8S)
-#define USERRET 10
-#define USEREXR 8
-INTERRUPTS = 128
-	.h8300s
-	.macro	SHLL2 reg
-	shll.l	#2,\reg
-	.endm
-	.macro	SHLR2 reg
-	shlr.l	#2,\reg
-	.endm
-	.macro	SAVEREGS
-	stm.l	er0-er3,@-sp
-	.endm
-	.macro	RESTOREREGS
-	ldm.l	@sp+,er2-er3
-	.endm
-	.macro	SAVEEXR
-	mov.w	@(USEREXR:16,er0),r1
-	mov.w	r1,@(LEXR-LER3:16,sp)		/* copy EXR */
-	.endm
-	.macro	RESTOREEXR
-	mov.w	@(LEXR-LER1:16,sp),r1		/* restore EXR */
-	mov.b	r1l,r1h
-	mov.w	r1,@(USEREXR:16,er0)
-	.endm
-#endif
-
-
-/* CPU context save/restore macros. */
-
-	.macro	SAVE_ALL
-	mov.l	er0,@-sp
-	stc	ccr,r0l				/* check kernel mode */
-	btst	#4,r0l
-	bne	5f
-
-	/* user mode */
-	mov.l	sp,@_sw_usp
-	mov.l	@sp,er0				/* restore saved er0 */
-	orc	#0x10,ccr			/* switch kernel stack */
-	mov.l	@_sw_ksp,sp
-	sub.l	#(LRET-LORIG),sp		/* allocate LORIG - LRET */
-	SAVEREGS
-	mov.l   @_sw_usp,er0
-	mov.l   @(USERRET:16,er0),er1           /* copy the RET addr */
-	mov.l   er1,@(LRET-LER3:16,sp)
-	SAVEEXR
-
-	mov.l	@(LORIG-LER3:16,sp),er0
-	mov.l	er0,@(LER0-LER3:16,sp)		/* copy ER0 */
-	mov.w	e1,r1				/* e1 highbyte = ccr */
-	and	#0xef,r1h			/* mask mode? flag */
-	bra	6f
-5:
-	/* kernel mode */
-	mov.l	@sp,er0				/* restore saved er0 */
-	subs	#2,sp				/* set dummy ccr */
-	SAVEREGS
-	mov.w	@(LRET-LER3:16,sp),r1		/* copy old ccr */
-6:
-	mov.b	r1h,r1l
-	mov.b	#0,r1h
-	mov.w	r1,@(LCCR-LER3:16,sp)		/* set ccr */
-	mov.l	er6,@-sp			/* syscall arg #6 */
-	mov.l	er5,@-sp			/* syscall arg #5 */
-	mov.l	er4,@-sp			/* syscall arg #4 */
-	.endm					/* r1 = ccr */
-
-	.macro	RESTORE_ALL
-	mov.l	@sp+,er4
-	mov.l	@sp+,er5
-	mov.l	@sp+,er6
-	RESTOREREGS
-	mov.w	@(LCCR-LER1:16,sp),r0		/* check kernel mode */
-	btst	#4,r0l
-	bne	7f
-
-	orc	#0x80,ccr
-	mov.l	@_sw_usp,er0
-	mov.l	@(LER0-LER1:16,sp),er1		/* restore ER0 */
-	mov.l	er1,@er0
-	RESTOREEXR
-	mov.w	@(LCCR-LER1:16,sp),r1		/* restore the RET addr */
-	mov.b	r1l,r1h
-	mov.b	@(LRET+1-LER1:16,sp),r1l
-	mov.w	r1,e1
-	mov.w	@(LRET+2-LER1:16,sp),r1
-	mov.l	er1,@(USERRET:16,er0)
-
-	mov.l	@sp+,er1
-	add.l	#(LRET-LER1),sp			/* remove LORIG - LRET */
-	mov.l	sp,@_sw_ksp
-	andc	#0xef,ccr			/* switch to user mode */
-	mov.l	er0,sp
-	bra	8f
-7:
-	mov.l	@sp+,er1
-	adds	#4,sp
-	adds	#2,sp
-8:
-	mov.l	@sp+,er0
-	adds	#4,sp				/* remove the sw created LVEC */
-	rte
-	.endm
-
-.globl _system_call
-.globl _ret_from_exception
-.globl _ret_from_fork
-.globl _ret_from_kernel_thread
-.globl _ret_from_interrupt
-.globl _interrupt_redirect_table
-.globl _sw_ksp,_sw_usp
-.globl _resume
-.globl _interrupt_entry
-.globl _trace_break
-
-#if defined(CONFIG_ROMKERNEL)
-	.section .int_redirect,"ax"
-_interrupt_redirect_table:
-#if defined(CONFIG_CPU_H8300H)
-	.rept	7
-	.long	0
-	.endr
-#endif
-#if defined(CONFIG_CPU_H8S)
-	.rept	5
-	.long	0
-	.endr
-	jmp	@_trace_break
-	.long	0
-#endif
-
-	jsr	@_interrupt_entry		/* NMI */
-	jmp	@_system_call			/* TRAPA #0 (System call) */
-	.long	0
-	.long	0
-	jmp	@_trace_break			/* TRAPA #3 (breakpoint) */
-	.rept	INTERRUPTS-12
-	jsr	@_interrupt_entry
-	.endr
-#endif
-#if defined(CONFIG_RAMKERNEL)
-.globl _interrupt_redirect_table
-	.section .bss
-_interrupt_redirect_table:
-	.space	4
-#endif
-
-	.section .text
-	.align	2
-_interrupt_entry:
-	SAVE_ALL
-	mov.l	sp,er0
-	add.l	#LVEC,er0
-	btst	#4,r1l
-	bne	1f
-	/* user LVEC */
-	mov.l	@_sw_usp,er0
-	adds	#4,er0
-1:
-	mov.l	@er0,er0			/* LVEC address */
-#if defined(CONFIG_ROMKERNEL)
-	sub.l	#_interrupt_redirect_table,er0
-#endif
-#if defined(CONFIG_RAMKERNEL)
-	mov.l	@_interrupt_redirect_table,er1
-	sub.l	er1,er0
-#endif
-	SHLR2	er0
-	dec.l	#1,er0
-	mov.l	sp,er1
-	subs	#4,er1				/* adjust ret_pc */
-	jsr	@_do_IRQ
-	jmp	@_ret_from_interrupt
-
-_system_call:
-	subs	#4,sp				/* dummy LVEC */
-	SAVE_ALL
-	andc	#0x7f,ccr
-	mov.l	er0,er4
-
-	/* save top of frame */
-	mov.l	sp,er0
-	jsr	@_set_esp0
-	mov.l	sp,er2
-	and.w	#0xe000,r2
-	mov.b	@((TI_FLAGS+3-(TIF_SYSCALL_TRACE >> 3)):16,er2),r2l
-	btst	#(TIF_SYSCALL_TRACE & 7),r2l
-	beq	1f
-	jsr	@_do_syscall_trace
-1:
-	cmp.l	#NR_syscalls,er4
-	bcc	badsys
-	SHLL2	er4
-	mov.l	#_sys_call_table,er0
-	add.l	er4,er0
-	mov.l	@er0,er4
-	beq	_ret_from_exception:16
-	mov.l	@(LER1:16,sp),er0
-	mov.l	@(LER2:16,sp),er1
-	mov.l	@(LER3:16,sp),er2
-	jsr	@er4
-	mov.l	er0,@(LER0:16,sp)		/* save the return value */
-	mov.l	sp,er2
-	and.w	#0xe000,r2
-	mov.b	@((TI_FLAGS+3-(TIF_SYSCALL_TRACE >> 3)):16,er2),r2l
-	btst	#(TIF_SYSCALL_TRACE & 7),r2l
-	beq	2f
-	jsr	@_do_syscall_trace
-2:
-#if defined(CONFIG_SYSCALL_PRINT)
-	jsr	@_syscall_print
-#endif
-	orc	#0x80,ccr
-	bra	resume_userspace
-
-badsys:
-	mov.l	#-ENOSYS,er0
-	mov.l	er0,@(LER0:16,sp)
-	bra	resume_userspace
-
-#if !defined(CONFIG_PREEMPT)
-#define resume_kernel restore_all
-#endif
-
-_ret_from_exception:
-#if defined(CONFIG_PREEMPT)
-	orc	#0x80,ccr
-#endif
-_ret_from_interrupt:
-	mov.b	@(LCCR+1:16,sp),r0l
-	btst	#4,r0l
-	bne	resume_kernel:8		/* return from kernel */
-resume_userspace:
-	andc	#0x7f,ccr
-	mov.l	sp,er4
-	and.w	#0xe000,r4		/* er4 <- current thread info */
-	mov.l	@(TI_FLAGS:16,er4),er1
-	and.l	#_TIF_WORK_MASK,er1
-	beq	restore_all:8
-work_pending:
-	btst	#TIF_NEED_RESCHED,r1l
-	bne	work_resched:8
-	/* work notifysig */
-	mov.l	sp,er0
-	subs	#4,er0			/* er0: pt_regs */
-	jsr	@_do_notify_resume
-	bra	restore_all:8
-work_resched:
-	mov.l	sp,er0
-	jsr	@_set_esp0
-	jsr	@_schedule
-	bra	resume_userspace:8
-restore_all:
-	RESTORE_ALL			/* Does RTE */
-
-#if defined(CONFIG_PREEMPT)
-resume_kernel:
-	mov.l	@(TI_PRE_COUNT:16,er4),er0
-	bne	restore_all:8
-need_resched:
-	mov.l	@(TI_FLAGS:16,er4),er0
-	btst	#TIF_NEED_RESCHED,r0l
-	beq	restore_all:8
-	mov.b	@(LCCR+1:16,sp),r0l	/* Interrupt Enabled? */
-	bmi	restore_all:8
-	mov.l	#PREEMPT_ACTIVE,er0
-	mov.l	er0,@(TI_PRE_COUNT:16,er4)
-	andc	#0x7f,ccr
-	mov.l	sp,er0
-	jsr	@_set_esp0
-	jsr	@_schedule
-	orc	#0x80,ccr
-	bra	need_resched:8
-#endif
-
-_ret_from_fork:
-	mov.l	er2,er0
-	jsr	@_schedule_tail
-	jmp	@_ret_from_exception
-
-_ret_from_kernel_thread:
-	mov.l	er2,er0
-	jsr	@_schedule_tail
-	mov.l	@(LER4:16,sp),er0
-	mov.l	@(LER5:16,sp),er1
-	jsr	@er1
-	jmp	@_ret_from_exception
-
-_resume:
-	/*
-	 * Beware - when entering resume, offset of tss is in d1,
-	 * prev (the current task) is in a0, next (the new task)
-	 * is in a1 and d2.b is non-zero if the mm structure is
-	 * shared between the tasks, so don't change these
-	 * registers until their contents are no longer needed.
-	 */
-
-	/* save sr */
-	sub.w	r3,r3
-	stc	ccr,r3l
-	mov.w	r3,@(THREAD_CCR+2:16,er0)
-
-	/* disable interrupts */
-	orc	#0x80,ccr
-	mov.l	@_sw_usp,er3
-	mov.l	er3,@(THREAD_USP:16,er0)
-	mov.l	sp,@(THREAD_KSP:16,er0)
-
-	/* Skip address space switching if they are the same. */
-	/* FIXME: what did we hack out of here, this does nothing! */
-
-	mov.l	@(THREAD_USP:16,er1),er0
-	mov.l	er0,@_sw_usp
-	mov.l	@(THREAD_KSP:16,er1),sp
-
-	/* restore status register */
-	mov.w	@(THREAD_CCR+2:16,er1),r3
-
-	ldc	r3l,ccr
-	rts
-
-_trace_break:
-	subs	#4,sp
-	SAVE_ALL
-	sub.l	er1,er1
-	dec.l	#1,er1
-	mov.l	er1,@(LORIG,sp)
-	mov.l	sp,er0
-	jsr	@_set_esp0
-	mov.l	@_sw_usp,er0
-	mov.l	@er0,er1
-	mov.w	@(-2:16,er1),r2
-	cmp.w	#0x5730,r2
-	beq	1f
-	subs	#2,er1
-	mov.l	er1,@er0
-1:
-	and.w	#0xff,e1
-	mov.l	er1,er0
-	jsr	@_trace_trap
-	jmp	@_ret_from_exception
-
-	.section	.bss
-_sw_ksp:
-	.space	4
-_sw_usp:
-	.space	4
-
-	.end
diff --git a/arch/h8300/kernel/gpio.c b/arch/h8300/kernel/gpio.c
deleted file mode 100644
index 084bfd0..0000000
--- a/arch/h8300/kernel/gpio.c
+++ /dev/null
@@ -1,178 +0,0 @@
-/*
- *  linux/arch/h8300/kernel/gpio.c
- *
- *  Yoshinori Sato <ysato@users.sourceforge.jp>
- *
- */
-
-/*
- * Internal I/O Port Management
- */
-
-#include <linux/stddef.h>
-#include <linux/proc_fs.h>
-#include <linux/seq_file.h>
-#include <linux/kernel.h>
-#include <linux/string.h>
-#include <linux/fs.h>
-#include <linux/init.h>
-
-#define _(addr) (volatile unsigned char *)(addr)
-#if defined(CONFIG_H83007) || defined(CONFIG_H83068)
-#include <asm/regs306x.h>
-static volatile unsigned char *ddrs[] = {
-	_(P1DDR),_(P2DDR),_(P3DDR),_(P4DDR),_(P5DDR),_(P6DDR),
-	NULL,    _(P8DDR),_(P9DDR),_(PADDR),_(PBDDR),
-};
-#define MAX_PORT 11
-#endif
-
- #if defined(CONFIG_H83002) || defined(CONFIG_H8048)
-/* Fix me!! */
-#include <asm/regs306x.h>
-static volatile unsigned char *ddrs[] = {
-	_(P1DDR),_(P2DDR),_(P3DDR),_(P4DDR),_(P5DDR),_(P6DDR),
-	NULL,    _(P8DDR),_(P9DDR),_(PADDR),_(PBDDR),
-};
-#define MAX_PORT 11
-#endif
-
-#if defined(CONFIG_H8S2678)
-#include <asm/regs267x.h>
-static volatile unsigned char *ddrs[] = {
-	_(P1DDR),_(P2DDR),_(P3DDR),NULL    ,_(P5DDR),_(P6DDR),
-	_(P7DDR),_(P8DDR),NULL,    _(PADDR),_(PBDDR),_(PCDDR),
-	_(PDDDR),_(PEDDR),_(PFDDR),_(PGDDR),_(PHDDR),
-	_(PADDR),_(PBDDR),_(PCDDR),_(PDDDR),_(PEDDR),_(PFDDR),
-	_(PGDDR),_(PHDDR)
-};
-#define MAX_PORT 17
-#endif
-#undef _
- 
-#if !defined(P1DDR)
-#error Unsuppoted CPU Selection
-#endif
-
-static struct {
-	unsigned char used;
-	unsigned char ddr;
-} gpio_regs[MAX_PORT];
-
-extern char *_platform_gpio_table(int length);
-
-int h8300_reserved_gpio(int port, unsigned int bits)
-{
-	unsigned char *used;
-
-	if (port < 0 || port >= MAX_PORT)
-		return -1;
-	used = &(gpio_regs[port].used);
-	if ((*used & bits) != 0)
-		return 0;
-	*used |= bits;
-	return 1;
-}
-
-int h8300_free_gpio(int port, unsigned int bits)
-{
-	unsigned char *used;
-
-	if (port < 0 || port >= MAX_PORT)
-		return -1;
-	used = &(gpio_regs[port].used);
-	if ((*used & bits) != bits)
-		return 0;
-	*used &= (~bits);
-	return 1;
-}
-
-int h8300_set_gpio_dir(int port_bit,int dir)
-{
-	int port = (port_bit >> 8) & 0xff;
-	int bit  = port_bit & 0xff;
-
-	if (ddrs[port] == NULL)
-		return 0;
-	if (gpio_regs[port].used & bit) {
-		if (dir)
-			gpio_regs[port].ddr |= bit;
-		else
-			gpio_regs[port].ddr &= ~bit;
-		*ddrs[port] = gpio_regs[port].ddr;
-		return 1;
-	} else
-		return 0;
-}
-
-int h8300_get_gpio_dir(int port_bit)
-{
-	int port = (port_bit >> 8) & 0xff;
-	int bit  = port_bit & 0xff;
-
-	if (ddrs[port] == NULL)
-		return 0;
-	if (gpio_regs[port].used & bit) {
-		return (gpio_regs[port].ddr & bit) != 0;
-	} else
-		return -1;
-}
-
-#if defined(CONFIG_PROC_FS)
-static char *port_status(int portno)
-{
-	static char result[10];
-	static const char io[2]={'I','O'};
-	char *rp;
-	int c;
-	unsigned char used,ddr;
-	
-	used = gpio_regs[portno].used;
-	ddr  = gpio_regs[portno].ddr;
-	result[8]='\0';
-	rp = result + 7;
-	for (c = 8; c > 0; c--,rp--,used >>= 1, ddr >>= 1)
-		if (used & 0x01)
-			*rp = io[ ddr & 0x01];
-		else	
-			*rp = '-';
-	return result;
-}
-
-static int gpio_proc_show(struct seq_file *m, void *v)
-{
-	static const char port_name[]="123456789ABCDEFGH";
-	int c;
-
-	for (c = 0; c < MAX_PORT; c++) {
-		if (ddrs[c] == NULL)
-			continue;
-		seq_printf(m, "P%c: %s\n", port_name[c], port_status(c));
-	}
-	return 0;
-}
-
-static int gpio_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, gpio_proc_show, PDE_DATA(inode));
-}
-
-static const struct file_operations gpio_proc_fops = {
-	.open		= gpio_proc_open,
-	.read		= seq_read,
-	.llseek		= seq_lseek,
-	.release	= single_release,
-};
-
-static __init int register_proc(void)
-{
-	return proc_create("gpio", S_IRUGO, NULL, &gpio_proc_fops) != NULL;
-}
-
-__initcall(register_proc);
-#endif
-
-void __init h8300_gpio_init(void)
-{
-	memcpy(gpio_regs,_platform_gpio_table(sizeof(gpio_regs)),sizeof(gpio_regs));
-}
diff --git a/arch/h8300/kernel/h8300_ksyms.c b/arch/h8300/kernel/h8300_ksyms.c
deleted file mode 100644
index 53d7c0e..0000000
--- a/arch/h8300/kernel/h8300_ksyms.c
+++ /dev/null
@@ -1,100 +0,0 @@
-#include <linux/module.h>
-#include <linux/linkage.h>
-#include <linux/sched.h>
-#include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/user.h>
-#include <linux/elfcore.h>
-#include <linux/in6.h>
-#include <linux/interrupt.h>
-
-#include <asm/setup.h>
-#include <asm/pgalloc.h>
-#include <asm/irq.h>
-#include <asm/io.h>
-#include <asm/checksum.h>
-#include <asm/current.h>
-#include <asm/gpio.h>
-
-//asmlinkage long long __ashrdi3 (long long, int);
-//asmlinkage long long __lshrdi3 (long long, int);
-extern char h8300_debug_device[];
-
-/* platform dependent support */
-
-EXPORT_SYMBOL(strnlen);
-EXPORT_SYMBOL(strrchr);
-EXPORT_SYMBOL(strstr);
-EXPORT_SYMBOL(strchr);
-EXPORT_SYMBOL(strcat);
-EXPORT_SYMBOL(strlen);
-EXPORT_SYMBOL(strcmp);
-EXPORT_SYMBOL(strncmp);
-
-EXPORT_SYMBOL(ip_fast_csum);
-
-EXPORT_SYMBOL(enable_irq);
-EXPORT_SYMBOL(disable_irq);
-
-/* Networking helper routines. */
-EXPORT_SYMBOL(csum_partial_copy_nocheck);
-
-/* The following are special because they're not called
-   explicitly (the C compiler generates them).  Fortunately,
-   their interface isn't gonna change any time soon now, so
-   it's OK to leave it out of version control.  */
-//EXPORT_SYMBOL(__ashrdi3);
-//EXPORT_SYMBOL(__lshrdi3);
-EXPORT_SYMBOL(memcpy);
-EXPORT_SYMBOL(memset);
-EXPORT_SYMBOL(memcmp);
-EXPORT_SYMBOL(memscan);
-EXPORT_SYMBOL(memmove);
-
-/*
- * libgcc functions - functions that are used internally by the
- * compiler...  (prototypes are not correct though, but that
- * doesn't really matter since they're not versioned).
- */
-extern void __gcc_bcmp(void);
-extern void __ashldi3(void);
-extern void __ashrdi3(void);
-extern void __cmpdi2(void);
-extern void __divdi3(void);
-extern void __divsi3(void);
-extern void __lshrdi3(void);
-extern void __moddi3(void);
-extern void __modsi3(void);
-extern void __muldi3(void);
-extern void __mulsi3(void);
-extern void __negdi2(void);
-extern void __ucmpdi2(void);
-extern void __udivdi3(void);
-extern void __udivmoddi4(void);
-extern void __udivsi3(void);
-extern void __umoddi3(void);
-extern void __umodsi3(void);
-
-        /* gcc lib functions */
-EXPORT_SYMBOL(__gcc_bcmp);
-EXPORT_SYMBOL(__ashldi3);
-EXPORT_SYMBOL(__ashrdi3);
-EXPORT_SYMBOL(__cmpdi2);
-EXPORT_SYMBOL(__divdi3);
-EXPORT_SYMBOL(__divsi3);
-EXPORT_SYMBOL(__lshrdi3);
-EXPORT_SYMBOL(__moddi3);
-EXPORT_SYMBOL(__modsi3);
-EXPORT_SYMBOL(__muldi3);
-EXPORT_SYMBOL(__mulsi3);
-EXPORT_SYMBOL(__negdi2);
-EXPORT_SYMBOL(__ucmpdi2);
-EXPORT_SYMBOL(__udivdi3);
-EXPORT_SYMBOL(__udivmoddi4);
-EXPORT_SYMBOL(__udivsi3);
-EXPORT_SYMBOL(__umoddi3);
-EXPORT_SYMBOL(__umodsi3);
-
-EXPORT_SYMBOL(h8300_reserved_gpio);
-EXPORT_SYMBOL(h8300_free_gpio);
-EXPORT_SYMBOL(h8300_set_gpio_dir);
diff --git a/arch/h8300/kernel/irq.c b/arch/h8300/kernel/irq.c
deleted file mode 100644
index 2fa8ac7..0000000
--- a/arch/h8300/kernel/irq.c
+++ /dev/null
@@ -1,165 +0,0 @@
-/*
- * linux/arch/h8300/kernel/irq.c
- *
- * Copyright 2007 Yoshinori Sato <ysato@users.sourceforge.jp>
- */
-
-#include <linux/module.h>
-#include <linux/types.h>
-#include <linux/kernel.h>
-#include <linux/sched.h>
-#include <linux/kernel_stat.h>
-#include <linux/seq_file.h>
-#include <linux/init.h>
-#include <linux/random.h>
-#include <linux/bootmem.h>
-#include <linux/irq.h>
-#include <linux/interrupt.h>
-
-#include <asm/traps.h>
-#include <asm/io.h>
-#include <asm/setup.h>
-#include <asm/errno.h>
-
-/*#define DEBUG*/
-
-extern unsigned long *interrupt_redirect_table;
-extern const int h8300_saved_vectors[];
-extern const h8300_vector h8300_trap_table[];
-int h8300_enable_irq_pin(unsigned int irq);
-void h8300_disable_irq_pin(unsigned int irq);
-
-#define CPU_VECTOR ((unsigned long *)0x000000)
-#define ADDR_MASK (0xffffff)
-
-static inline int is_ext_irq(unsigned int irq)
-{
-	return (irq >= EXT_IRQ0 && irq <= (EXT_IRQ0 + EXT_IRQS));
-}
-
-static void h8300_enable_irq(struct irq_data *data)
-{
-	if (is_ext_irq(data->irq))
-		IER_REGS |= 1 << (data->irq - EXT_IRQ0);
-}
-
-static void h8300_disable_irq(struct irq_data *data)
-{
-	if (is_ext_irq(data->irq))
-		IER_REGS &= ~(1 << (data->irq - EXT_IRQ0));
-}
-
-static unsigned int h8300_startup_irq(struct irq_data *data)
-{
-	if (is_ext_irq(data->irq))
-		return h8300_enable_irq_pin(data->irq);
-	else
-		return 0;
-}
-
-static void h8300_shutdown_irq(struct irq_data *data)
-{
-	if (is_ext_irq(data->irq))
-		h8300_disable_irq_pin(data->irq);
-}
-
-/*
- * h8300 interrupt controller implementation
- */
-struct irq_chip h8300irq_chip = {
-	.name		= "H8300-INTC",
-	.irq_startup	= h8300_startup_irq,
-	.irq_shutdown	= h8300_shutdown_irq,
-	.irq_enable	= h8300_enable_irq,
-	.irq_disable	= h8300_disable_irq,
-};
-
-#if defined(CONFIG_RAMKERNEL)
-static unsigned long __init *get_vector_address(void)
-{
-	unsigned long *rom_vector = CPU_VECTOR;
-	unsigned long base,tmp;
-	int vec_no;
-
-	base = rom_vector[EXT_IRQ0] & ADDR_MASK;
-
-	/* check romvector format */
-	for (vec_no = EXT_IRQ1; vec_no <= EXT_IRQ0+EXT_IRQS; vec_no++) {
-		if ((base+(vec_no - EXT_IRQ0)*4) != (rom_vector[vec_no] & ADDR_MASK))
-			return NULL;
-	}
-
-	/* ramvector base address */
-	base -= EXT_IRQ0*4;
-
-	/* writerble check */
-	tmp = ~(*(volatile unsigned long *)base);
-	(*(volatile unsigned long *)base) = tmp;
-	if ((*(volatile unsigned long *)base) != tmp)
-		return NULL;
-	return (unsigned long *)base;
-}
-
-static void __init setup_vector(void)
-{
-	int i;
-	unsigned long *ramvec,*ramvec_p;
-	const h8300_vector *trap_entry;
-	const int *saved_vector;
-
-	ramvec = get_vector_address();
-	if (ramvec == NULL)
-		panic("interrupt vector serup failed.");
-	else
-		printk(KERN_INFO "virtual vector at 0x%08lx\n",(unsigned long)ramvec);
-
-	/* create redirect table */
-	ramvec_p = ramvec;
-	trap_entry = h8300_trap_table;
-	saved_vector = h8300_saved_vectors;
-	for ( i = 0; i < NR_IRQS; i++) {
-		if (i == *saved_vector) {
-			ramvec_p++;
-			saved_vector++;
-		} else {
-			if ( i < NR_TRAPS ) {
-				if (*trap_entry)
-					*ramvec_p = VECTOR(*trap_entry);
-				ramvec_p++;
-				trap_entry++;
-			} else
-				*ramvec_p++ = REDIRECT(interrupt_entry);
-		}
-	}
-	interrupt_redirect_table = ramvec;
-#ifdef DEBUG
-	ramvec_p = ramvec;
-	for (i = 0; i < NR_IRQS; i++) {
-		if ((i % 8) == 0)
-			printk(KERN_DEBUG "\n%p: ",ramvec_p);
-		printk(KERN_DEBUG "%p ",*ramvec_p);
-		ramvec_p++;
-	}
-	printk(KERN_DEBUG "\n");
-#endif
-}
-#else
-#define setup_vector() do { } while(0)
-#endif
-
-void __init init_IRQ(void)
-{
-	int c;
-
-	setup_vector();
-
-	for (c = 0; c < NR_IRQS; c++)
-		irq_set_chip_and_handler(c, &h8300irq_chip, handle_simple_irq);
-}
-
-asmlinkage void do_IRQ(int irq)
-{
-	irq_enter();
-	generic_handle_irq(irq);
-	irq_exit();
-}
diff --git a/arch/h8300/kernel/module.c b/arch/h8300/kernel/module.c
deleted file mode 100644
index 1d526e0..0000000
--- a/arch/h8300/kernel/module.c
+++ /dev/null
@@ -1,75 +0,0 @@
-#include <linux/moduleloader.h>
-#include <linux/elf.h>
-#include <linux/vmalloc.h>
-#include <linux/fs.h>
-#include <linux/string.h>
-#include <linux/kernel.h>
-
-#if 0
-#define DEBUGP printk
-#else
-#define DEBUGP(fmt...)
-#endif
-
-int apply_relocate_add(Elf32_Shdr *sechdrs,
-		       const char *strtab,
-		       unsigned int symindex,
-		       unsigned int relsec,
-		       struct module *me)
-{
-	unsigned int i;
-	Elf32_Rela *rela = (void *)sechdrs[relsec].sh_addr;
-
-	DEBUGP("Applying relocate section %u to %u\n", relsec,
-	       sechdrs[relsec].sh_info);
-	for (i = 0; i < sechdrs[relsec].sh_size / sizeof(*rela); i++) {
-		/* This is where to make the change */
-		uint32_t *loc = (uint32_t *)(sechdrs[sechdrs[relsec].sh_info].sh_addr
-					     + rela[i].r_offset);
-		/* This is the symbol it is referring to.  Note that all
-		   undefined symbols have been resolved.  */
-		Elf32_Sym *sym = (Elf32_Sym *)sechdrs[symindex].sh_addr
-			+ ELF32_R_SYM(rela[i].r_info);
-		uint32_t v = sym->st_value + rela[i].r_addend;
-
-		switch (ELF32_R_TYPE(rela[i].r_info)) {
-		case R_H8_DIR24R8:
-			loc = (uint32_t *)((uint32_t)loc - 1);
-			*loc = (*loc & 0xff000000) | ((*loc & 0xffffff) + v);
-			break;
-		case R_H8_DIR24A8:
-			if (ELF32_R_SYM(rela[i].r_info))
-				*loc += v;
-			break;
-		case R_H8_DIR32:
-		case R_H8_DIR32A16:
-			*loc += v;
-			break;
-		case R_H8_PCREL16:
-			v -= (unsigned long)loc + 2;
-			if ((Elf32_Sword)v > 0x7fff || 
-			    (Elf32_Sword)v < -(Elf32_Sword)0x8000)
-				goto overflow;
-			else 
-				*(unsigned short *)loc = v;
-			break;
-		case R_H8_PCREL8:
-			v -= (unsigned long)loc + 1;
-			if ((Elf32_Sword)v > 0x7f || 
-			    (Elf32_Sword)v < -(Elf32_Sword)0x80)
-				goto overflow;
-			else 
-				*(unsigned char *)loc = v;
-			break;
-		default:
-			printk(KERN_ERR "module %s: Unknown relocation: %u\n",
-			       me->name, ELF32_R_TYPE(rela[i].r_info));
-			return -ENOEXEC;
-		}
-	}
-	return 0;
- overflow:
-	printk(KERN_ERR "module %s: relocation offset overflow: %08x\n",
-	       me->name, rela[i].r_offset);
-	return -ENOEXEC;
-}
diff --git a/arch/h8300/kernel/process.c b/arch/h8300/kernel/process.c
deleted file mode 100644
index 1a744ab..0000000
--- a/arch/h8300/kernel/process.c
+++ /dev/null
@@ -1,154 +0,0 @@
-/*
- *  linux/arch/h8300/kernel/process.c
- *
- * Yoshinori Sato <ysato@users.sourceforge.jp>
- *
- *  Based on:
- *
- *  linux/arch/m68knommu/kernel/process.c
- *
- *  Copyright (C) 1998  D. Jeff Dionne <jeff@ryeham.ee.ryerson.ca>,
- *                      Kenneth Albanowski <kjahds@kjahds.com>,
- *                      The Silver Hammer Group, Ltd.
- *
- *  linux/arch/m68k/kernel/process.c
- *
- *  Copyright (C) 1995  Hamish Macdonald
- *
- *  68060 fixes by Jesper Skov
- */
-
-/*
- * This file handles the architecture-dependent parts of process handling..
- */
-
-#include <linux/errno.h>
-#include <linux/module.h>
-#include <linux/sched.h>
-#include <linux/kernel.h>
-#include <linux/mm.h>
-#include <linux/smp.h>
-#include <linux/stddef.h>
-#include <linux/unistd.h>
-#include <linux/ptrace.h>
-#include <linux/user.h>
-#include <linux/interrupt.h>
-#include <linux/reboot.h>
-#include <linux/fs.h>
-#include <linux/slab.h>
-#include <linux/rcupdate.h>
-
-#include <asm/uaccess.h>
-#include <asm/traps.h>
-#include <asm/setup.h>
-#include <asm/pgtable.h>
-
-void (*pm_power_off)(void) = NULL;
-EXPORT_SYMBOL(pm_power_off);
-
-asmlinkage void ret_from_fork(void);
-asmlinkage void ret_from_kernel_thread(void);
-
-/*
- * The idle loop on an H8/300..
- */
-#if !defined(CONFIG_H8300H_SIM) && !defined(CONFIG_H8S_SIM)
-void arch_cpu_idle(void)
-{
-	local_irq_enable();
-	/* XXX: race here! What if need_resched() gets set now? */
-	__asm__("sleep");
-}
-#endif
-
-void machine_restart(char * __unused)
-{
-	local_irq_disable();
-	__asm__("jmp @@0"); 
-}
-
-void machine_halt(void)
-{
-	local_irq_disable();
-	__asm__("sleep");
-	for (;;);
-}
-
-void machine_power_off(void)
-{
-	local_irq_disable();
-	__asm__("sleep");
-	for (;;);
-}
-
-void show_regs(struct pt_regs * regs)
-{
-	show_regs_print_info(KERN_DEFAULT);
-
-	printk("\nPC: %08lx  Status: %02x",
-	       regs->pc, regs->ccr);
-	printk("\nORIG_ER0: %08lx ER0: %08lx ER1: %08lx",
-	       regs->orig_er0, regs->er0, regs->er1);
-	printk("\nER2: %08lx ER3: %08lx ER4: %08lx ER5: %08lx",
-	       regs->er2, regs->er3, regs->er4, regs->er5);
-	printk("\nER6' %08lx ",regs->er6);
-	if (user_mode(regs))
-		printk("USP: %08lx\n", rdusp());
-	else
-		printk("\n");
-}
-
-void flush_thread(void)
-{
-}
-
-int copy_thread(unsigned long clone_flags,
-                unsigned long usp, unsigned long topstk,
-		 struct task_struct * p)
-{
-	struct pt_regs * childregs;
-
-	childregs = (struct pt_regs *) (THREAD_SIZE + task_stack_page(p)) - 1;
-
-	if (unlikely(p->flags & PF_KTHREAD)) {
-		memset(childregs, 0, sizeof(struct pt_regs));
-		childregs->retpc = (unsigned long) ret_from_kernel_thread;
-		childregs->er4 = topstk; /* arg */
-		childregs->er5 = usp; /* fn */
-		p->thread.ksp = (unsigned long)childregs;
-	}
-	*childregs = *current_pt_regs();
-	childregs->retpc = (unsigned long) ret_from_fork;
-	childregs->er0 = 0;
-	p->thread.usp = usp ?: rdusp();
-	p->thread.ksp = (unsigned long)childregs;
-
-	return 0;
-}
-
-unsigned long thread_saved_pc(struct task_struct *tsk)
-{
-	return ((struct pt_regs *)tsk->thread.esp0)->pc;
-}
-
-unsigned long get_wchan(struct task_struct *p)
-{
-	unsigned long fp, pc;
-	unsigned long stack_page;
-	int count = 0;
-	if (!p || p == current || p->state == TASK_RUNNING)
-		return 0;
-
-	stack_page = (unsigned long)p;
-	fp = ((struct pt_regs *)p->thread.ksp)->er6;
-	do {
-		if (fp < stack_page+sizeof(struct thread_info) ||
-		    fp >= 8184+stack_page)
-			return 0;
-		pc = ((unsigned long *)fp)[1];
-		if (!in_sched_functions(pc))
-			return pc;
-		fp = *(unsigned long *) fp;
-	} while (count++ < 16);
-	return 0;
-}
diff --git a/arch/h8300/kernel/ptrace.c b/arch/h8300/kernel/ptrace.c
deleted file mode 100644
index 748cf65..0000000
--- a/arch/h8300/kernel/ptrace.c
+++ /dev/null
@@ -1,168 +0,0 @@
-/*
- *  linux/arch/h8300/kernel/ptrace.c
- *
- *  Yoshinori Sato <ysato@users.sourceforge.jp>
- *
- *  Based on:
- *  linux/arch/m68k/kernel/ptrace.c
- *
- *  Copyright (C) 1994 by Hamish Macdonald
- *  Taken from linux/kernel/ptrace.c and modified for M680x0.
- *  linux/kernel/ptrace.c is by Ross Biro 1/23/92, edited by Linus Torvalds
- *
- * This file is subject to the terms and conditions of the GNU General
- * Public License.  See the file COPYING in the main directory of
- * this archive for more details.
- */
-
-#include <linux/kernel.h>
-#include <linux/sched.h>
-#include <linux/mm.h>
-#include <linux/smp.h>
-#include <linux/errno.h>
-#include <linux/ptrace.h>
-#include <linux/user.h>
-#include <linux/signal.h>
-
-#include <asm/uaccess.h>
-#include <asm/page.h>
-#include <asm/pgtable.h>
-#include <asm/processor.h>
-#include <asm/signal.h>
-
-/* cpu depend functions */
-extern long h8300_get_reg(struct task_struct *task, int regno);
-extern int  h8300_put_reg(struct task_struct *task, int regno, unsigned long data);
-
-
-void user_disable_single_step(struct task_struct *child)
-{
-}
-
-/*
- * does not yet catch signals sent when the child dies.
- * in exit.c or in signal.c.
- */
-
-void ptrace_disable(struct task_struct *child)
-{
-	user_disable_single_step(child);
-}
-
-long arch_ptrace(struct task_struct *child, long request,
-		 unsigned long addr, unsigned long data)
-{
-	int ret;
-	int regno = addr >> 2;
-	unsigned long __user *datap = (unsigned long __user *) data;
-
-	switch (request) {
-	/* read the word at location addr in the USER area. */
-		case PTRACE_PEEKUSR: {
-			unsigned long tmp = 0;
-			
-			if ((addr & 3) || addr >= sizeof(struct user)) {
-				ret = -EIO;
-				break ;
-			}
-			
-		        ret = 0;  /* Default return condition */
-
-			if (regno < H8300_REGS_NO)
-				tmp = h8300_get_reg(child, regno);
-			else {
-				switch (regno) {
-				case 49:
-					tmp = child->mm->start_code;
-					break ;
-				case 50:
-					tmp = child->mm->start_data;
-					break ;
-				case 51:
-					tmp = child->mm->end_code;
-					break ;
-				case 52:
-					tmp = child->mm->end_data;
-					break ;
-				default:
-					ret = -EIO;
-				}
-			}
-			if (!ret)
-				ret = put_user(tmp, datap);
-			break ;
-		}
-
-      /* when I and D space are separate, this will have to be fixed. */
-		case PTRACE_POKEUSR: /* write the word at location addr in the USER area */
-			if ((addr & 3) || addr >= sizeof(struct user)) {
-				ret = -EIO;
-				break ;
-			}
-			    
-			if (regno == PT_ORIG_ER0) {
-				ret = -EIO;
-				break ;
-			}
-			if (regno < H8300_REGS_NO) {
-				ret = h8300_put_reg(child, regno, data);
-				break ;
-			}
-			ret = -EIO;
-			break ;
-
-		case PTRACE_GETREGS: { /* Get all gp regs from the child. */
-		  	int i;
-			unsigned long tmp;
-			for (i = 0; i < H8300_REGS_NO; i++) {
-			    tmp = h8300_get_reg(child, i);
-			    if (put_user(tmp, datap)) {
-				ret = -EFAULT;
-				break;
-			    }
-			    datap++;
-			}
-			ret = 0;
-			break;
-		}
-
-		case PTRACE_SETREGS: { /* Set all gp regs in the child. */
-			int i;
-			unsigned long tmp;
-			for (i = 0; i < H8300_REGS_NO; i++) {
-			    if (get_user(tmp, datap)) {
-				ret = -EFAULT;
-				break;
-			    }
-			    h8300_put_reg(child, i, tmp);
-			    datap++;
-			}
-			ret = 0;
-			break;
-		}
-
-		default:
-			ret = ptrace_request(child, request, addr, data);
-			break;
-	}
-	return ret;
-}
-
-asmlinkage void do_syscall_trace(void)
-{
-	if (!test_thread_flag(TIF_SYSCALL_TRACE))
-		return;
-	if (!(current->ptrace & PT_PTRACED))
-		return;
-	ptrace_notify(SIGTRAP | ((current->ptrace & PT_TRACESYSGOOD)
-				 ? 0x80 : 0));
-	/*
-	 * this isn't the same as continuing with a signal, but it will do
-	 * for normal use.  strace only continues with a signal if the
-	 * stopping signal is not SIGTRAP.  -brl
-	 */
-	if (current->exit_code) {
-		send_sig(current->exit_code, current, 1);
-		current->exit_code = 0;
-	}
-}
diff --git a/arch/h8300/kernel/setup.c b/arch/h8300/kernel/setup.c
deleted file mode 100644
index d0b1607..0000000
--- a/arch/h8300/kernel/setup.c
+++ /dev/null
@@ -1,242 +0,0 @@
-/*
- *  linux/arch/h8300/kernel/setup.c
- *
- *  Copyleft  ()) 2000       James D. Schettine {james@telos-systems.com}
- *  Copyright (C) 1999,2000  Greg Ungerer (gerg@snapgear.com)
- *  Copyright (C) 1998,1999  D. Jeff Dionne <jeff@lineo.ca>
- *  Copyright (C) 1998       Kenneth Albanowski <kjahds@kjahds.com>
- *  Copyright (C) 1995       Hamish Macdonald
- *  Copyright (C) 2000       Lineo Inc. (www.lineo.com) 
- *  Copyright (C) 2001 	     Lineo, Inc. <www.lineo.com>
- *
- *  H8/300 porting Yoshinori Sato <ysato@users.sourceforge.jp>
- */
-
-/*
- * This file handles the architecture-dependent parts of system setup
- */
-
-#include <linux/kernel.h>
-#include <linux/sched.h>
-#include <linux/delay.h>
-#include <linux/interrupt.h>
-#include <linux/mm.h>
-#include <linux/fs.h>
-#include <linux/fb.h>
-#include <linux/console.h>
-#include <linux/genhd.h>
-#include <linux/errno.h>
-#include <linux/string.h>
-#include <linux/major.h>
-#include <linux/bootmem.h>
-#include <linux/seq_file.h>
-#include <linux/init.h>
-
-#include <asm/setup.h>
-#include <asm/irq.h>
-#include <asm/pgtable.h>
-#include <asm/sections.h>
-
-#if defined(__H8300H__)
-#define CPU "H8/300H"
-#include <asm/regs306x.h>
-#endif
-
-#if defined(__H8300S__)
-#define CPU "H8S"
-#include <asm/regs267x.h>
-#endif
-
-#define STUBSIZE 0xc000
-
-unsigned long rom_length;
-unsigned long memory_start;
-unsigned long memory_end;
-
-char __initdata command_line[COMMAND_LINE_SIZE];
-
-extern int _ramstart, _ramend;
-extern char _target_name[];
-extern void h8300_gpio_init(void);
-
-#if (defined(CONFIG_H8300H_SIM) || defined(CONFIG_H8S_SIM)) \
-    && defined(CONFIG_GDB_MAGICPRINT)
-/* printk with gdb service */
-static void gdb_console_output(struct console *c, const char *msg, unsigned len)
-{
-	for (; len > 0; len--) {
-		asm("mov.w %0,r2\n\t"
-                    "jsr @0xc4"::"r"(*msg++):"er2");
-	}
-}
-
-/*
- *	Setup initial baud/bits/parity. We do two things here:
- *	- construct a cflag setting for the first rs_open()
- *	- initialize the serial port
- *	Return non-zero if we didn't find a serial port.
- */
-static int __init gdb_console_setup(struct console *co, char *options)
-{
-	return 0;
-}
-
-static const struct console gdb_console = {
-	.name		= "gdb_con",
-	.write		= gdb_console_output,
-	.device		= NULL,
-	.setup		= gdb_console_setup,
-	.flags		= CON_PRINTBUFFER,
-	.index		= -1,
-};
-#endif
-
-void __init setup_arch(char **cmdline_p)
-{
-	int bootmap_size;
-
-	memory_start = (unsigned long) &_ramstart;
-
-	/* allow for ROMFS on the end of the kernel */
-	if (memcmp((void *)memory_start, "-rom1fs-", 8) == 0) {
-#if defined(CONFIG_BLK_DEV_INITRD)
-		initrd_start = memory_start;
-		initrd_end = memory_start += be32_to_cpu(((unsigned long *) (memory_start))[2]);
-#else
-		memory_start += be32_to_cpu(((unsigned long *) memory_start)[2]);
-#endif
-	}
-	memory_start = PAGE_ALIGN(memory_start);
-#if !defined(CONFIG_BLKDEV_RESERVE)
-	memory_end = (unsigned long) &_ramend; /* by now the stack is part of the init task */
-#if defined(CONFIG_GDB_DEBUG)
-	memory_end -= STUBSIZE;
-#endif
-#else
-	if ((memory_end < CONFIG_BLKDEV_RESERVE_ADDRESS) && 
-	    (memory_end > CONFIG_BLKDEV_RESERVE_ADDRESS))
-	    /* overlap userarea */
-	    memory_end = CONFIG_BLKDEV_RESERVE_ADDRESS; 
-#endif
-
-	init_mm.start_code = (unsigned long) _stext;
-	init_mm.end_code = (unsigned long) _etext;
-	init_mm.end_data = (unsigned long) _edata;
-	init_mm.brk = (unsigned long) 0; 
-
-#if (defined(CONFIG_H8300H_SIM) || defined(CONFIG_H8S_SIM)) && defined(CONFIG_GDB_MAGICPRINT)
-	register_console((struct console *)&gdb_console);
-#endif
-
-	printk(KERN_INFO "\r\n\nuClinux " CPU "\n");
-	printk(KERN_INFO "Target Hardware: %s\n",_target_name);
-	printk(KERN_INFO "Flat model support (C) 1998,1999 Kenneth Albanowski, D. Jeff Dionne\n");
-	printk(KERN_INFO "H8/300 series support by Yoshinori Sato <ysato@users.sourceforge.jp>\n");
-
-#ifdef DEBUG
-	printk(KERN_DEBUG "KERNEL -> TEXT=0x%p-0x%p DATA=0x%p-0x%p "
-		"BSS=0x%p-0x%p\n", _stext, _etext, _sdata, _edata, __bss_start,
-		__bss_stop);
-	printk(KERN_DEBUG "KERNEL -> ROMFS=0x%p-0x%06lx MEM=0x%06lx-0x%06lx "
-		"STACK=0x%06lx-0x%p\n", __bss_stop, memory_start, memory_start,
-		memory_end, memory_end, &_ramend);
-#endif
-
-#ifdef CONFIG_DEFAULT_CMDLINE
-	/* set from default command line */
-	if (*command_line == '\0')
-		strcpy(command_line,CONFIG_KERNEL_COMMAND);
-#endif
-	/* Keep a copy of command line */
-	*cmdline_p = &command_line[0];
-	memcpy(boot_command_line, command_line, COMMAND_LINE_SIZE);
-	boot_command_line[COMMAND_LINE_SIZE-1] = 0;
-
-#ifdef DEBUG
-	if (strlen(*cmdline_p)) 
-		printk(KERN_DEBUG "Command line: '%s'\n", *cmdline_p);
-#endif
-
-	/*
-	 * give all the memory to the bootmap allocator,  tell it to put the
-	 * boot mem_map at the start of memory
-	 */
-	bootmap_size = init_bootmem_node(
-			NODE_DATA(0),
-			memory_start >> PAGE_SHIFT, /* map goes here */
-			PAGE_OFFSET >> PAGE_SHIFT,	/* 0 on coldfire */
-			memory_end >> PAGE_SHIFT);
-	/*
-	 * free the usable memory,  we have to make sure we do not free
-	 * the bootmem bitmap so we then reserve it after freeing it :-)
-	 */
-	free_bootmem(memory_start, memory_end - memory_start);
-	reserve_bootmem(memory_start, bootmap_size, BOOTMEM_DEFAULT);
-	/*
-	 * get kmalloc into gear
-	 */
-	paging_init();
-	h8300_gpio_init();
-#if defined(CONFIG_H8300_AKI3068NET) && defined(CONFIG_IDE)
-	{
-#define AREABIT(addr) (1 << (((addr) >> 21) & 7))
-		/* setup BSC */
-		volatile unsigned char *abwcr = (volatile unsigned char *)ABWCR;
-		volatile unsigned char *cscr = (volatile unsigned char *)CSCR;
-		*abwcr &= ~(AREABIT(CONFIG_H8300_IDE_BASE) | AREABIT(CONFIG_H8300_IDE_ALT));
-		*cscr  |= (AREABIT(CONFIG_H8300_IDE_BASE) | AREABIT(CONFIG_H8300_IDE_ALT)) | 0x0f;
-	}
-#endif
-#ifdef DEBUG
-	printk(KERN_DEBUG "Done setup_arch\n");
-#endif
-}
-
-/*
- *	Get CPU information for use by the procfs.
- */
-
-static int show_cpuinfo(struct seq_file *m, void *v)
-{
-    char *cpu;
-    int mode;
-    u_long clockfreq;
-
-    cpu = CPU;
-    mode = *(volatile unsigned char *)MDCR & 0x07;
-
-    clockfreq = CONFIG_CPU_CLOCK;
-
-    seq_printf(m,  "CPU:\t\t%s (mode:%d)\n"
-		   "Clock:\t\t%lu.%1luMHz\n"
-		   "BogoMips:\t%lu.%02lu\n"
-		   "Calibration:\t%lu loops\n",
-	           cpu,mode,
-		   clockfreq/1000,clockfreq%1000,
-		   (loops_per_jiffy*HZ)/500000,((loops_per_jiffy*HZ)/5000)%100,
-		   (loops_per_jiffy*HZ));
-
-    return 0;
-}
-
-static void *c_start(struct seq_file *m, loff_t *pos)
-{
-	return *pos < NR_CPUS ? ((void *) 0x12345678) : NULL;
-}
-
-static void *c_next(struct seq_file *m, void *v, loff_t *pos)
-{
-	++*pos;
-	return c_start(m, pos);
-}
-
-static void c_stop(struct seq_file *m, void *v)
-{
-}
-
-const struct seq_operations cpuinfo_op = {
-	.start	= c_start,
-	.next	= c_next,
-	.stop	= c_stop,
-	.show	= show_cpuinfo,
-};
diff --git a/arch/h8300/kernel/signal.c b/arch/h8300/kernel/signal.c
deleted file mode 100644
index a65ff3b..0000000
--- a/arch/h8300/kernel/signal.c
+++ /dev/null
@@ -1,444 +0,0 @@
-/*
- *  linux/arch/h8300/kernel/signal.c
- *
- *  Copyright (C) 1991, 1992  Linus Torvalds
- *
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file COPYING in the main directory of this archive
- * for more details.
- */
-
-/*
- * uClinux H8/300 support by Yoshinori Sato <ysato@users.sourceforge.jp>
- *                and David McCullough <davidm@snapgear.com>
- *
- * Based on
- * Linux/m68k by Hamish Macdonald
- */
-
-/*
- * ++roman (07/09/96): implemented signal stacks (specially for tosemu on
- * Atari :-) Current limitation: Only one sigstack can be active at one time.
- * If a second signal with SA_ONSTACK set arrives while working on a sigstack,
- * SA_ONSTACK is ignored. This behaviour avoids lots of trouble with nested
- * signal handlers!
- */
-
-#include <linux/sched.h>
-#include <linux/mm.h>
-#include <linux/kernel.h>
-#include <linux/signal.h>
-#include <linux/syscalls.h>
-#include <linux/errno.h>
-#include <linux/wait.h>
-#include <linux/ptrace.h>
-#include <linux/unistd.h>
-#include <linux/stddef.h>
-#include <linux/highuid.h>
-#include <linux/personality.h>
-#include <linux/tty.h>
-#include <linux/binfmts.h>
-#include <linux/tracehook.h>
-
-#include <asm/setup.h>
-#include <asm/uaccess.h>
-#include <asm/pgtable.h>
-#include <asm/traps.h>
-#include <asm/ucontext.h>
-
-/*
- * Do a signal return; undo the signal stack.
- *
- * Keep the return code on the stack quadword aligned!
- * That makes the cache flush below easier.
- */
-
-struct sigframe
-{
-	long dummy_er0;
-	long dummy_vector;
-#if defined(CONFIG_CPU_H8S)
-	short dummy_exr;
-#endif
-	long dummy_pc;
-	char *pretcode;
-	unsigned char retcode[8];
-	unsigned long extramask[_NSIG_WORDS-1];
-	struct sigcontext sc;
-	int sig;
-} __attribute__((aligned(2),packed));
-
-struct rt_sigframe
-{
-	long dummy_er0;
-	long dummy_vector;
-#if defined(CONFIG_CPU_H8S)
-	short dummy_exr;
-#endif
-	long dummy_pc;
-	char *pretcode;
-	struct siginfo *pinfo;
-	void *puc;
-	unsigned char retcode[8];
-	struct siginfo info;
-	struct ucontext uc;
-	int sig;
-} __attribute__((aligned(2),packed));
-
-static inline int
-restore_sigcontext(struct sigcontext *usc, int *pd0)
-{
-	struct pt_regs *regs = current_pt_regs();
-	int err = 0;
-	unsigned int ccr;
-	unsigned int usp;
-	unsigned int er0;
-
-	/* Always make any pending restarted system calls return -EINTR */
-	current_thread_info()->restart_block.fn = do_no_restart_syscall;
-
-#define COPY(r) err |= __get_user(regs->r, &usc->sc_##r)    /* restore passed registers */
-	COPY(er1);
-	COPY(er2);
-	COPY(er3);
-	COPY(er5);
-	COPY(pc);
-	ccr = regs->ccr & 0x10;
-	COPY(ccr);
-#undef COPY
-	regs->ccr &= 0xef;
-	regs->ccr |= ccr;
-	regs->orig_er0 = -1;		/* disable syscall checks */
-	err |= __get_user(usp, &usc->sc_usp);
-	wrusp(usp);
-
-	err |= __get_user(er0, &usc->sc_er0);
-	*pd0 = er0;
-	return err;
-}
-
-asmlinkage int sys_sigreturn(void)
-{
-	unsigned long usp = rdusp();
-	struct sigframe *frame = (struct sigframe *)(usp - 4);
-	sigset_t set;
-	int er0;
-
-	if (!access_ok(VERIFY_READ, frame, sizeof(*frame)))
-		goto badframe;
-	if (__get_user(set.sig[0], &frame->sc.sc_mask) ||
-	    (_NSIG_WORDS > 1 &&
-	     __copy_from_user(&set.sig[1], &frame->extramask,
-			      sizeof(frame->extramask))))
-		goto badframe;
-
-	set_current_blocked(&set);
-	
-	if (restore_sigcontext(&frame->sc, &er0))
-		goto badframe;
-	return er0;
-
-badframe:
-	force_sig(SIGSEGV, current);
-	return 0;
-}
-
-asmlinkage int sys_rt_sigreturn(void)
-{
-	unsigned long usp = rdusp();
-	struct rt_sigframe *frame = (struct rt_sigframe *)(usp - 4);
-	sigset_t set;
-	int er0;
-
-	if (!access_ok(VERIFY_READ, frame, sizeof(*frame)))
-		goto badframe;
-	if (__copy_from_user(&set, &frame->uc.uc_sigmask, sizeof(set)))
-		goto badframe;
-
-	set_current_blocked(&set);
-	
-	if (restore_sigcontext(&frame->uc.uc_mcontext, &er0))
-		goto badframe;
-
-	if (restore_altstack(&frame->uc.uc_stack))
-		goto badframe;
-
-	return er0;
-
-badframe:
-	force_sig(SIGSEGV, current);
-	return 0;
-}
-
-static int setup_sigcontext(struct sigcontext __user *sc, struct pt_regs *regs,
-			     unsigned long mask)
-{
-	int err = 0;
-
-	err |= __put_user(regs->er0, &sc->sc_er0);
-	err |= __put_user(regs->er1, &sc->sc_er1);
-	err |= __put_user(regs->er2, &sc->sc_er2);
-	err |= __put_user(regs->er3, &sc->sc_er3);
-	err |= __put_user(regs->er4, &sc->sc_er4);
-	err |= __put_user(regs->er5, &sc->sc_er5);
-	err |= __put_user(regs->er6, &sc->sc_er6);
-	err |= __put_user(rdusp(),   &sc->sc_usp);
-	err |= __put_user(regs->pc,  &sc->sc_pc);
-	err |= __put_user(regs->ccr, &sc->sc_ccr);
-	err |= __put_user(mask,      &sc->sc_mask);
-
-	return err;
-}
-
-static inline void *
-get_sigframe(struct k_sigaction *ka, struct pt_regs *regs, size_t frame_size)
-{
-	unsigned long usp;
-
-	/* Default to using normal stack.  */
-	usp = rdusp();
-
-	/* This is the X/Open sanctioned signal stack switching.  */
-	if (ka->sa.sa_flags & SA_ONSTACK) {
-		if (!sas_ss_flags(usp))
-			usp = current->sas_ss_sp + current->sas_ss_size;
-	}
-	return (void *)((usp - frame_size) & -8UL);
-}
-
-static int setup_frame (int sig, struct k_sigaction *ka,
-			 sigset_t *set, struct pt_regs *regs)
-{
-	struct sigframe *frame;
-	int err = 0;
-	int usig;
-	unsigned char *ret;
-
-	frame = get_sigframe(ka, regs, sizeof(*frame));
-
-	if (!access_ok(VERIFY_WRITE, frame, sizeof(*frame)))
-		goto give_sigsegv;
-
-	usig = current_thread_info()->exec_domain
-		&& current_thread_info()->exec_domain->signal_invmap
-		&& sig < 32
-		? current_thread_info()->exec_domain->signal_invmap[sig]
-		: sig;
-
-	err |= __put_user(usig, &frame->sig);
-	if (err)
-		goto give_sigsegv;
-
-	err |= setup_sigcontext(&frame->sc, regs, set->sig[0]);
-	if (err)
-		goto give_sigsegv;
-
-	if (_NSIG_WORDS > 1) {
-		err |= copy_to_user(frame->extramask, &set->sig[1],
-				    sizeof(frame->extramask));
-		if (err)
-			goto give_sigsegv;
-	}
-
-	ret = frame->retcode;
-	if (ka->sa.sa_flags & SA_RESTORER)
-		ret = (unsigned char *)(ka->sa.sa_restorer);
-	else {
-		/* sub.l er0,er0; mov.b #__NR_sigreturn,r0l; trapa #0 */
-		err |= __put_user(0x1a80f800 + (__NR_sigreturn & 0xff),
-				  (unsigned long *)(frame->retcode + 0));
-		err |= __put_user(0x5700, (unsigned short *)(frame->retcode + 4));
-	}
-
-	/* Set up to return from userspace.  */
-	err |= __put_user(ret, &frame->pretcode);
-
-	if (err)
-		goto give_sigsegv;
-
-	/* Set up registers for signal handler */
-	wrusp ((unsigned long) frame);
-	regs->pc = (unsigned long) ka->sa.sa_handler;
-	regs->er0 = (current_thread_info()->exec_domain
-			   && current_thread_info()->exec_domain->signal_invmap
-			   && sig < 32
-			   ? current_thread_info()->exec_domain->signal_invmap[sig]
-		          : sig);
-	regs->er1 = (unsigned long)&(frame->sc);
-	regs->er5 = current->mm->start_data;	/* GOT base */
-
-	return 0;
-
-give_sigsegv:
-	force_sigsegv(sig, current);
-	return -EFAULT;
-}
-
-static int setup_rt_frame (int sig, struct k_sigaction *ka, siginfo_t *info,
-			    sigset_t *set, struct pt_regs *regs)
-{
-	struct rt_sigframe *frame;
-	int err = 0;
-	int usig;
-	unsigned char *ret;
-
-	frame = get_sigframe(ka, regs, sizeof(*frame));
-
-	if (!access_ok(VERIFY_WRITE, frame, sizeof(*frame)))
-		goto give_sigsegv;
-
-	usig = current_thread_info()->exec_domain
-		&& current_thread_info()->exec_domain->signal_invmap
-		&& sig < 32
-		? current_thread_info()->exec_domain->signal_invmap[sig]
-		: sig;
-
-	err |= __put_user(usig, &frame->sig);
-	if (err)
-		goto give_sigsegv;
-
-	err |= __put_user(&frame->info, &frame->pinfo);
-	err |= __put_user(&frame->uc, &frame->puc);
-	err |= copy_siginfo_to_user(&frame->info, info);
-	if (err)
-		goto give_sigsegv;
-
-	/* Create the ucontext.  */
-	err |= __put_user(0, &frame->uc.uc_flags);
-	err |= __put_user(0, &frame->uc.uc_link);
-	err |= __save_altstack(&frame->uc.uc_stack, rdusp());
-	err |= setup_sigcontext(&frame->uc.uc_mcontext, regs, set->sig[0]);
-	err |= copy_to_user (&frame->uc.uc_sigmask, set, sizeof(*set));
-	if (err)
-		goto give_sigsegv;
-
-	/* Set up to return from userspace.  */
-	ret = frame->retcode;
-	if (ka->sa.sa_flags & SA_RESTORER)
-		ret = (unsigned char *)(ka->sa.sa_restorer);
-	else {
-		/* sub.l er0,er0; mov.b #__NR_sigreturn,r0l; trapa #0 */
-		err |= __put_user(0x1a80f800 + (__NR_sigreturn & 0xff),
-				  (unsigned long *)(frame->retcode + 0));
-		err |= __put_user(0x5700, (unsigned short *)(frame->retcode + 4));
-	}
-	err |= __put_user(ret, &frame->pretcode);
-
-	if (err)
-		goto give_sigsegv;
-
-	/* Set up registers for signal handler */
-	wrusp ((unsigned long) frame);
-	regs->pc  = (unsigned long) ka->sa.sa_handler;
-	regs->er0 = (current_thread_info()->exec_domain
-		     && current_thread_info()->exec_domain->signal_invmap
-		     && sig < 32
-		     ? current_thread_info()->exec_domain->signal_invmap[sig]
-		     : sig);
-	regs->er1 = (unsigned long)&(frame->info);
-	regs->er2 = (unsigned long)&frame->uc;
-	regs->er5 = current->mm->start_data;	/* GOT base */
-
-	return 0;
-
-give_sigsegv:
-	force_sigsegv(sig, current);
-	return -EFAULT;
-}
-
-/*
- * OK, we're invoking a handler
- */
-static void
-handle_signal(unsigned long sig, siginfo_t *info, struct k_sigaction *ka,
-	      struct pt_regs * regs)
-{
-	sigset_t *oldset = sigmask_to_save();
-	int ret;
-	/* are we from a system call? */
-	if (regs->orig_er0 >= 0) {
-		switch (regs->er0) {
-		        case -ERESTART_RESTARTBLOCK:
-			case -ERESTARTNOHAND:
-				regs->er0 = -EINTR;
-				break;
-
-			case -ERESTARTSYS:
-				if (!(ka->sa.sa_flags & SA_RESTART)) {
-					regs->er0 = -EINTR;
-					break;
-				}
-			/* fallthrough */
-			case -ERESTARTNOINTR:
-				regs->er0 = regs->orig_er0;
-				regs->pc -= 2;
-		}
-	}
-
-	/* set up the stack frame */
-	if (ka->sa.sa_flags & SA_SIGINFO)
-		ret = setup_rt_frame(sig, ka, info, oldset, regs);
-	else
-		ret = setup_frame(sig, ka, oldset, regs);
-
-	if (!ret)
-		signal_delivered(sig, info, ka, regs, 0);
-}
-
-/*
- * Note that 'init' is a special process: it doesn't get signals it doesn't
- * want to handle. Thus you cannot kill init even with a SIGKILL even by
- * mistake.
- */
-static void do_signal(struct pt_regs *regs)
-{
-	siginfo_t info;
-	int signr;
-	struct k_sigaction ka;
-
-	/*
-	 * We want the common case to go fast, which
-	 * is why we may in certain cases get here from
-	 * kernel mode. Just return without doing anything
-	 * if so.
-	 */
-	if ((regs->ccr & 0x10))
-		return;
-
-	current->thread.esp0 = (unsigned long) regs;
-
-	signr = get_signal_to_deliver(&info, &ka, regs, NULL);
-	if (signr > 0) {
-		/* Whee!  Actually deliver the signal.  */
-		handle_signal(signr, &info, &ka, regs);
-		return;
-	}
-	/* Did we come from a system call? */
-	if (regs->orig_er0 >= 0) {
-		/* Restart the system call - no handlers present */
-		if (regs->er0 == -ERESTARTNOHAND ||
-		    regs->er0 == -ERESTARTSYS ||
-		    regs->er0 == -ERESTARTNOINTR) {
-			regs->er0 = regs->orig_er0;
-			regs->pc -= 2;
-		}
-		if (regs->er0 == -ERESTART_RESTARTBLOCK){
-			regs->er0 = __NR_restart_syscall;
-			regs->pc -= 2;
-		}
-	}
-
-	/* If there's no signal to deliver, we just restore the saved mask.  */
-	restore_saved_sigmask();
-}
-
-asmlinkage void do_notify_resume(struct pt_regs *regs, u32 thread_info_flags)
-{
-	if (thread_info_flags & _TIF_SIGPENDING)
-		do_signal(regs);
-
-	if (thread_info_flags & _TIF_NOTIFY_RESUME) {
-		clear_thread_flag(TIF_NOTIFY_RESUME);
-		tracehook_notify_resume(regs);
-	}
-}
diff --git a/arch/h8300/kernel/sys_h8300.c b/arch/h8300/kernel/sys_h8300.c
deleted file mode 100644
index bf350cb..0000000
--- a/arch/h8300/kernel/sys_h8300.c
+++ /dev/null
@@ -1,48 +0,0 @@
-/*
- * linux/arch/h8300/kernel/sys_h8300.c
- *
- * This file contains various random system calls that
- * have a non-standard calling sequence on the H8/300
- * platform.
- */
-
-#include <linux/errno.h>
-#include <linux/sched.h>
-#include <linux/mm.h>
-#include <linux/smp.h>
-#include <linux/sem.h>
-#include <linux/msg.h>
-#include <linux/shm.h>
-#include <linux/stat.h>
-#include <linux/syscalls.h>
-#include <linux/mman.h>
-#include <linux/file.h>
-#include <linux/fs.h>
-#include <linux/ipc.h>
-
-#include <asm/setup.h>
-#include <asm/uaccess.h>
-#include <asm/cachectl.h>
-#include <asm/traps.h>
-#include <asm/unistd.h>
-
-/* sys_cacheflush -- no support.  */
-asmlinkage int
-sys_cacheflush (unsigned long addr, int scope, int cache, unsigned long len)
-{
-	return -EINVAL;
-}
-
-asmlinkage int sys_getpagesize(void)
-{
-	return PAGE_SIZE;
-}
-
-#if defined(CONFIG_SYSCALL_PRINT)
-asmlinkage void syscall_print(void *dummy,...)
-{
-	struct pt_regs *regs = (struct pt_regs *) ((unsigned char *)&dummy-4);
-	printk("call %06lx:%ld 1:%08lx,2:%08lx,3:%08lx,ret:%08lx\n",
-               ((regs->pc)&0xffffff)-2,regs->orig_er0,regs->er1,regs->er2,regs->er3,regs->er0);
-}
-#endif
diff --git a/arch/h8300/kernel/syscalls.S b/arch/h8300/kernel/syscalls.S
deleted file mode 100644
index c55e0ed..0000000
--- a/arch/h8300/kernel/syscalls.S
+++ /dev/null
@@ -1,338 +0,0 @@
-/* Systemcall Entry Table */
-#include <linux/sys.h>
-#include <asm/linkage.h>
-#include <asm/unistd.h>
-
-#define CALL(x)	.long _ ## x
-
-.globl _sys_call_table
-
-#if defined(CONFIG_CPU_H8300H)
-	.h8300h
-#endif
-#if defined(CONFIG_CPU_H8S)
-	.h8300s
-#endif
-	.section .text
-	.align	2
-_sys_call_table:
-	CALL(sys_ni_syscall)		/* 0  -  old "setup()" system call*/
-	CALL(sys_exit)
-	CALL(sys_fork)
-	CALL(sys_read)
-	CALL(sys_write)
-	CALL(sys_open)			/* 5 */
-	CALL(sys_close)
-	CALL(sys_waitpid)
-	CALL(sys_creat)
-	CALL(sys_link)
-	CALL(sys_unlink)		/* 10 */
-	CALL(sys_execve)
-	CALL(sys_chdir)
-	CALL(sys_time)
-	CALL(sys_mknod)
-	CALL(sys_chmod)			/* 15 */
-	CALL(sys_chown16)
-	CALL(sys_ni_syscall)		/* old break syscall holder */
-	CALL(sys_stat)
-	CALL(sys_lseek)
-	CALL(sys_getpid)		/* 20 */
-	CALL(sys_mount)
-	CALL(sys_oldumount)
-	CALL(sys_setuid16)
-	CALL(sys_getuid16)
-	CALL(sys_stime)			/* 25 */
-	CALL(sys_ptrace)
-	CALL(sys_alarm)
-	CALL(sys_fstat)
-	CALL(sys_pause)
-	CALL(sys_utime)			/* 30 */
-	CALL(sys_ni_syscall)		/* old stty syscall holder */
-	CALL(sys_ni_syscall)		/* old gtty syscall holder */
-	CALL(sys_access)
-	CALL(sys_nice)
-	CALL(sys_ni_syscall)		/* 35 old ftime syscall holder */
-	CALL(sys_sync)
-	CALL(sys_kill)
-	CALL(sys_rename)
-	CALL(sys_mkdir)
-	CALL(sys_rmdir)			/* 40 */
-	CALL(sys_dup)
-	CALL(sys_pipe)
-	CALL(sys_times)
-	CALL(sys_ni_syscall)		/* old prof syscall holder */
-	CALL(sys_brk)			/* 45 */
-	CALL(sys_setgid16)
-	CALL(sys_getgid16)
-	CALL(sys_signal)
-	CALL(sys_geteuid16)
-	CALL(sys_getegid16)		/* 50 */
-	CALL(sys_acct)
-	CALL(sys_umount)		/* recycled never used phys() */
-	CALL(sys_ni_syscall)		/* old lock syscall holder */
-	CALL(sys_ioctl)
-	CALL(sys_fcntl)			/* 55 */
-	CALL(sys_ni_syscall)		/* old mpx syscall holder */
-	CALL(sys_setpgid)
-	CALL(sys_ni_syscall)		/* old ulimit syscall holder */
-	CALL(sys_ni_syscall)
-	CALL(sys_umask)			/* 60 */
-	CALL(sys_chroot)
-	CALL(sys_ustat)
-	CALL(sys_dup2)
-	CALL(sys_getppid)
-	CALL(sys_getpgrp)		/* 65 */
-	CALL(sys_setsid)
-	CALL(sys_sigaction)
-	CALL(sys_sgetmask)
-	CALL(sys_ssetmask)
-	CALL(sys_setreuid16)		/* 70 */
-	CALL(sys_setregid16)
-	CALL(sys_sigsuspend)
-	CALL(sys_sigpending)
-	CALL(sys_sethostname)
-	CALL(sys_setrlimit)		/* 75 */
-	CALL(sys_old_getrlimit)
-	CALL(sys_getrusage)
-	CALL(sys_gettimeofday)
-	CALL(sys_settimeofday)
-	CALL(sys_getgroups16)		/* 80 */
-	CALL(sys_setgroups16)
-	CALL(sys_old_select)
-	CALL(sys_symlink)
-	CALL(sys_lstat)
-	CALL(sys_readlink)		/* 85 */
-	CALL(sys_uselib)
-	CALL(sys_swapon)
-	CALL(sys_reboot)
-	CALL(sys_old_readdir)
-	CALL(sys_old_mmap)		/* 90 */
-	CALL(sys_munmap)
-	CALL(sys_truncate)
-	CALL(sys_ftruncate)
-	CALL(sys_fchmod)
-	CALL(sys_fchown16)		/* 95 */
-	CALL(sys_getpriority)
-	CALL(sys_setpriority)
-	CALL(sys_ni_syscall)		/* old profil syscall holder */
-	CALL(sys_statfs)
-	CALL(sys_fstatfs)		/* 100 */
-	CALL(sys_ni_syscall)		/* ioperm for i386 */
-	CALL(sys_socketcall)
-	CALL(sys_syslog)
-	CALL(sys_setitimer)
-	CALL(sys_getitimer)		/* 105 */
-	CALL(sys_newstat)
-	CALL(sys_newlstat)
-	CALL(sys_newfstat)
-	CALL(sys_ni_syscall)
-	CALL(sys_ni_syscall)		/* iopl for i386 */ /* 110 */
-	CALL(sys_vhangup)
-	CALL(sys_ni_syscall)		/* obsolete idle() syscall */
-	CALL(sys_ni_syscall)		/* vm86old for i386 */
-	CALL(sys_wait4)
-	CALL(sys_swapoff)		/* 115 */
-	CALL(sys_sysinfo)
-	CALL(sys_ipc)
-	CALL(sys_fsync)
-	CALL(sys_sigreturn)
-	CALL(sys_clone)			/* 120 */
-	CALL(sys_setdomainname)
-	CALL(sys_newuname)
-	CALL(sys_cacheflush)		/* modify_ldt for i386 */
-	CALL(sys_adjtimex)
-	CALL(sys_ni_syscall)		/* 125 sys_mprotect */
-	CALL(sys_sigprocmask)
-	CALL(sys_ni_syscall)		/* sys_create_module */
-	CALL(sys_init_module)
-	CALL(sys_delete_module)
-	CALL(sys_ni_syscall)		/* 130 sys_get_kernel_syms */
-	CALL(sys_quotactl)
-	CALL(sys_getpgid)
-	CALL(sys_fchdir)
-	CALL(sys_bdflush)
-	CALL(sys_sysfs)			/* 135 */
-	CALL(sys_personality)
-	CALL(sys_ni_syscall)		/* for afs_syscall */
-	CALL(sys_setfsuid16)
-	CALL(sys_setfsgid16)
-	CALL(sys_llseek)		/* 140 */
-	CALL(sys_getdents)
-	CALL(sys_select)
-	CALL(sys_flock)
-	CALL(sys_ni_syscall)		/* sys_msync */
-	CALL(sys_readv)			/* 145 */
-	CALL(sys_writev)
-	CALL(sys_getsid)
-	CALL(sys_fdatasync)
-	CALL(sys_sysctl)
-	CALL(sys_ni_syscall)		/* 150 sys_mlock */
-	CALL(sys_ni_syscall)		/* sys_munlock */
-	CALL(sys_ni_syscall)		/* sys_mlockall */
-	CALL(sys_ni_syscall)		/* sys_munlockall */
-	CALL(sys_sched_setparam)
-	CALL(sys_sched_getparam)	/* 155 */
-	CALL(sys_sched_setscheduler)
-	CALL(sys_sched_getscheduler)
-	CALL(sys_sched_yield)
-	CALL(sys_sched_get_priority_max)
-	CALL(sys_sched_get_priority_min)  /* 160 */
-	CALL(sys_sched_rr_get_interval)
-	CALL(sys_nanosleep)
-	CALL(sys_ni_syscall)		/* sys_mremap */
-	CALL(sys_setresuid16)
-	CALL(sys_getresuid16)		/* 165 */
-	CALL(sys_ni_syscall)		/* for vm86 */
-	CALL(sys_ni_syscall)		/* sys_query_module */
-	CALL(sys_poll)
-	CALL(sys_ni_syscall)		/* old nfsservctl */
-	CALL(sys_setresgid16)		/* 170 */
-	CALL(sys_getresgid16)
-	CALL(sys_prctl)
-	CALL(sys_rt_sigreturn)
-	CALL(sys_rt_sigaction)
-	CALL(sys_rt_sigprocmask)	/* 175 */
-	CALL(sys_rt_sigpending)
-	CALL(sys_rt_sigtimedwait)
-	CALL(sys_rt_sigqueueinfo)
-	CALL(sys_rt_sigsuspend)
-	CALL(sys_pread64)		/* 180 */
-	CALL(sys_pwrite64)
-	CALL(sys_lchown16);
-	CALL(sys_getcwd)
-	CALL(sys_capget)
-	CALL(sys_capset)		/* 185 */
-	CALL(sys_sigaltstack)
-	CALL(sys_sendfile)
-	CALL(sys_ni_syscall)		/* streams1 */
-	CALL(sys_ni_syscall)		/* streams2 */
-	CALL(sys_vfork)			/* 190 */
-	CALL(sys_getrlimit)
-	CALL(sys_mmap_pgoff)
-	CALL(sys_truncate64)
-	CALL(sys_ftruncate64)
-	CALL(sys_stat64)		/* 195 */
-	CALL(sys_lstat64)
-	CALL(sys_fstat64)
-	CALL(sys_chown)
-	CALL(sys_getuid)
-	CALL(sys_getgid)		/* 200 */
-	CALL(sys_geteuid)
-	CALL(sys_getegid)
-	CALL(sys_setreuid)
-	CALL(sys_setregid)
-	CALL(sys_getgroups)		/* 205 */
-	CALL(sys_setgroups)
-	CALL(sys_fchown)
-	CALL(sys_setresuid)
-	CALL(sys_getresuid)
-	CALL(sys_setresgid)		/* 210 */
-	CALL(sys_getresgid)
-	CALL(sys_lchown)
-	CALL(sys_setuid)
-	CALL(sys_setgid)
-	CALL(sys_setfsuid)		/* 215 */
-	CALL(sys_setfsgid)
-	CALL(sys_pivot_root)
-	CALL(sys_ni_syscall)
-	CALL(sys_ni_syscall)
-	CALL(sys_getdents64)		/* 220 */
-	CALL(sys_fcntl64)
-	CALL(sys_ni_syscall)		/* reserved TUX */
-	CALL(sys_ni_syscall)		/* reserved Security */
-	CALL(sys_gettid)
-	CALL(sys_readahead)		/* 225 */
-	CALL(sys_setxattr)
-	CALL(sys_lsetxattr)
-	CALL(sys_fsetxattr)
-	CALL(sys_getxattr)
-	CALL(sys_lgetxattr)		/* 230 */
-	CALL(sys_fgetxattr)
-	CALL(sys_listxattr)
-	CALL(sys_llistxattr)
-	CALL(sys_flistxattr)
-	CALL(sys_removexattr)		/* 235 */
-	CALL(sys_lremovexattr)
-	CALL(sys_fremovexattr)
-	CALL(sys_tkill)
-	CALL(sys_sendfile64)
-	CALL(sys_futex)			/* 240 */
-	CALL(sys_sched_setaffinity)
-	CALL(sys_sched_getaffinity)
-	CALL(sys_ni_syscall)
-	CALL(sys_ni_syscall)
-	CALL(sys_io_setup)		/* 245 */
-	CALL(sys_io_destroy)
-	CALL(sys_io_getevents)
-	CALL(sys_io_submit)
-	CALL(sys_io_cancel)
-	CALL(sys_fadvise64)		/* 250 */
-	CALL(sys_ni_syscall)
-	CALL(sys_exit_group)
-	CALL(sys_lookup_dcookie)
-	CALL(sys_epoll_create)
-	CALL(sys_epoll_ctl)		/* 255 */
-	CALL(sys_epoll_wait)
-	CALL(sys_ni_syscall)		/* sys_remap_file_pages */
-	CALL(sys_set_tid_address)
-	CALL(sys_timer_create)
-	CALL(sys_timer_settime)		/* 260 */
-	CALL(sys_timer_gettime)
-	CALL(sys_timer_getoverrun)
-	CALL(sys_timer_delete)
-	CALL(sys_clock_settime)
-	CALL(sys_clock_gettime)		/* 265 */
-	CALL(sys_clock_getres)
-	CALL(sys_clock_nanosleep)
-	CALL(sys_statfs64)
-	CALL(sys_fstatfs64)
-	CALL(sys_tgkill)		/* 270 */
-	CALL(sys_utimes)
-	CALL(sys_fadvise64_64)
-	CALL(sys_ni_syscall)		/* sys_vserver */
-	CALL(sys_ni_syscall)
-	CALL(sys_get_mempolicy)		/* 275 */
-	CALL(sys_set_mempolicy)
-	CALL(sys_mq_open)
-	CALL(sys_mq_unlink)
-	CALL(sys_mq_timedsend)
-	CALL(sys_mq_timedreceive)	/* 280 */
-	CALL(sys_mq_notify)
-	CALL(sys_mq_getsetattr)
-	CALL(sys_waitid)
-	CALL(sys_ni_syscall)		/* sys_kexec_load */
-	CALL(sys_add_key) 		/* 285 */
-	CALL(sys_request_key)
-	CALL(sys_keyctl)
-	CALL(sys_ioprio_set)
-	CALL(sys_ioprio_get)		/* 290 */
-	CALL(sys_inotify_init)
-	CALL(sys_inotify_add_watch)
-	CALL(sys_inotify_rm_watch)
-	CALL(sys_migrate_pages)
-	CALL(sys_openat)		/* 295 */
-	CALL(sys_mkdirat)
-	CALL(sys_mknodat)
-	CALL(sys_fchownat)
-	CALL(sys_futimesat)
-	CALL(sys_fstatat64)		/* 300 */
-	CALL(sys_unlinkat)
-	CALL(sys_renameat)
-	CALL(sys_linkat)
-	CALL(sys_symlinkat)
-	CALL(sys_readlinkat)		/* 305 */
-	CALL(sys_fchmodat)
-	CALL(sys_faccessat)
-	CALL(sys_ni_syscall)		/* sys_pselect6 */
-	CALL(sys_ni_syscall)		/* sys_ppoll */
-	CALL(sys_unshare)		/* 310 */
-	CALL(sys_set_robust_list)
-	CALL(sys_get_robust_list)
-	CALL(sys_splice)
-	CALL(sys_sync_file_range)
-	CALL(sys_tee)			/* 315 */
-	CALL(sys_vmsplice)
-	CALL(sys_ni_syscall)		/* sys_move_pages */
-	CALL(sys_getcpu)
-	CALL(sys_ni_syscall)		/* sys_epoll_pwait */
-	CALL(sys_setns)			/* 320 */
diff --git a/arch/h8300/kernel/time.c b/arch/h8300/kernel/time.c
deleted file mode 100644
index e0f7419..0000000
--- a/arch/h8300/kernel/time.c
+++ /dev/null
@@ -1,66 +0,0 @@
-/*
- *  linux/arch/h8300/kernel/time.c
- *
- *  Yoshinori Sato <ysato@users.sourceforge.jp>
- *
- *  Copied/hacked from:
- *
- *  linux/arch/m68k/kernel/time.c
- *
- *  Copyright (C) 1991, 1992, 1995  Linus Torvalds
- *
- * This file contains the m68k-specific time handling details.
- * Most of the stuff is located in the machine specific files.
- *
- * 1997-09-10	Updated NTP code according to technical memorandum Jan '96
- *		"A Kernel Model for Precision Timekeeping" by Dave Mills
- */
-
-#include <linux/errno.h>
-#include <linux/module.h>
-#include <linux/sched.h>
-#include <linux/kernel.h>
-#include <linux/param.h>
-#include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/timex.h>
-#include <linux/profile.h>
-
-#include <asm/io.h>
-#include <asm/irq_regs.h>
-#include <asm/timer.h>
-
-#define	TICK_SIZE (tick_nsec / 1000)
-
-void h8300_timer_tick(void)
-{
-	if (current->pid)
-		profile_tick(CPU_PROFILING);
-	xtime_update(1);
-	update_process_times(user_mode(get_irq_regs()));
-}
-
-void read_persistent_clock(struct timespec *ts)
-{
-	unsigned int year, mon, day, hour, min, sec;
-
-	/* FIX by dqg : Set to zero for platforms that don't have tod */
-	/* without this time is undefined and can overflow time_t, causing  */
-	/* very strange errors */
-	year = 1980;
-	mon = day = 1;
-	hour = min = sec = 0;
-#ifdef CONFIG_H8300_GETTOD
-	h8300_gettod (&year, &mon, &day, &hour, &min, &sec);
-#endif
-	if ((year += 1900) < 1970)
-		year += 100;
-	ts->tv_sec = mktime(year, mon, day, hour, min, sec);
-	ts->tv_nsec = 0;
-}
-
-void __init time_init(void)
-{
-
-	h8300_timer_setup();
-}
diff --git a/arch/h8300/kernel/timer/Makefile b/arch/h8300/kernel/timer/Makefile
deleted file mode 100644
index bef0510..0000000
--- a/arch/h8300/kernel/timer/Makefile
+++ /dev/null
@@ -1,6 +0,0 @@
-# h8300 internal timer handler
-
-obj-$(CONFIG_H8300_TIMER8)  := timer8.o
-obj-$(CONFIG_H8300_TIMER16) := timer16.o
-obj-$(CONFIG_H8300_ITU)     := itu.o
-obj-$(CONFIG_H8300_TPU)     := tpu.o
diff --git a/arch/h8300/kernel/timer/itu.c b/arch/h8300/kernel/timer/itu.c
deleted file mode 100644
index 0a8b5cd..0000000
--- a/arch/h8300/kernel/timer/itu.c
+++ /dev/null
@@ -1,82 +0,0 @@
-/*
- *  linux/arch/h8300/kernel/timer/itu.c
- *
- *  Yoshinori Sato <ysato@users.sourcefoge.jp>
- *
- *  ITU Timer Handler
- *
- */
-
-#include <linux/errno.h>
-#include <linux/sched.h>
-#include <linux/kernel.h>
-#include <linux/param.h>
-#include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/interrupt.h>
-#include <linux/init.h>
-#include <linux/timex.h>
-
-#include <asm/segment.h>
-#include <asm/io.h>
-#include <asm/irq.h>
-#include <asm/regs306x.h>
-
-#if CONFIG_H8300_ITU_CH == 0
-#define ITUBASE	0xffff64
-#define ITUIRQ	24
-#elif CONFIG_H8300_ITU_CH == 1
-#define ITUBASE	0xffff6e
-#define ITUIRQ	28
-#elif CONFIG_H8300_ITU_CH == 2
-#define ITUBASE	0xffff78
-#define ITUIRQ	32
-#elif CONFIG_H8300_ITU_CH == 3
-#define ITUBASE	0xffff82
-#define ITUIRQ	36
-#elif CONFIG_H8300_ITU_CH == 4
-#define ITUBASE	0xffff92
-#define ITUIRQ	40
-#else
-#error Unknown timer channel.
-#endif
-
-#define TCR	0
-#define TIOR	1
-#define TIER	2
-#define TSR	3
-#define TCNT	4
-#define GRA	6
-#define GRB	8
-
-static irqreturn_t timer_interrupt(int irq, void *dev_id)
-{
-	h8300_timer_tick();
-	ctrl_bclr(IMFA, ITUBASE + TSR);
-	return IRQ_HANDLED;
-}
-
-static struct irqaction itu_irq = {
-	.name		= "itu",
-	.handler	= timer_interrupt,
-	.flags		= IRQF_DISABLED | IRQF_TIMER,
-};
-
-static const int __initconst divide_rate[] = {1, 2, 4, 8};
-
-void __init h8300_timer_setup(void)
-{
-	unsigned int div;
-	unsigned int cnt;
-
-	calc_param(cnt, div, divide_rate, 0x10000);
-
-	setup_irq(ITUIRQ, &itu_irq);
-
-	/* initialize timer */
-	ctrl_outb(0, TSTR);
-	ctrl_outb(CCLR0 | div, ITUBASE + TCR);
-	ctrl_outb(0x01, ITUBASE + TIER);
-	ctrl_outw(cnt, ITUBASE + GRA);
-	ctrl_bset(CONFIG_H8300_ITU_CH, TSTR);
-}
diff --git a/arch/h8300/kernel/timer/timer16.c b/arch/h8300/kernel/timer/timer16.c
deleted file mode 100644
index 462d9f58..0000000
--- a/arch/h8300/kernel/timer/timer16.c
+++ /dev/null
@@ -1,77 +0,0 @@
-/*
- *  linux/arch/h8300/kernel/timer/timer16.c
- *
- *  Yoshinori Sato <ysato@users.sourcefoge.jp>
- *
- *  16bit Timer Handler
- *
- */
-
-#include <linux/errno.h>
-#include <linux/sched.h>
-#include <linux/kernel.h>
-#include <linux/param.h>
-#include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/interrupt.h>
-#include <linux/init.h>
-#include <linux/timex.h>
-
-#include <asm/segment.h>
-#include <asm/io.h>
-#include <asm/irq.h>
-#include <asm/regs306x.h>
-
-/* 16bit timer */
-#if CONFIG_H8300_TIMER16_CH == 0
-#define _16BASE	0xffff78
-#define _16IRQ	24
-#elif CONFIG_H8300_TIMER16_CH == 1
-#define _16BASE	0xffff80
-#define _16IRQ	28
-#elif CONFIG_H8300_TIMER16_CH == 2
-#define _16BASE	0xffff88
-#define _16IRQ	32
-#else
-#error Unknown timer channel.
-#endif
-
-#define TCR	0
-#define TIOR	1
-#define TCNT	2
-#define GRA	4
-#define GRB	6
-
-#define H8300_TIMER_FREQ CONFIG_CPU_CLOCK*10000 /* Timer input freq. */
-
-static irqreturn_t timer_interrupt(int irq, void *dev_id)
-{
-	h8300_timer_tick();
-	ctrl_bclr(CONFIG_H8300_TIMER16_CH, TISRA);
-	return IRQ_HANDLED;
-}
-
-static struct irqaction timer16_irq = {
-	.name		= "timer-16",
-	.handler	= timer_interrupt,
-	.flags		= IRQF_DISABLED | IRQF_TIMER,
-};
-
-static const int __initconst divide_rate[] = {1, 2, 4, 8};
-
-void __init h8300_timer_setup(void)
-{
-	unsigned int div;
-	unsigned int cnt;
-
-	calc_param(cnt, div, divide_rate, 0x10000);
-
-	setup_irq(_16IRQ, &timer16_irq);
-
-	/* initialize timer */
-	ctrl_outb(0, TSTR);
-	ctrl_outb(CCLR0 | div, _16BASE + TCR);
-	ctrl_outw(cnt, _16BASE + GRA);
-	ctrl_bset(4 + CONFIG_H8300_TIMER16_CH, TISRA);
-	ctrl_bset(CONFIG_H8300_TIMER16_CH, TSTR);
-}
diff --git a/arch/h8300/kernel/timer/timer8.c b/arch/h8300/kernel/timer/timer8.c
deleted file mode 100644
index 505f341..0000000
--- a/arch/h8300/kernel/timer/timer8.c
+++ /dev/null
@@ -1,102 +0,0 @@
-/*
- *  linux/arch/h8300/kernel/cpu/timer/timer8.c
- *
- *  Yoshinori Sato <ysato@users.sourcefoge.jp>
- *
- *  8bit Timer Handler
- *
- */
-
-#include <linux/errno.h>
-#include <linux/sched.h>
-#include <linux/kernel.h>
-#include <linux/param.h>
-#include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/interrupt.h>
-#include <linux/init.h>
-#include <linux/profile.h>
-
-#include <asm/io.h>
-#include <asm/irq.h>
-#include <asm/timer.h>
-#if defined(CONFIG_CPU_H8300H)
-#include <asm/regs306x.h>
-#endif
-#if defined(CONFIG_CPU_H8S)
-#include <asm/regs267x.h>
-#endif
-
-/* 8bit timer x2 */
-#define CMFA	6
-
-#if defined(CONFIG_H8300_TIMER8_CH0)
-#define _8BASE	_8TCR0
-#ifdef CONFIG_CPU_H8300H
-#define _8IRQ	36
-#endif
-#ifdef CONFIG_CPU_H8S
-#define _8IRQ	72
-#endif
-#elif defined(CONFIG_H8300_TIMER8_CH2)
-#ifdef CONFIG_CPU_H8300H
-#define _8BASE	_8TCR2
-#define _8IRQ	40
-#endif
-#endif
-
-#ifndef _8BASE
-#error Unknown timer channel.
-#endif
-
-#define _8TCR	0
-#define _8TCSR	2
-#define TCORA	4
-#define TCORB	6
-#define _8TCNT	8
-
-#define CMIEA	0x40
-#define CCLR_CMA 0x08
-#define CKS2	0x04
-
-/*
- * timer_interrupt() needs to keep up the real-time clock,
- * as well as call the "xtime_update()" routine every clocktick
- */
-
-static irqreturn_t timer_interrupt(int irq, void *dev_id)
-{
-	h8300_timer_tick();
-	ctrl_bclr(CMFA, _8BASE + _8TCSR);
-	return IRQ_HANDLED;
-}
-
-static struct irqaction timer8_irq = {
-	.name		= "timer-8",
-	.handler	= timer_interrupt,
-	.flags		= IRQF_DISABLED | IRQF_TIMER,
-};
-
-static const int __initconst divide_rate[] = {8, 64, 8192};
-
-void __init h8300_timer_setup(void)
-{
-	unsigned int div;
-	unsigned int cnt;
-
-	calc_param(cnt, div, divide_rate, 0x10000);
-	div++;
-
-	setup_irq(_8IRQ, &timer8_irq);
-
-#if defined(CONFIG_CPU_H8S)
-	/* Timer module enable */
-	ctrl_bclr(0, MSTPCRL)
-#endif
-
-	/* initialize timer */
-	ctrl_outw(cnt, _8BASE + TCORA);
-	ctrl_outw(0x0000, _8BASE + _8TCSR);
-	ctrl_outw((CMIEA|CCLR_CMA|CKS2) << 8 | div,
-		  _8BASE + _8TCR);
-}
diff --git a/arch/h8300/kernel/timer/tpu.c b/arch/h8300/kernel/timer/tpu.c
deleted file mode 100644
index 0350f62..0000000
--- a/arch/h8300/kernel/timer/tpu.c
+++ /dev/null
@@ -1,100 +0,0 @@
-/*
- *  linux/arch/h8300/kernel/timer/tpu.c
- *
- *  Yoshinori Sato <ysato@users.sourceforge.jp>
- *
- *  TPU Timer Handler
- *
- */
-
-#include <linux/errno.h>
-#include <linux/sched.h>
-#include <linux/kernel.h>
-#include <linux/param.h>
-#include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/interrupt.h>
-#include <linux/init.h>
-#include <linux/timex.h>
-
-#include <asm/segment.h>
-#include <asm/io.h>
-#include <asm/irq.h>
-#include <asm/regs267x.h>
-
-/* TPU */
-#if CONFIG_H8300_TPU_CH == 0
-#define TPUBASE	0xffffd0
-#define TPUIRQ	40
-#elif CONFIG_H8300_TPU_CH == 1
-#define TPUBASE	0xffffe0
-#define TPUIRQ	48
-#elif CONFIG_H8300_TPU_CH == 2
-#define TPUBASE	0xfffff0
-#define TPUIRQ	52
-#elif CONFIG_H8300_TPU_CH == 3
-#define TPUBASE	0xfffe80
-#define TPUIRQ	56
-#elif CONFIG_H8300_TPU_CH == 4
-#define TPUBASE	0xfffe90
-#define TPUIRQ	64
-#else
-#error Unknown timer channel.
-#endif
-
-#define _TCR	0
-#define _TMDR	1
-#define _TIOR	2
-#define _TIER	4
-#define _TSR	5
-#define _TCNT	6
-#define _GRA	8
-#define _GRB	10
-
-#define CCLR0	0x20
-
-static irqreturn_t timer_interrupt(int irq, void *dev_id)
-{
-	h8300_timer_tick();
-	ctrl_bclr(0, TPUBASE + _TSR);
-	return IRQ_HANDLED;
-}
-
-static struct irqaction tpu_irq = {
-	.name		= "tpu",
-	.handler	= timer_interrupt,
-	.flags		= IRQF_DISABLED | IRQF_TIMER,
-};
-
-static const int __initconst divide_rate[] = {
-#if CONFIG_H8300_TPU_CH == 0
-	1,4,16,64,0,0,0,0,
-#elif (CONFIG_H8300_TPU_CH == 1) || (CONFIG_H8300_TPU_CH == 5)
-	1,4,16,64,0,0,256,0,
-#elif (CONFIG_H8300_TPU_CH == 2) || (CONFIG_H8300_TPU_CH == 4)
-	1,4,16,64,0,0,0,1024,
-#elif CONFIG_H8300_TPU_CH == 3
-	1,4,16,64,0,1024,256,4096,
-#endif
-};
-
-void __init h8300_timer_setup(void)
-{
-	unsigned int cnt;
-	unsigned int div;
-
-	calc_param(cnt, div, divide_rate, 0x10000);
-
-	setup_irq(TPUIRQ, &tpu_irq);
-
-	/* TPU module enabled */
-	ctrl_bclr(3, MSTPCRH);
-
-	ctrl_outb(0, TSTR);
-	ctrl_outb(CCLR0 | div, TPUBASE + _TCR);
-	ctrl_outb(0, TPUBASE + _TMDR);
-	ctrl_outw(0, TPUBASE + _TIOR);
-	ctrl_outb(0x01, TPUBASE + _TIER);
-	ctrl_outw(cnt, TPUBASE + _GRA);
-	ctrl_bset(CONFIG_H8300_TPU_CH, TSTR);
-}
diff --git a/arch/h8300/kernel/traps.c b/arch/h8300/kernel/traps.c
deleted file mode 100644
index cfe494d..0000000
--- a/arch/h8300/kernel/traps.c
+++ /dev/null
@@ -1,166 +0,0 @@
-/*
- * linux/arch/h8300/boot/traps.c -- general exception handling code
- * H8/300 support Yoshinori Sato <ysato@users.sourceforge.jp>
- * 
- * Cloned from Linux/m68k.
- *
- * No original Copyright holder listed,
- * Probable original (C) Roman Zippel (assigned DJD, 1999)
- *
- * Copyright 1999-2000 D. Jeff Dionne, <jeff@rt-control.com>
- *
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file COPYING in the main directory of this archive
- * for more details.
- */
-
-#include <linux/types.h>
-#include <linux/sched.h>
-#include <linux/kernel.h>
-#include <linux/errno.h>
-#include <linux/init.h>
-#include <linux/module.h>
-#include <linux/bug.h>
-
-#include <asm/irq.h>
-#include <asm/traps.h>
-#include <asm/page.h>
-
-static DEFINE_SPINLOCK(die_lock);
-
-/*
- * this must be called very early as the kernel might
- * use some instruction that are emulated on the 060
- */
-
-void __init base_trap_init(void)
-{
-}
-
-void __init trap_init (void)
-{
-}
-
-asmlinkage void set_esp0 (unsigned long ssp)
-{
-	current->thread.esp0 = ssp;
-}
-
-/*
- *	Generic dumping code. Used for panic and debug.
- */
-
-static void dump(struct pt_regs *fp)
-{
-	unsigned long	*sp;
-	unsigned char	*tp;
-	int		i;
-
-	printk("\nCURRENT PROCESS:\n\n");
-	printk("COMM=%s PID=%d\n", current->comm, current->pid);
-	if (current->mm) {
-		printk("TEXT=%08x-%08x DATA=%08x-%08x BSS=%08x-%08x\n",
-			(int) current->mm->start_code,
-			(int) current->mm->end_code,
-			(int) current->mm->start_data,
-			(int) current->mm->end_data,
-			(int) current->mm->end_data,
-			(int) current->mm->brk);
-		printk("USER-STACK=%08x  KERNEL-STACK=%08lx\n\n",
-			(int) current->mm->start_stack,
-			(int) PAGE_SIZE+(unsigned long)current);
-	}
-
-	show_regs(fp);
-	printk("\nCODE:");
-	tp = ((unsigned char *) fp->pc) - 0x20;
-	for (sp = (unsigned long *) tp, i = 0; (i < 0x40);  i += 4) {
-		if ((i % 0x10) == 0)
-			printk("\n%08x: ", (int) (tp + i));
-		printk("%08x ", (int) *sp++);
-	}
-	printk("\n");
-
-	printk("\nKERNEL STACK:");
-	tp = ((unsigned char *) fp) - 0x40;
-	for (sp = (unsigned long *) tp, i = 0; (i < 0xc0); i += 4) {
-		if ((i % 0x10) == 0)
-			printk("\n%08x: ", (int) (tp + i));
-		printk("%08x ", (int) *sp++);
-	}
-	printk("\n");
-	if (STACK_MAGIC != *(unsigned long *)((unsigned long)current+PAGE_SIZE))
-                printk("(Possibly corrupted stack page??)\n");
-
-	printk("\n\n");
-}
-
-void die(const char *str, struct pt_regs *fp, unsigned long err)
-{
-	static int diecount;
-
-	oops_enter();
-
-	console_verbose();
-	spin_lock_irq(&die_lock);
-	report_bug(fp->pc, fp);
-	printk(KERN_EMERG "%s: %04lx [#%d] ", str, err & 0xffff, ++diecount);
-	dump(fp);
-
-	spin_unlock_irq(&die_lock);
-	do_exit(SIGSEGV);
-}
-
-extern char _start, _etext;
-#define check_kernel_text(addr) \
-        ((addr >= (unsigned long)(&_start)) && \
-         (addr <  (unsigned long)(&_etext))) 
-
-static int kstack_depth_to_print = 24;
-
-void show_stack(struct task_struct *task, unsigned long *esp)
-{
-	unsigned long *stack,  addr;
-	int i;
-
-	if (esp == NULL)
-		esp = (unsigned long *) &esp;
-
-	stack = esp;
-
-	printk("Stack from %08lx:", (unsigned long)stack);
-	for (i = 0; i < kstack_depth_to_print; i++) {
-		if (((unsigned long)stack & (THREAD_SIZE - 1)) == 0)
-			break;
-		if (i % 8 == 0)
-			printk("\n       ");
-		printk(" %08lx", *stack++);
-	}
-
-	printk("\nCall Trace:");
-	i = 0;
-	stack = esp;
-	while (((unsigned long)stack & (THREAD_SIZE - 1)) != 0) {
-		addr = *stack++;
-		/*
-		 * If the address is either in the text segment of the
-		 * kernel, or in the region which contains vmalloc'ed
-		 * memory, it *may* be the address of a calling
-		 * routine; if so, print it so that someone tracing
-		 * down the cause of the crash will be able to figure
-		 * out the call path that was taken.
-		 */
-		if (check_kernel_text(addr)) {
-			if (i % 4 == 0)
-				printk("\n       ");
-			printk(" [<%08lx>]", addr);
-			i++;
-		}
-	}
-	printk("\n");
-}
-
-void show_trace_task(struct task_struct *tsk)
-{
-	show_stack(tsk,(unsigned long *)tsk->thread.esp0);
-}
diff --git a/arch/h8300/kernel/vmlinux.lds.S b/arch/h8300/kernel/vmlinux.lds.S
deleted file mode 100644
index 3253fed..0000000
--- a/arch/h8300/kernel/vmlinux.lds.S
+++ /dev/null
@@ -1,157 +0,0 @@
-#include <asm-generic/vmlinux.lds.h>
-#include <asm/page.h>
-
-/* target memory map */
-#ifdef CONFIG_H8300H_GENERIC
-#define ROMTOP  0x000000
-#define ROMSIZE 0x400000
-#define RAMTOP  0x400000
-#define RAMSIZE 0x400000
-#endif
-
-#ifdef CONFIG_H8300H_AKI3068NET
-#define ROMTOP  0x000000
-#define ROMSIZE 0x080000
-#define RAMTOP  0x400000
-#define RAMSIZE 0x200000
-#endif
-
-#ifdef CONFIG_H8300H_H8MAX
-#define ROMTOP  0x000000
-#define ROMSIZE 0x080000
-#define RAMTOP  0x400000
-#define RAMSIZE 0x200000
-#endif
-
-#ifdef CONFIG_H8300H_SIM
-#define ROMTOP  0x000000
-#define ROMSIZE 0x400000
-#define RAMTOP  0x400000
-#define RAMSIZE 0x400000
-#endif
-
-#ifdef CONFIG_H8S_SIM
-#define ROMTOP  0x000000
-#define ROMSIZE 0x400000
-#define RAMTOP  0x400000
-#define RAMSIZE 0x800000
-#endif
-
-#ifdef CONFIG_H8S_EDOSK2674
-#define ROMTOP  0x000000
-#define ROMSIZE 0x400000
-#define RAMTOP  0x400000
-#define RAMSIZE 0x800000
-#endif
-
-#if defined(CONFIG_H8300H_SIM) || defined(CONFIG_H8S_SIM)
-INPUT(romfs.o)
-#endif
-
-_jiffies = _jiffies_64 + 4;
-
-ENTRY(__start)
-
-SECTIONS
-{
-#if defined(CONFIG_ROMKERNEL)
-	. = ROMTOP; 
-	.vectors :
-	{
-	__vector = . ;
-		*(.vectors*)
-	}
-#else
-	. = RAMTOP; 
-	.bootvec :	
-	{
-		*(.bootvec)
-	}
-#endif
-        .text :
-	{
-	_text = .;
-#if defined(CONFIG_ROMKERNEL)
-	*(.int_redirect)
-#endif
-	__stext = . ;
-	TEXT_TEXT
-	SCHED_TEXT
-	LOCK_TEXT
-	__etext = . ;
-	}
-	EXCEPTION_TABLE(16)
-
-	RODATA
-#if defined(CONFIG_ROMKERNEL)
-	SECURITY_INIT
-#endif
-	ROEND = .; 
-#if defined(CONFIG_ROMKERNEL)
-	. = RAMTOP;
-	.data :	AT(ROEND)
-#else
-	.data :	
-#endif
-	{
-	__sdata = . ;
-	___data_start = . ;
-
-	INIT_TASK_DATA(0x2000)
-	. = ALIGN(0x4) ;
-		DATA_DATA
-	. = ALIGN(0x4) ;
-		*(.data.*)	
-
-	. = ALIGN(0x4) ;
-	___init_begin = .;
-	__sinittext = .; 
-		INIT_TEXT
-	__einittext = .; 
-		INIT_DATA
-	. = ALIGN(0x4) ;
-	INIT_SETUP(0x4)
-	___setup_start = .;
-		*(.init.setup)
-	. = ALIGN(0x4) ;
-	___setup_end = .;
-	INIT_CALLS
-	CON_INITCALL
-		EXIT_TEXT
-		EXIT_DATA
-	INIT_RAM_FS
-	. = ALIGN(0x4) ;
-	___init_end = .;
-	__edata = . ;
-	}
-#if defined(CONFIG_RAMKERNEL)
-	SECURITY_INIT
-#endif
-	__begin_data = LOADADDR(.data);
-        .bss : 
-        {
-	. = ALIGN(0x4) ;
-	__sbss = . ;
-	___bss_start = . ;
-		*(.bss*)
-	. = ALIGN(0x4) ;
-		*(COMMON)
-	. = ALIGN(0x4) ;
-	___bss_stop = . ;
-	__ebss = . ;
-	__end = . ;
-	__ramstart = .;
-	}
-        .romfs :	
-	{
-		*(.romfs*)
-	}
-	. = RAMTOP+RAMSIZE;
-        .dummy :
-        {
-	COMMAND_START = . - 0x200 ;
-	__ramend = . ;
-	}
-
-	DISCARDS
-}
diff --git a/arch/h8300/lib/Makefile b/arch/h8300/lib/Makefile
deleted file mode 100644
index 1577f507..0000000
--- a/arch/h8300/lib/Makefile
+++ /dev/null
@@ -1,5 +0,0 @@
-#
-# Makefile for H8/300-specific library files..
-#
-
-lib-y  = ashrdi3.o checksum.o memcpy.o memset.o abs.o romfs.o
diff --git a/arch/h8300/lib/abs.S b/arch/h8300/lib/abs.S
deleted file mode 100644
index ddd1fb3..0000000
--- a/arch/h8300/lib/abs.S
+++ /dev/null
@@ -1,21 +0,0 @@
-;;; abs.S
-
-#include <asm/linkage.h>
-
-#if defined(__H8300H__) 
-	.h8300h
-#endif
-#if defined(__H8300S__) 
-	.h8300s
-#endif
-	.text
-.global _abs
-
-;;; int abs(int n)
-_abs:
-	mov.l	er0,er0
-	bpl	1f
-	neg.l	er0
-1:
-	rts
-	
diff --git a/arch/h8300/lib/ashrdi3.c b/arch/h8300/lib/ashrdi3.c
deleted file mode 100644
index 78efb65..0000000
--- a/arch/h8300/lib/ashrdi3.c
+++ /dev/null
@@ -1,63 +0,0 @@
-/* ashrdi3.c extracted from gcc-2.7.2/libgcc2.c which is: */
-/* Copyright (C) 1989, 1992, 1993, 1994, 1995 Free Software Foundation, Inc.
-
-This file is part of GNU CC.
-
-GNU CC is free software; you can redistribute it and/or modify
-it under the terms of the GNU General Public License as published by
-the Free Software Foundation; either version 2, or (at your option)
-any later version.
-
-GNU CC is distributed in the hope that it will be useful,
-but WITHOUT ANY WARRANTY; without even the implied warranty of
-MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-GNU General Public License for more details.
-
-You should have received a copy of the GNU General Public License
-along with GNU CC; see the file COPYING.  If not, write to
-the Free Software Foundation, 59 Temple Place - Suite 330,
-Boston, MA 02111-1307, USA.  */
-
-#define BITS_PER_UNIT 8
-
-typedef 	 int SItype	__attribute__ ((mode (SI)));
-typedef unsigned int USItype	__attribute__ ((mode (SI)));
-typedef		 int DItype	__attribute__ ((mode (DI)));
-typedef int word_type __attribute__ ((mode (__word__)));
-
-struct DIstruct {SItype high, low;};
-
-typedef union
-{
-  struct DIstruct s;
-  DItype ll;
-} DIunion;
-
-DItype
-__ashrdi3 (DItype u, word_type b)
-{
-  DIunion w;
-  word_type bm;
-  DIunion uu;
-
-  if (b == 0)
-    return u;
-
-  uu.ll = u;
-
-  bm = (sizeof (SItype) * BITS_PER_UNIT) - b;
-  if (bm <= 0)
-    {
-      /* w.s.high = 1..1 or 0..0 */
-      w.s.high = uu.s.high >> (sizeof (SItype) * BITS_PER_UNIT - 1);
-      w.s.low = uu.s.high >> -bm;
-    }
-  else
-    {
-      USItype carries = (USItype)uu.s.high << bm;
-      w.s.high = uu.s.high >> b;
-      w.s.low = ((USItype)uu.s.low >> b) | carries;
-    }
-
-  return w.ll;
-}
diff --git a/arch/h8300/lib/checksum.c b/arch/h8300/lib/checksum.c
deleted file mode 100644
index bdc5b03..0000000
--- a/arch/h8300/lib/checksum.c
+++ /dev/null
@@ -1,164 +0,0 @@
-/*
- * INET		An implementation of the TCP/IP protocol suite for the LINUX
- *		operating system.  INET is implemented using the  BSD Socket
- *		interface as the means of communication with the user level.
- *
- *		IP/TCP/UDP checksumming routines
- *
- * Authors:	Jorge Cwik, <jorge@laser.satlink.net>
- *		Arnt Gulbrandsen, <agulbra@nvg.unit.no>
- *		Tom May, <ftom@netcom.com>
- *		Andreas Schwab, <schwab@issan.informatik.uni-dortmund.de>
- *		Lots of code moved from tcp.c and ip.c; see those files
- *		for more names.
- *
- * 03/02/96	Jes Sorensen, Andreas Schwab, Roman Hodek:
- *		Fixed some nasty bugs, causing some horrible crashes.
- *		A: At some points, the sum (%0) was used as
- *		length-counter instead of the length counter
- *		(%1). Thanks to Roman Hodek for pointing this out.
- *		B: GCC seems to mess up if one uses too many
- *		data-registers to hold input values and one tries to
- *		specify d0 and d1 as scratch registers. Letting gcc choose these
- *      registers itself solves the problem.
- *
- *		This program is free software; you can redistribute it and/or
- *		modify it under the terms of the GNU General Public License
- *		as published by the Free Software Foundation; either version
- *		2 of the License, or (at your option) any later version.
- */
- 
-/* Revised by Kenneth Albanowski for m68knommu. Basic problem: unaligned access kills, so most
-   of the assembly has to go. */
-
-#include <net/checksum.h>
-#include <linux/module.h>
-
-static inline unsigned short from32to16(unsigned long x)
-{
-	/* add up 16-bit and 16-bit for 16+c bit */
-	x = (x & 0xffff) + (x >> 16);
-	/* add up carry.. */
-	x = (x & 0xffff) + (x >> 16);
-	return x;
-}
-
-static unsigned long do_csum(const unsigned char * buff, int len)
-{
-	int odd, count;
-	unsigned long result = 0;
-
-	if (len <= 0)
-		goto out;
-	odd = 1 & (unsigned long) buff;
-	if (odd) {
-		result = *buff;
-		len--;
-		buff++;
-	}
-	count = len >> 1;		/* nr of 16-bit words.. */
-	if (count) {
-		if (2 & (unsigned long) buff) {
-			result += *(unsigned short *) buff;
-			count--;
-			len -= 2;
-			buff += 2;
-		}
-		count >>= 1;		/* nr of 32-bit words.. */
-		if (count) {
-		        unsigned long carry = 0;
-			do {
-				unsigned long w = *(unsigned long *) buff;
-				count--;
-				buff += 4;
-				result += carry;
-				result += w;
-				carry = (w > result);
-			} while (count);
-			result += carry;
-			result = (result & 0xffff) + (result >> 16);
-		}
-		if (len & 2) {
-			result += *(unsigned short *) buff;
-			buff += 2;
-		}
-	}
-	if (len & 1)
-		result += (*buff << 8);
-	result = from32to16(result);
-	if (odd)
-		result = ((result >> 8) & 0xff) | ((result & 0xff) << 8);
-out:
-	return result;
-}
-
-/*
- *	This is a version of ip_compute_csum() optimized for IP headers,
- *	which always checksum on 4 octet boundaries.
- */
-__sum16 ip_fast_csum(const void *iph, unsigned int ihl)
-{
-	return (__force __sum16)~do_csum(iph,ihl*4);
-}
-
-/*
- * computes the checksum of a memory block at buff, length len,
- * and adds in "sum" (32-bit)
- *
- * returns a 32-bit number suitable for feeding into itself
- * or csum_tcpudp_magic
- *
- * this function must be called with even lengths, except
- * for the last fragment, which may be odd
- *
- * it's best to have buff aligned on a 32-bit boundary
- */
-/*
- * Egads...  That thing apparently assumes that *all* checksums it ever sees will
- * be folded.  Very likely a bug.
- */
-__wsum csum_partial(const void *buff, int len, __wsum sum)
-{
-	unsigned int result = do_csum(buff, len);
-
-	/* add in old sum, and carry.. */
-	result += (__force u32)sum;
-	/* 16+c bits -> 16 bits */
-	result = (result & 0xffff) + (result >> 16);
-	return (__force __wsum)result;
-}
-
-EXPORT_SYMBOL(csum_partial);
-
-/*
- * this routine is used for miscellaneous IP-like checksums, mainly
- * in icmp.c
- */
-__sum16 ip_compute_csum(const void *buff, int len)
-{
-	return (__force __sum16)~do_csum(buff,len);
-}
-
-/*
- * copy from fs while checksumming, otherwise like csum_partial
- */
-
-__wsum
-csum_partial_copy_from_user(const void __user *src, void *dst, int len,
-			    __wsum sum, int *csum_err)
-{
-	if (csum_err) *csum_err = 0;
-	memcpy(dst, (__force const void *)src, len);
-	return csum_partial(dst, len, sum);
-}
-
-/*
- * copy from ds while checksumming, otherwise like csum_partial
- */
-
-__wsum
-csum_partial_copy_nocheck(const void *src, void *dst, int len, __wsum sum)
-{
-	memcpy(dst, src, len);
-	return csum_partial(dst, len, sum);
-}
diff --git a/arch/h8300/lib/memcpy.S b/arch/h8300/lib/memcpy.S
deleted file mode 100644
index cad325e..0000000
--- a/arch/h8300/lib/memcpy.S
+++ /dev/null
@@ -1,84 +0,0 @@
-;;; memcpy.S
-
-#include <asm/linkage.h>
-
-#if defined(__H8300H__) 
-	.h8300h
-#endif
-#if defined(__H8300S__) 
-	.h8300s
-#endif
-
-	.text
-.global _memcpy
-
-;;; void *memcpy(void *to, void *from, size_t n)
-_memcpy:
-	mov.l	er2,er2
-	bne	1f
-	rts	
-1:	
-	;; address check
-	bld	#0,r0l
-	bxor	#0,r1l
-	bcs	4f
-	mov.l	er4,@-sp
-	mov.l	er0,@-sp
-	btst	#0,r0l
-	beq	1f
-	;; (aligned even) odd address
-	mov.b	@er1,r3l
-	mov.b	r3l,@er0
-	adds	#1,er1
-	adds	#1,er0
-	dec.l	#1,er2
-	beq	3f
-1:	
-	;; n < sizeof(unsigned long) check
-	sub.l	er4,er4
-	adds	#4,er4		; loop count check value
-	cmp.l	er4,er2
-	blo	2f
-	;; unsigned long copy
-1:	
-	mov.l	@er1,er3
-	mov.l	er3,@er0
-	adds	#4,er0
-	adds	#4,er1
-	subs	#4,er2
-	cmp.l	er4,er2
-	bcc	1b	
-	;; rest
-2:	
-	mov.l	er2,er2
-	beq	3f
-1:	
-	mov.b	@er1,r3l
-	mov.b	r3l,@er0
-	adds	#1,er1
-	adds	#1,er0
-	dec.l	#1,er2
-	bne	1b
-3:
-	mov.l	@sp+,er0
-	mov.l	@sp+,er4
-	rts
-
-	;; odd <- even / even <- odd
-4:	
-	mov.l	er4,er3
-	mov.l	er2,er4
-	mov.l	er5,er2
-	mov.l	er1,er5
-	mov.l	er6,er1
-	mov.l	er0,er6
-1:
-	eepmov.w
-	mov.w	r4,r4
-	bne	1b
-	dec.w	#1,e4
-	bpl	1b
-	mov.l	er1,er6
-	mov.l	er2,er5
-	mov.l	er3,er4
-	rts
diff --git a/arch/h8300/lib/memset.S b/arch/h8300/lib/memset.S
deleted file mode 100644
index 4549a64..0000000
--- a/arch/h8300/lib/memset.S
+++ /dev/null
@@ -1,61 +0,0 @@
-/* memset.S */
-
-#include <asm/linkage.h>
-
-#if defined(__H8300H__) 
-	.h8300h
-#endif
-#if defined(__H8300S__) 
-	.h8300s
-#endif
-	.text
-
-.global	_memset
-
-;;void *memset(*ptr, int c, size_t count)
-;; ptr = er0
-;; c   = er1(r1l)
-;; count = er2
-_memset:
-	btst	#0,r0l
-	beq	2f
-
-	;; odd address
-1:
-	mov.b	r1l,@er0
-	adds	#1,er0
-	dec.l	#1,er2
-	beq	6f
-
-	;; even address
-2:
-	mov.l	er2,er3
-	cmp.l	#4,er2
-	blo	4f
-	;; count>=4 -> count/4
-#if defined(__H8300H__)
-	shlr.l	er2
-	shlr.l	er2
-#endif
-#if defined(__H8300S__)
-	shlr.l	#2,er2
-#endif
-	;; byte -> long
-	mov.b	r1l,r1h
-	mov.w	r1,e1
-3:
-	mov.l	er1,@er0
-	adds	#4,er0
-	dec.l	#1,er2
-	bne	3b
-4:
-	;; count % 4
-	and.b	#3,r3l
-	beq	6f
-5:
-	mov.b	r1l,@er0
-	adds	#1,er0
-	dec.b	r3l
-	bne	5b
-6:
-	rts
diff --git a/arch/h8300/lib/romfs.S b/arch/h8300/lib/romfs.S
deleted file mode 100644
index 68910d8..0000000
--- a/arch/h8300/lib/romfs.S
+++ /dev/null
@@ -1,57 +0,0 @@
-/* romfs move to __ebss */
-
-#include <asm/linkage.h>
-
-#if defined(__H8300H__) 
-	.h8300h
-#endif
-#if defined(__H8300S__) 
-	.h8300s
-#endif
-
-#define BLKOFFSET 512
-
-	.text
-.globl	__move_romfs
-_romfs_sig_len = 8
-
-__move_romfs:	
-	mov.l	#__sbss,er0
-	mov.l	#_romfs_sig,er1
-	mov.b	#_romfs_sig_len,r3l
-1:					/* check romfs image */
-	mov.b	@er0+,r2l
-	mov.b	@er1+,r2h
-	cmp.b	r2l,r2h
-	bne	2f
-	dec.b	r3l
-	bne	1b
-
-	/* find romfs image */
-	mov.l	@__sbss+8,er0		/* romfs length(be) */
-	mov.l	#__sbss,er1
-	add.l	er0,er1			/* romfs image end */
-	mov.l	#__ebss,er2
-	add.l	er0,er2			/* distination address */
-#if defined(CONFIG_INTELFLASH)
-	add.l	#BLKOFFSET,er2
-#endif
-	adds	#2,er0
-	adds	#1,er0
-	shlr	er0
-	shlr	er0			/* transfer length */
-1:
-	mov.l	@er1,er3		/* copy image */
-	mov.l	er3,@er2
-	subs	#4,er1
-	subs	#4,er2
-	dec.l	#1,er0
-	bpl	1b
-2:
-	rts
-
-	.section	.rodata
-_romfs_sig:	
-	.ascii	"-rom1fs-"
-
-	.end
diff --git a/arch/h8300/mm/Makefile b/arch/h8300/mm/Makefile
deleted file mode 100644
index 5f4bc42..0000000
--- a/arch/h8300/mm/Makefile
+++ /dev/null
@@ -1,5 +0,0 @@
-#
-# Makefile for the linux m68k-specific parts of the memory manager.
-#
-
-obj-y	 := init.o fault.o memory.o kmap.o
diff --git a/arch/h8300/mm/fault.c b/arch/h8300/mm/fault.c
deleted file mode 100644
index 4725359..0000000
--- a/arch/h8300/mm/fault.c
+++ /dev/null
@@ -1,56 +0,0 @@
-/*
- *  linux/arch/h8300/mm/fault.c
- *
- *  Copyright (C) 1998  D. Jeff Dionne <jeff@lineo.ca>,
- *  Copyright (C) 2000  Lineo, Inc.  (www.lineo.com) 
- *
- *  Based on:
- *
- *  linux/arch/m68knommu/mm/fault.c
- *  linux/arch/m68k/mm/fault.c
- *
- *  Copyright (C) 1995  Hamish Macdonald
- */
-
-#include <linux/mman.h>
-#include <linux/mm.h>
-#include <linux/kernel.h>
-#include <linux/ptrace.h>
-
-#include <asm/pgtable.h>
-
-/*
- * This routine handles page faults.  It determines the problem, and
- * then passes it off to one of the appropriate routines.
- *
- * error_code:
- *	bit 0 == 0 means no page found, 1 means protection fault
- *	bit 1 == 0 means read, 1 means write
- *
- * If this routine detects a bad access, it returns 1, otherwise it
- * returns 0.
- */
-asmlinkage int do_page_fault(struct pt_regs *regs, unsigned long address,
-			      unsigned long error_code)
-{
-#ifdef DEBUG
-	printk ("regs->sr=%#x, regs->pc=%#lx, address=%#lx, %ld\n",
-		regs->sr, regs->pc, address, error_code);
-#endif
-
-/*
- * Oops. The kernel tried to access some bad page. We'll have to
- * terminate things with extreme prejudice.
- */
-	if ((unsigned long) address < PAGE_SIZE) {
-		printk(KERN_ALERT "Unable to handle kernel NULL pointer dereference");
-	} else
-		printk(KERN_ALERT "Unable to handle kernel access");
-	printk(" at virtual address %08lx\n",address);
-	if (!user_mode(regs))
-		die("Oops", regs, error_code);
-	do_exit(SIGKILL);
-
-	return 1;
-}
-
diff --git a/arch/h8300/mm/init.c b/arch/h8300/mm/init.c
deleted file mode 100644
index 6c1251e..0000000
--- a/arch/h8300/mm/init.c
+++ /dev/null
@@ -1,155 +0,0 @@
-/*
- *  linux/arch/h8300/mm/init.c
- *
- *  Copyright (C) 1998  D. Jeff Dionne <jeff@lineo.ca>,
- *                      Kenneth Albanowski <kjahds@kjahds.com>,
- *  Copyright (C) 2000  Lineo, Inc.  (www.lineo.com) 
- *
- *  Based on:
- *
- *  linux/arch/m68knommu/mm/init.c
- *  linux/arch/m68k/mm/init.c
- *
- *  Copyright (C) 1995  Hamish Macdonald
- *
- *  JAN/1999 -- hacked to support ColdFire (gerg@snapgear.com)
- *  DEC/2000 -- linux 2.4 support <davidm@snapgear.com>
- */
-
-#include <linux/signal.h>
-#include <linux/sched.h>
-#include <linux/kernel.h>
-#include <linux/errno.h>
-#include <linux/string.h>
-#include <linux/types.h>
-#include <linux/ptrace.h>
-#include <linux/mman.h>
-#include <linux/mm.h>
-#include <linux/swap.h>
-#include <linux/init.h>
-#include <linux/highmem.h>
-#include <linux/pagemap.h>
-#include <linux/bootmem.h>
-#include <linux/gfp.h>
-
-#include <asm/setup.h>
-#include <asm/segment.h>
-#include <asm/page.h>
-#include <asm/pgtable.h>
-#include <asm/sections.h>
-
-#undef DEBUG
-
-/*
- * BAD_PAGE is the page that is used for page faults when linux
- * is out-of-memory. Older versions of linux just did a
- * do_exit(), but using this instead means there is less risk
- * for a process dying in kernel mode, possibly leaving a inode
- * unused etc..
- *
- * BAD_PAGETABLE is the accompanying page-table: it is initialized
- * to point to BAD_PAGE entries.
- *
- * ZERO_PAGE is a special page that is used for zero-initialized
- * data and COW.
- */
-static unsigned long empty_bad_page_table;
-
-static unsigned long empty_bad_page;
-
-unsigned long empty_zero_page;
-
-extern unsigned long rom_length;
-
-extern unsigned long memory_start;
-extern unsigned long memory_end;
-
-/*
- * paging_init() continues the virtual memory environment setup which
- * was begun by the code in arch/head.S.
- * The parameters are pointers to where to stick the starting and ending
- * addresses of available kernel virtual memory.
- */
-void __init paging_init(void)
-{
-	/*
-	 * Make sure start_mem is page aligned,  otherwise bootmem and
-	 * page_alloc get different views og the world.
-	 */
-#ifdef DEBUG
-	unsigned long start_mem = PAGE_ALIGN(memory_start);
-#endif
-	unsigned long end_mem   = memory_end & PAGE_MASK;
-
-#ifdef DEBUG
-	printk ("start_mem is %#lx\nvirtual_end is %#lx\n",
-		start_mem, end_mem);
-#endif
-
-	/*
-	 * Initialize the bad page table and bad page to point
-	 * to a couple of allocated pages.
-	 */
-	empty_bad_page_table = (unsigned long)alloc_bootmem_pages(PAGE_SIZE);
-	empty_bad_page = (unsigned long)alloc_bootmem_pages(PAGE_SIZE);
-	empty_zero_page = (unsigned long)alloc_bootmem_pages(PAGE_SIZE);
-	memset((void *)empty_zero_page, 0, PAGE_SIZE);
-
-	/*
-	 * Set up SFC/DFC registers (user data space).
-	 */
-	set_fs (USER_DS);
-
-#ifdef DEBUG
-	printk ("before free_area_init\n");
-
-	printk ("free_area_init -> start_mem is %#lx\nvirtual_end is %#lx\n",
-		start_mem, end_mem);
-#endif
-
-	{
-		unsigned long zones_size[MAX_NR_ZONES] = {0, };
-
-		zones_size[ZONE_DMA]     = 0 >> PAGE_SHIFT;
-		zones_size[ZONE_NORMAL]  = (end_mem - PAGE_OFFSET) >> PAGE_SHIFT;
-#ifdef CONFIG_HIGHMEM
-		zones_size[ZONE_HIGHMEM] = 0;
-#endif
-		free_area_init(zones_size);
-	}
-}
-
-void __init mem_init(void)
-{
-	unsigned long codesize = _etext - _stext;
-
-	pr_devel("Mem_init: start=%lx, end=%lx\n", memory_start, memory_end);
-
-	high_memory = (void *) (memory_end & PAGE_MASK);
-	max_mapnr = MAP_NR(high_memory);
-
-	/* this will put all low memory onto the freelists */
-	free_all_bootmem();
-
-	mem_init_print_info(NULL);
-	if (rom_length > 0 && rom_length > codesize)
-		pr_info("Memory available: %luK/%luK ROM\n",
-			(rom_length - codesize) >> 10, rom_length >> 10);
-}
-
-
-#ifdef CONFIG_BLK_DEV_INITRD
-void free_initrd_mem(unsigned long start, unsigned long end)
-{
-	free_reserved_area((void *)start, (void *)end, -1, "initrd");
-}
-#endif
-
-void
-free_initmem(void)
-{
-#ifdef CONFIG_RAMKERNEL
-	free_initmem_default(-1);
-#endif
-}
-
diff --git a/arch/h8300/mm/kmap.c b/arch/h8300/mm/kmap.c
deleted file mode 100644
index f79edcd..0000000
--- a/arch/h8300/mm/kmap.c
+++ /dev/null
@@ -1,58 +0,0 @@
-/*
- *  linux/arch/h8300/mm/kmap.c
- *  
- *  Based on
- *  linux/arch/m68knommu/mm/kmap.c
- *
- *  Copyright (C) 2000 Lineo, <davidm@snapgear.com>
- *  Copyright (C) 2000-2002 David McCullough <davidm@snapgear.com>
- */
-
-#include <linux/mm.h>
-#include <linux/kernel.h>
-#include <linux/string.h>
-#include <linux/types.h>
-#include <linux/vmalloc.h>
-
-#include <asm/setup.h>
-#include <asm/segment.h>
-#include <asm/page.h>
-#include <asm/pgalloc.h>
-#include <asm/io.h>
-
-#undef DEBUG
-
-#define VIRT_OFFSET (0x01000000)
-
-/*
- * Map some physical address range into the kernel address space.
- */
-void *__ioremap(unsigned long physaddr, unsigned long size, int cacheflag)
-{
-	return (void *)(physaddr + VIRT_OFFSET);
-}
-
-/*
- * Unmap a ioremap()ed region again.
- */
-void iounmap(void *addr)
-{
-}
-
-/*
- * __iounmap unmaps nearly everything, so be careful
- * it doesn't free currently pointer/page tables anymore but it
- * wans't used anyway and might be added later.
- */
-void __iounmap(void *addr, unsigned long size)
-{
-}
-
-/*
- * Set new cache mode for some kernel address space.
- * The caller must push data for that range itself, if such data may already
- * be in the cache.
- */
-void kernel_set_cachemode(void *addr, unsigned long size, int cmode)
-{
-}
diff --git a/arch/h8300/mm/memory.c b/arch/h8300/mm/memory.c
deleted file mode 100644
index 06e3646..0000000
--- a/arch/h8300/mm/memory.c
+++ /dev/null
@@ -1,54 +0,0 @@
-/*
- *  linux/arch/h8300/mm/memory.c
- *
- *  Copyright (C) 2002  Yoshinori Sato <ysato@users.sourceforge.jp>,
- *
- *  Based on:
- *
- *  linux/arch/m68knommu/mm/memory.c
- *
- *  Copyright (C) 1998  Kenneth Albanowski <kjahds@kjahds.com>,
- *  Copyright (C) 1999-2002, Greg Ungerer (gerg@snapgear.com)
- *
- *  Based on:
- *
- *  linux/arch/m68k/mm/memory.c
- *
- *  Copyright (C) 1995  Hamish Macdonald
- */
-
-#include <linux/mm.h>
-#include <linux/kernel.h>
-#include <linux/string.h>
-#include <linux/types.h>
-
-#include <asm/setup.h>
-#include <asm/segment.h>
-#include <asm/page.h>
-#include <asm/pgtable.h>
-#include <asm/traps.h>
-#include <asm/io.h>
-
-void cache_clear (unsigned long paddr, int len)
-{
-}
-
-
-void cache_push (unsigned long paddr, int len)
-{
-}
-
-void cache_push_v (unsigned long vaddr, int len)
-{
-}
-
-/*
- * Map some physical address range into the kernel address space.
- */
-
-unsigned long kernel_map(unsigned long paddr, unsigned long size,
-			 int nocacheflag, unsigned long *memavailp )
-{
-	return paddr;
-}
-
diff --git a/arch/h8300/platform/h8300h/Makefile b/arch/h8300/platform/h8300h/Makefile
deleted file mode 100644
index 420f73b..0000000
--- a/arch/h8300/platform/h8300h/Makefile
+++ /dev/null
@@ -1,7 +0,0 @@
-#
-# Makefile for the linux kernel.
-#
-# Reuse any files we can from the H8/300H
-#
-
-obj-y := irq.o ptrace_h8300h.o
diff --git a/arch/h8300/platform/h8300h/aki3068net/Makefile b/arch/h8300/platform/h8300h/aki3068net/Makefile
deleted file mode 100644
index b7ff780..0000000
--- a/arch/h8300/platform/h8300h/aki3068net/Makefile
+++ /dev/null
@@ -1,5 +0,0 @@
-#
-# Makefile for the linux kernel.
-#
-
-extra-y := crt0_ram.o
diff --git a/arch/h8300/platform/h8300h/aki3068net/crt0_ram.S b/arch/h8300/platform/h8300h/aki3068net/crt0_ram.S
deleted file mode 100644
index b2ad0f2..0000000
--- a/arch/h8300/platform/h8300h/aki3068net/crt0_ram.S
+++ /dev/null
@@ -1,110 +0,0 @@
-/*
- *  linux/arch/h8300/platform/h8300h/aki3068net/crt0_ram.S
- *
- *  Yoshinori Sato <ysato@users.sourceforge.jp>
- *
- *  Platform depend startup
- *  Target Archtecture:	AE-3068 (aka. aki3068net)
- *  Memory Layout     :	RAM
- */
-
-#define ASSEMBLY
-
-#include <asm/linkage.h>
-	
-#if !defined(CONFIG_BLKDEV_RESERVE)
-#if defined(CONFIG_GDB_DEBUG)
-#define RAMEND (__ramend - 0xc000)
-#else
-#define RAMEND __ramend
-#endif
-#else
-#define RAMEND CONFIG_BLKDEV_RESERVE_ADDRESS
-#endif
-	
-	.global __start
-	.global _command_line
-	.global __platform_gpio_table
-	.global __target_name
-	
-	.h8300h
-
-	.section .text
-	.file	"crt0_ram.S"
-
-	/* CPU Reset entry */
-__start:
-	mov.l	#RAMEND,sp
-	ldc	#0x80,ccr
-
-	/* Peripheral Setup */
-	
-#if defined(CONFIG_MTD_UCLINUX)
-	/* move romfs image */
-	jsr	@__move_romfs	
-#endif
-	
-	/* .bss clear */
-	mov.l	#__sbss,er5
-	mov.l	#__ebss,er4
-	sub.l	er5,er4
-	shlr	er4
-	shlr	er4
-	sub.l	er0,er0
-1:	
-	mov.l	er0,@er5
-	adds	#4,er5
-	dec.l	#1,er4
-	bne	1b
-
-	/* copy kernel commandline */
-	mov.l	#COMMAND_START,er5
-	mov.l	#_command_line,er6
-	mov.w	#512,r4
-	eepmov.w
-
-	/* uClinux kernel start */
-	ldc	#0x90,ccr	/* running kernel */
-	mov.l	#_init_thread_union,sp
-	add.l	#0x2000,sp
-	jsr	@_start_kernel
-_exit:
-
-	jmp	_exit
-
-	rts
-
-	/* I/O port assign information */
-__platform_gpio_table:	
-	mov.l	#gpio_table,er0
-	rts
-
-gpio_table:
-	;; P1DDR
-	.byte	0xff,0xff
-	;; P2DDR
-	.byte	0xff,0xff
-	;; P3DDR
-	.byte	0xff,0x00
-	;; P4DDR
-	.byte	0x00,0x00
-	;; P5DDR
-	.byte	0x01,0x01
-	;; P6DDR
-	.byte	0x00,0x00
-	;; dummy
-	.byte	0x00,0x00
-	;; P8DDR
-	.byte	0x0c,0x0c
-	;; P9DDR
-	.byte	0x00,0x00
-	;; PADDR
-	.byte	0x00,0x00
-	;; PBDDR
-	.byte	0x30,0x30
-
-__target_name:	
-	.asciz	"AE-3068"
-	
-	.section .bootvec,"ax"
-	jmp	@__start
diff --git a/arch/h8300/platform/h8300h/generic/Makefile b/arch/h8300/platform/h8300h/generic/Makefile
deleted file mode 100644
index 2b12a17..0000000
--- a/arch/h8300/platform/h8300h/generic/Makefile
+++ /dev/null
@@ -1,5 +0,0 @@
-#
-# Makefile for the linux kernel.
-#
-
-extra-y :=  crt0_$(MODEL).o
diff --git a/arch/h8300/platform/h8300h/generic/crt0_ram.S b/arch/h8300/platform/h8300h/generic/crt0_ram.S
deleted file mode 100644
index 5ab7d9c..0000000
--- a/arch/h8300/platform/h8300h/generic/crt0_ram.S
+++ /dev/null
@@ -1,107 +0,0 @@
-/*
- *  linux/arch/h8300/platform/h8300h/generic/crt0_ram.S
- *
- *  Yoshinori Sato <ysato@users.sourceforge.jp>
- *
- *  Platform depend startup
- *  Target Archtecture:	AE-3068 (aka. aki3068net)
- *  Memory Layout     :	RAM
- */
-
-#define ASSEMBLY
-
-#include <asm/linkage.h>
-	
-#if !defined(CONFIG_BLKDEV_RESERVE)
-#if defined(CONFIG_GDB_DEBUG)
-#define RAMEND (__ramend - 0xc000)
-#else
-#define RAMEND __ramend
-#endif
-#else
-#define RAMEND CONFIG_BLKDEV_RESERVE_ADDRESS
-#endif
-	
-	.global __start
-	.global _command_line
-	.global __platform_gpio_table
-	.global __target_name
-	
-	.h8300h
-
-	.section .text
-	.file	"crt0_ram.S"
-
-	/* CPU Reset entry */
-__start:
-	mov.l	#RAMEND,sp
-	ldc	#0x80,ccr
-
-	/* Peripheral Setup */
-	
-#if defined(CONFIG_BLK_DEV_BLKMEM)
-	/* move romfs image */
-	jsr	@__move_romfs	
-#endif
-	
-	/* .bss clear */
-	mov.l	#__sbss,er5
-	mov.l	#__ebss,er4
-	sub.l	er5,er4
-	shlr	er4
-	shlr	er4
-	sub.l	er0,er0
-1:	
-	mov.l	er0,@er5
-	adds	#4,er5
-	dec.l	#1,er4
-	bne	1b
-
-	/* copy kernel commandline */
-	mov.l	#COMMAND_START,er5
-	mov.l	#_command_line,er6
-	mov.w	#512,r4
-	eepmov.w
-
-	/* uClinux kernel start */
-	ldc	#0x90,ccr	/* running kernel */
-	mov.l	#_init_thread_union,sp
-	add.l	#0x2000,sp
-	jsr	@_start_kernel
-_exit:
-
-	jmp	_exit
-
-	rts
-
-	/* I/O port assign information */
-__platform_gpio_table:	
-	mov.l	#gpio_table,er0
-	rts
-
-gpio_table:
-	;; P1DDR
-	.byte	0x00,0x00
-	;; P2DDR
-	.byte	0x00,0x00
-	;; P3DDR
-	.byte	0x00,0x00
-	;; P4DDR
-	.byte	0x00,0x00
-	;; P5DDR
-	.byte	0x00,0x00
-	;; P6DDR
-	.byte	0x00,0x00
-	;; dummy
-	.byte	0x00,0x00
-	;; P8DDR
-	.byte	0x00,0x00
-	;; P9DDR
-	.byte	0x00,0x00
-	;; PADDR
-	.byte	0x00,0x00
-	;; PBDDR
-	.byte	0x00,0x00
-
-__target_name:	
-	.asciz	"generic"
diff --git a/arch/h8300/platform/h8300h/generic/crt0_rom.S b/arch/h8300/platform/h8300h/generic/crt0_rom.S
deleted file mode 100644
index dda1dfa..0000000
--- a/arch/h8300/platform/h8300h/generic/crt0_rom.S
+++ /dev/null
@@ -1,122 +0,0 @@
-/*
- *  linux/arch/h8300/platform/h8300h/generic/crt0_rom.S
- *
- *  Yoshinori Sato <ysato@users.sourceforge.jp>
- *
- *  Platform depend startup
- *  Target Archtecture:	generic
- *  Memory Layout     :	ROM
- */
-
-#define ASSEMBLY
-
-#include <asm/linkage.h>
-	
-	.global __start
-	.global __command_line
-	.global __platform_gpio_table
-	.global __target_name
-	
-	.h8300h
-	.section .text
-	.file	"crt0_rom.S"
-
-	/* CPU Reset entry */
-__start:
-	mov.l	#__ramend,sp
-	ldc	#0x80,ccr
-
-	/* Peripheral Setup */
-	
-	/* .bss clear */
-	mov.l	#__sbss,er5
-	mov.l	#__ebss,er4
-	sub.l	er5,er4
-	shlr	er4
-	shlr	er4
-	sub.l	er0,er0
-1:	
-	mov.l	er0,@er5
-	adds	#4,er5
-	dec.l	#1,er4
-	bne	1b
-
-	/* copy .data */
-#if !defined(CONFIG_H8300H_SIM)
-	/* copy .data */
-	mov.l	#__begin_data,er5
-	mov.l	#__sdata,er6
-	mov.l	#__edata,er4
-	sub.l	er6,er4
-	shlr.l	er4
-	shlr.l	er4
-1:	
-	mov.l	@er5+,er0
-	mov.l	er0,@er6
-	adds	#4,er6
-	dec.l	#1,er4
-	bne	1b	
-#endif
-
-	/* copy kernel commandline */
-	mov.l	#COMMAND_START,er5
-	mov.l	#__command_line,er6
-	mov.w	#512,r4
-	eepmov.w
-
-	/* linux kernel start */
-	ldc	#0x90,ccr	/* running kernel */
-	mov.l	#_init_thread_union,sp
-	add.l	#0x2000,sp
-	jsr	@_start_kernel
-_exit:
-
-	jmp	_exit
-
-	rts
-
-	/* I/O port assign information */
-__platform_gpio_table:	
-	mov.l	#gpio_table,er0
-	rts
-
-gpio_table:
-	;; P1DDR
-	.byte	0x00,0x00
-	;; P2DDR
-	.byte	0x00,0x00
-	;; P3DDR
-	.byte	0x00,0x00
-	;; P4DDR
-	.byte	0x00,0x00
-	;; P5DDR
-	.byte	0x00,0x00
-	;; P6DDR
-	.byte	0x00,0x00
-	;; dummy
-	.byte	0x00,0x00
-	;; P8DDR
-	.byte	0x00,0x00
-	;; P9DDR
-	.byte	0x00,0x00
-	;; PADDR
-	.byte	0x00,0x00
-	;; PBDDR
-	.byte	0x00,0x00
-
-	.section .rodata
-__target_name:	
-	.asciz	"generic"
-	
-	.section .bss
-__command_line:	
-	.space	512
-
-	/* interrupt vector */
-	.section .vectors,"ax"
-	.long	__start
-vector	=	1
-	.rept	64-1
-	.long	_interrupt_redirect_table+vector*4
-vector	=	vector + 1
-	.endr
diff --git a/arch/h8300/platform/h8300h/h8max/Makefile b/arch/h8300/platform/h8300h/h8max/Makefile
deleted file mode 100644
index b7ff780..0000000
--- a/arch/h8300/platform/h8300h/h8max/Makefile
+++ /dev/null
@@ -1,5 +0,0 @@
-#
-# Makefile for the linux kernel.
-#
-
-extra-y := crt0_ram.o
diff --git a/arch/h8300/platform/h8300h/h8max/crt0_ram.S b/arch/h8300/platform/h8300h/h8max/crt0_ram.S
deleted file mode 100644
index 6a0d4e2..0000000
--- a/arch/h8300/platform/h8300h/h8max/crt0_ram.S
+++ /dev/null
@@ -1,110 +0,0 @@
-/*
- *  linux/arch/h8300/platform/h8300h/h8max/crt0_ram.S
- *
- *  Yoshinori Sato <ysato@users.sourceforge.jp>
- *
- *  Platform depend startup
- *  Target Archtecture:	H8MAX
- *  Memory Layout     :	RAM
- */
-
-#define ASSEMBLY
-
-#include <asm/linkage.h>
-	
-#if !defined(CONFIG_BLKDEV_RESERVE)
-#if defined(CONFIG_GDB_DEBUG)
-#define RAMEND (__ramend - 0xc000)
-#else
-#define RAMEND __ramend
-#endif
-#else
-#define RAMEND CONFIG_BLKDEV_RESERVE_ADDRESS
-#endif
-	
-	.global __start
-	.global _command_line
-	.global __platform_gpio_table
-	.global __target_name
-	
-	.h8300h
-
-	.section .text
-	.file	"crt0_ram.S"
-
-	/* CPU Reset entry */
-__start:
-	mov.l	#RAMEND,sp
-	ldc	#0x80,ccr
-
-	/* Peripheral Setup */
-	
-#if defined(CONFIG_MTD_UCLINUX)
-	/* move romfs image */
-	jsr	@__move_romfs	
-#endif
-	
-	/* .bss clear */
-	mov.l	#__sbss,er5
-	mov.l	#__ebss,er4
-	sub.l	er5,er4
-	shlr	er4
-	shlr	er4
-	sub.l	er0,er0
-1:	
-	mov.l	er0,@er5
-	adds	#4,er5
-	dec.l	#1,er4
-	bne	1b
-
-	/* copy kernel commandline */
-	mov.l	#COMMAND_START,er5
-	mov.l	#_command_line,er6
-	mov.w	#512,r4
-	eepmov.w
-
-	/* uClinux kernel start */
-	ldc	#0x90,ccr	/* running kernel */
-	mov.l	#_init_thread_union,sp
-	add.l	#0x2000,sp
-	jsr	@_start_kernel
-_exit:
-
-	jmp	_exit
-
-	rts
-
-	/* I/O port assign information */
-__platform_gpio_table:	
-	mov.l	#gpio_table,er0
-	rts
-
-gpio_table:
-	;; P1DDR
-	.byte	0xff,0xff
-	;; P2DDR
-	.byte	0xff,0xff
-	;; P3DDR
-	.byte	0x00,0x00
-	;; P4DDR
-	.byte	0x00,0x00
-	;; P5DDR
-	.byte	0x01,0x01
-	;; P6DDR
-	.byte	0xf6,0xf6
-	;; dummy
-	.byte	0x00,0x00
-	;; P8DDR
-	.byte	0xee,0xee
-	;; P9DDR
-	.byte	0x00,0x00
-	;; PADDR
-	.byte	0x00,0x00
-	;; PBDDR
-	.byte	0x30,0x30
-
-__target_name:	
-	.asciz	"H8MAX"
-	
-	.section .bootvec,"ax"
-	jmp	@__start
diff --git a/arch/h8300/platform/h8300h/irq.c b/arch/h8300/platform/h8300h/irq.c
deleted file mode 100644
index 0a50353..0000000
--- a/arch/h8300/platform/h8300h/irq.c
+++ /dev/null
@@ -1,82 +0,0 @@
-/*
- * Interrupt handling H8/300H depend.
- * Yoshinori Sato <ysato@users.sourceforge.jp>
- *
- */
-
-#include <linux/init.h>
-#include <linux/errno.h>
-
-#include <asm/ptrace.h>
-#include <asm/traps.h>
-#include <asm/irq.h>
-#include <asm/io.h>
-#include <asm/gpio-internal.h>
-#include <asm/regs306x.h>
-
-const int __initconst h8300_saved_vectors[] = {
-#if defined(CONFIG_GDB_DEBUG)
-	TRAP3_VEC,	/* TRAPA #3 is GDB breakpoint */
-#endif
-	-1,
-};
-
-const h8300_vector __initconst h8300_trap_table[] = {
-	0, 0, 0, 0, 0, 0, 0, 0,
-	system_call,
-	0,
-	0,
-	trace_break,
-};
-
-int h8300_enable_irq_pin(unsigned int irq)
-{
-	int bitmask;
-	if (irq < EXT_IRQ0 || irq > EXT_IRQ5)
-		return 0;
-
-	/* initialize IRQ pin */
-	bitmask = 1 << (irq - EXT_IRQ0);
-	switch(irq) {
-	case EXT_IRQ0:
-	case EXT_IRQ1:
-	case EXT_IRQ2:
-	case EXT_IRQ3:
-		if (H8300_GPIO_RESERVE(H8300_GPIO_P8, bitmask) == 0)
-			return -EBUSY;
-		H8300_GPIO_DDR(H8300_GPIO_P8, bitmask, H8300_GPIO_INPUT);
-		break;
-	case EXT_IRQ4:
-	case EXT_IRQ5:
-		if (H8300_GPIO_RESERVE(H8300_GPIO_P9, bitmask) == 0)
-			return -EBUSY;
-		H8300_GPIO_DDR(H8300_GPIO_P9, bitmask, H8300_GPIO_INPUT);
-		break;
-	}
-
-	return 0;
-}
-
-void h8300_disable_irq_pin(unsigned int irq)
-{
-	int bitmask;
-	if (irq < EXT_IRQ0 || irq > EXT_IRQ5)
-		return;
-
-	/* disable interrupt & release IRQ pin */
-	bitmask = 1 << (irq - EXT_IRQ0);
-	switch(irq) {
-	case EXT_IRQ0:
-	case EXT_IRQ1:
-	case EXT_IRQ2:
-	case EXT_IRQ3:
-		*(volatile unsigned char *)IER &= ~bitmask;
-		H8300_GPIO_FREE(H8300_GPIO_P8, bitmask);
-		break ;
-	case EXT_IRQ4:
-	case EXT_IRQ5:
-		*(volatile unsigned char *)IER &= ~bitmask;
-		H8300_GPIO_FREE(H8300_GPIO_P9, bitmask);
-		break;
-	}
-}
diff --git a/arch/h8300/platform/h8300h/ptrace_h8300h.c b/arch/h8300/platform/h8300h/ptrace_h8300h.c
deleted file mode 100644
index 4f1ed02..0000000
--- a/arch/h8300/platform/h8300h/ptrace_h8300h.c
+++ /dev/null
@@ -1,284 +0,0 @@
-/*
- *  linux/arch/h8300/platform/h8300h/ptrace_h8300h.c
- *    ptrace cpu depend helper functions
- *
- *  Yoshinori Sato <ysato@users.sourceforge.jp>
- *
- * This file is subject to the terms and conditions of the GNU General
- * Public License.  See the file COPYING in the main directory of
- * this archive for more details.
- */
-
-#include <linux/linkage.h>
-#include <linux/sched.h>
-#include <asm/ptrace.h>
-
-#define CCR_MASK 0x6f    /* mode/imask not set */
-#define BREAKINST 0x5730 /* trapa #3 */
-
-/* Mapping from PT_xxx to the stack offset at which the register is
-   saved.  Notice that usp has no stack-slot and needs to be treated
-   specially (see get_reg/put_reg below). */
-static const int h8300_register_offset[] = {
-	PT_REG(er1), PT_REG(er2), PT_REG(er3), PT_REG(er4),
-	PT_REG(er5), PT_REG(er6), PT_REG(er0), PT_REG(orig_er0),
-	PT_REG(ccr), PT_REG(pc)
-};
-
-/* read register */
-long h8300_get_reg(struct task_struct *task, int regno)
-{
-	switch (regno) {
-	case PT_USP:
-		return task->thread.usp + sizeof(long)*2;
-	case PT_CCR:
-	    return *(unsigned short *)(task->thread.esp0 + h8300_register_offset[regno]);
-	default:
-	    return *(unsigned long *)(task->thread.esp0 + h8300_register_offset[regno]);
-	}
-}
-
-/* write register */
-int h8300_put_reg(struct task_struct *task, int regno, unsigned long data)
-{
-	unsigned short oldccr;
-	switch (regno) {
-	case PT_USP:
-		task->thread.usp = data - sizeof(long)*2;
-	case PT_CCR:
-		oldccr = *(unsigned short *)(task->thread.esp0 + h8300_register_offset[regno]);
-		oldccr &= ~CCR_MASK;
-		data &= CCR_MASK;
-		data |= oldccr;
-		*(unsigned short *)(task->thread.esp0 + h8300_register_offset[regno]) = data;
-		break;
-	default:
-		*(unsigned long *)(task->thread.esp0 + h8300_register_offset[regno]) = data;
-		break;
-	}
-	return 0;
-}
-
-/* disable singlestep */
-void user_disable_single_step(struct task_struct *child)
-{
-	if((long)child->thread.breakinfo.addr != -1L) {
-		*child->thread.breakinfo.addr = child->thread.breakinfo.inst;
-		child->thread.breakinfo.addr = (unsigned short *)-1L;
-	}
-}
-
-/* calculate next pc */
-enum jump_type {none,    /* normal instruction */
-		jabs,    /* absolute address jump */
-		ind,     /* indirect address jump */
-		ret,     /* return to subrutine */
-		reg,     /* register indexed jump */
-		relb,    /* pc relative jump (byte offset) */
-		relw,    /* pc relative jump (word offset) */
-               };
-
-/* opcode decode table define
-   ptn: opcode pattern
-   msk: opcode bitmask
-   len: instruction length (<0 next table index)
-   jmp: jump operation mode */
-struct optable {
-	unsigned char bitpattern;
-	unsigned char bitmask;
-	signed char length;
-	signed char type;
-} __attribute__((aligned(1),packed));
-
-#define OPTABLE(ptn,msk,len,jmp)   \
-        {                          \
-		.bitpattern = ptn, \
-		.bitmask    = msk, \
-		.length	    = len, \
-		.type       = jmp, \
-	}
-
-static const struct optable optable_0[] = {
-	OPTABLE(0x00,0xff, 1,none), /* 0x00 */
-	OPTABLE(0x01,0xff,-1,none), /* 0x01 */
-	OPTABLE(0x02,0xfe, 1,none), /* 0x02-0x03 */
-	OPTABLE(0x04,0xee, 1,none), /* 0x04-0x05/0x14-0x15 */
-	OPTABLE(0x06,0xfe, 1,none), /* 0x06-0x07 */
-	OPTABLE(0x08,0xea, 1,none), /* 0x08-0x09/0x0c-0x0d/0x18-0x19/0x1c-0x1d */
-	OPTABLE(0x0a,0xee, 1,none), /* 0x0a-0x0b/0x1a-0x1b */
-	OPTABLE(0x0e,0xee, 1,none), /* 0x0e-0x0f/0x1e-0x1f */
-	OPTABLE(0x10,0xfc, 1,none), /* 0x10-0x13 */
-	OPTABLE(0x16,0xfe, 1,none), /* 0x16-0x17 */
-	OPTABLE(0x20,0xe0, 1,none), /* 0x20-0x3f */
-	OPTABLE(0x40,0xf0, 1,relb), /* 0x40-0x4f */
-	OPTABLE(0x50,0xfc, 1,none), /* 0x50-0x53 */
-	OPTABLE(0x54,0xfd, 1,ret ), /* 0x54/0x56 */
-	OPTABLE(0x55,0xff, 1,relb), /* 0x55 */
-	OPTABLE(0x57,0xff, 1,none), /* 0x57 */
-	OPTABLE(0x58,0xfb, 2,relw), /* 0x58/0x5c */
-	OPTABLE(0x59,0xfb, 1,reg ), /* 0x59/0x5b */
-	OPTABLE(0x5a,0xfb, 2,jabs), /* 0x5a/0x5e */
-	OPTABLE(0x5b,0xfb, 2,ind ), /* 0x5b/0x5f */
-	OPTABLE(0x60,0xe8, 1,none), /* 0x60-0x67/0x70-0x77 */
-	OPTABLE(0x68,0xfa, 1,none), /* 0x68-0x69/0x6c-0x6d */
-	OPTABLE(0x6a,0xfe,-2,none), /* 0x6a-0x6b */
-	OPTABLE(0x6e,0xfe, 2,none), /* 0x6e-0x6f */
-	OPTABLE(0x78,0xff, 4,none), /* 0x78 */
-	OPTABLE(0x79,0xff, 2,none), /* 0x79 */
-	OPTABLE(0x7a,0xff, 3,none), /* 0x7a */
-	OPTABLE(0x7b,0xff, 2,none), /* 0x7b */
-	OPTABLE(0x7c,0xfc, 2,none), /* 0x7c-0x7f */
-	OPTABLE(0x80,0x80, 1,none), /* 0x80-0xff */
-};
-
-static const struct optable optable_1[] = {
-	OPTABLE(0x00,0xff,-3,none), /* 0x0100 */
-	OPTABLE(0x40,0xf0,-3,none), /* 0x0140-0x14f */
-	OPTABLE(0x80,0xf0, 1,none), /* 0x0180-0x018f */
-	OPTABLE(0xc0,0xc0, 2,none), /* 0x01c0-0x01ff */
-};
-
-static const struct optable optable_2[] = {
-	OPTABLE(0x00,0x20, 2,none), /* 0x6a0?/0x6a8?/0x6b0?/0x6b8? */
-	OPTABLE(0x20,0x20, 3,none), /* 0x6a2?/0x6aa?/0x6b2?/0x6ba? */
-};
-
-static const struct optable optable_3[] = {
-	OPTABLE(0x69,0xfb, 2,none), /* 0x010069/0x01006d/014069/0x01406d */
-	OPTABLE(0x6b,0xff,-4,none), /* 0x01006b/0x01406b */
-	OPTABLE(0x6f,0xff, 3,none), /* 0x01006f/0x01406f */
-	OPTABLE(0x78,0xff, 5,none), /* 0x010078/0x014078 */
-};
-
-static const struct optable optable_4[] = {
-	OPTABLE(0x00,0x78, 3,none), /* 0x0100690?/0x01006d0?/0140690/0x01406d0?/0x0100698?/0x01006d8?/0140698?/0x01406d8? */
-	OPTABLE(0x20,0x78, 4,none), /* 0x0100692?/0x01006d2?/0140692/0x01406d2?/0x010069a?/0x01006da?/014069a?/0x01406da? */
-};
-
-static const struct optables_list {
-	const struct optable *ptr;
-	int size;
-} optables[] = {
-#define OPTABLES(no)                                                   \
-        {                                                              \
-		.ptr  = optable_##no,                                  \
-		.size = sizeof(optable_##no) / sizeof(struct optable), \
-	}
-	OPTABLES(0),
-	OPTABLES(1),
-	OPTABLES(2),
-	OPTABLES(3),
-	OPTABLES(4),
-
-};
-
-const unsigned char condmask[] = {
-	0x00,0x40,0x01,0x04,0x02,0x08,0x10,0x20
-};
-
-static int isbranch(struct task_struct *task,int reson)
-{
-	unsigned char cond = h8300_get_reg(task, PT_CCR);
-	/* encode complex conditions */
-	/* B4: N^V
-	   B5: Z|(N^V)
-	   B6: C|Z */
-	__asm__("bld #3,%w0\n\t"
-		"bxor #1,%w0\n\t"
-		"bst #4,%w0\n\t"
-		"bor #2,%w0\n\t"
-		"bst #5,%w0\n\t"
-		"bld #2,%w0\n\t"
-		"bor #0,%w0\n\t"
-		"bst #6,%w0\n\t"
-		:"=&r"(cond)::"cc");
-	cond &= condmask[reson >> 1];
-	if (!(reson & 1))
-		return cond == 0;
-	else
-		return cond != 0;
-}
-
-static unsigned short *getnextpc(struct task_struct *child, unsigned short *pc)
-{
-	const struct optable *op;
-	unsigned char *fetch_p;
-	unsigned char inst;
-	unsigned long addr;
-	unsigned long *sp;
-	int op_len,regno;
-	op = optables[0].ptr;
-	op_len = optables[0].size;
-	fetch_p = (unsigned char *)pc;
-	inst = *fetch_p++;
-	do {
-		if ((inst & op->bitmask) == op->bitpattern) {
-			if (op->length < 0) {
-				op = optables[-op->length].ptr;
-				op_len = optables[-op->length].size + 1;
-				inst = *fetch_p++;
-			} else {
-				switch (op->type) {
-				case none:
-					return pc + op->length;
-				case jabs:
-					addr = *(unsigned long *)pc;
-					return (unsigned short *)(addr & 0x00ffffff);
-				case ind:
-					addr = *pc & 0xff;
-					return (unsigned short *)(*(unsigned long *)addr);
-				case ret:
-					sp = (unsigned long *)h8300_get_reg(child, PT_USP);
-					/* user stack frames
-					   |   er0  | temporary saved
-					   +--------+
-					   |   exp  | exception stack frames
-					   +--------+
-					   | ret pc | userspace return address
-					*/
-					return (unsigned short *)(*(sp+2) & 0x00ffffff);
-				case reg:
-					regno = (*pc >> 4) & 0x07;
-					if (regno == 0)
-						addr = h8300_get_reg(child, PT_ER0);
-					else
-						addr = h8300_get_reg(child, regno-1+PT_ER1);
-					return (unsigned short *)addr;
-				case relb:
-					if (inst == 0x55 || isbranch(child,inst & 0x0f))
-						pc = (unsigned short *)((unsigned long)pc +
-								       ((signed char)(*fetch_p)));
-					return pc+1; /* skip myself */
-				case relw:
-					if (inst == 0x5c || isbranch(child,(*fetch_p & 0xf0) >> 4))
-						pc = (unsigned short *)((unsigned long)pc +
-								       ((signed short)(*(pc+1))));
-					return pc+2; /* skip myself */
-				}
-			}
-		} else
-			op++;
-	} while(--op_len > 0);
-	return NULL;
-}
-
-/* Set breakpoint(s) to simulate a single step from the current PC.  */
-
-void user_enable_single_step(struct task_struct *child)
-{
-	unsigned short *nextpc;
-	nextpc = getnextpc(child,(unsigned short *)h8300_get_reg(child, PT_PC));
-	child->thread.breakinfo.addr = nextpc;
-	child->thread.breakinfo.inst = *nextpc;
-	*nextpc = BREAKINST;
-}
-
-asmlinkage void trace_trap(unsigned long bp)
-{
-	if ((unsigned long)current->thread.breakinfo.addr == bp) {
-		user_disable_single_step(current);
-		force_sig(SIGTRAP,current);
-	} else
-	        force_sig(SIGILL,current);
-}
-
diff --git a/arch/h8300/platform/h8s/Makefile b/arch/h8300/platform/h8s/Makefile
deleted file mode 100644
index bf12418..0000000
--- a/arch/h8300/platform/h8s/Makefile
+++ /dev/null
@@ -1,7 +0,0 @@
-#
-# Makefile for the linux kernel.
-#
-# Reuse any files we can from the H8S
-#
-
-obj-y := ints_h8s.o ptrace_h8s.o
diff --git a/arch/h8300/platform/h8s/edosk2674/Makefile b/arch/h8300/platform/h8s/edosk2674/Makefile
deleted file mode 100644
index 8e34972..0000000
--- a/arch/h8300/platform/h8s/edosk2674/Makefile
+++ /dev/null
@@ -1,5 +0,0 @@
-#
-# Makefile for the linux kernel.
-#
-
-extra-y := crt0_$(MODEL).o
diff --git a/arch/h8300/platform/h8s/edosk2674/crt0_ram.S b/arch/h8300/platform/h8s/edosk2674/crt0_ram.S
deleted file mode 100644
index 5ed191b..0000000
--- a/arch/h8300/platform/h8s/edosk2674/crt0_ram.S
+++ /dev/null
@@ -1,130 +0,0 @@
-/*
- *  linux/arch/h8300/platform/h8s/edosk2674/crt0_ram.S
- *
- *  Yoshinori Sato <ysato@users.sourceforge.jp>
- *
- *  Platform depend startup
- *  Target Archtecture:	EDOSK-2674
- *  Memory Layout     :	RAM
- */
-
-#define ASSEMBLY
-
-#include <asm/linkage.h>
-#include <asm/regs267x.h>
-			
-#if !defined(CONFIG_BLKDEV_RESERVE)
-#if defined(CONFIG_GDB_DEBUG)
-#define RAMEND (__ramend - 0xc000)
-#else
-#define RAMEND __ramend
-#endif
-#else
-#define RAMEND CONFIG_BLKDEV_RESERVE_ADDRESS
-#endif
-	
-	.global __start
-	.global __command_line
-	.global __platform_gpio_table
-	.global __target_name
-	
-	.h8300s
-
-	.section .text
-	.file	"crt0_ram.S"
-
-	/* CPU Reset entry */
-__start:
-	mov.l	#RAMEND,sp
-	ldc	#0x80,ccr
-	ldc	#0x00,exr
-
-	/* Peripheral Setup */
-	bclr	#4,@INTCR:8	/* interrupt mode 2 */
-	bset	#5,@INTCR:8
-	bclr	#0,@IER+1:16
-	bset	#1,@ISCRL+1:16	/* IRQ0 Positive Edge */
-	bclr	#0,@ISCRL+1:16
-
-#if defined(CONFIG_MTD_UCLINUX)
-	/* move romfs image */
-	jsr	@__move_romfs	
-#endif
-	
-	/* .bss clear */
-	mov.l	#__sbss,er5
-	mov.l	er5,er6
-	mov.l	#__ebss,er4
-	sub.l	er5,er4
-	shlr	#2,er4
-	sub.l	er0,er0
-1:	
-	mov.l	er0,@er5
-	adds	#4,er5
-	dec.l	#1,er4
-	bne	1b
-
-	/* copy kernel commandline */
-	mov.l	#COMMAND_START,er5
-	mov.l	#_command_line,er6
-	mov.w	#512,r4
-	eepmov.w
-
-	/* uClinux kernel start */
-	ldc	#0x90,ccr	/* running kernel */
-	mov.l	#_init_thread_union,sp
-	add.l	#0x2000,sp
-	jsr	@_start_kernel
-_exit:
-
-	jmp	_exit
-
-	rts
-
-	/* I/O port assign information */
-__platform_gpio_table:	
-	mov.l	#gpio_table,er0
-	rts
-
-gpio_table:
-	;; P1DDR
-	;;      used,ddr
-	.byte	0x00,0x00
-	;; P2DDR
-	.byte	0x00,0x00
-	;; P3DDR
-	.byte	0x3f,0x3a
-	;; dummy
-	.byte	0x00,0x00
-	;; P5DDR
-	.byte	0x00,0x00
-	;; P6DDR
-	.byte	0x00,0x00
-	;; P7DDR
-	.byte	0x00,0x00
-	;; P8DDR
-	.byte	0x00,0x00
-	;; dummy
-	.byte	0x00,0x00
-	;; PADDR
-	.byte	0xff,0xff
-	;; PBDDR
-	.byte	0xff,0x00
-	;; PCDDR
-	.byte	0xff,0x00
-	;; PDDDR
-	.byte	0xff,0x00
-	;; PEDDR
-	.byte	0xff,0x00
-	;; PFDDR
-	.byte	0xff,0xff
-	;; PGDDR
-	.byte	0x0f,0x0f
-	;; PHDDR
-	.byte	0x0f,0x0f
-
-__target_name:	
-	.asciz	"EDOSK-2674"
-	
-	.section .bootvec,"ax"
-	jmp	@__start
diff --git a/arch/h8300/platform/h8s/edosk2674/crt0_rom.S b/arch/h8300/platform/h8s/edosk2674/crt0_rom.S
deleted file mode 100644
index 06d1d7f..0000000
--- a/arch/h8300/platform/h8s/edosk2674/crt0_rom.S
+++ /dev/null
@@ -1,186 +0,0 @@
-/*
- *  linux/arch/h8300/platform/h8s/edosk2674/crt0_rom.S
- *
- *  Yoshinori Sato <ysato@users.sourceforge.jp>
- *
- *  Platform depend startup
- *  Target Archtecture:	EDOSK-2674
- *  Memory Layout     :	ROM
- */
-
-#define ASSEMBLY
-
-#include <asm/linkage.h>
-#include <asm/regs267x.h>
-		
-	.global __start
-	.global __command_line
-	.global __platform_gpio_table
-	.global __target_name
-	
-	.h8300s
-	.section .text
-	.file	"crt0_rom.S"
-
-	/* CPU Reset entry */
-__start:
-	mov.l	#__ramend,sp
-	ldc	#0x80,ccr
-	ldc	#0,exr
-	
-	/* Peripheral Setup */
-;BSC/GPIO setup
-	mov.l	#init_regs,er0
-	mov.w	#0xffff,e2
-1:
-	mov.w	@er0+,r2
-	beq	2f
-	mov.w	@er0+,r1
-	mov.b	r1l,@er2
-	bra	1b
-
-2:
-;SDRAM setup
-#define SDRAM_SMR 0x400040
-
-	mov.b	#0,r0l
-	mov.b	r0l,@DRACCR:16
-	mov.w	#0x188,r0
-	mov.w	r0,@REFCR:16
-	mov.w	#0x85b4,r0
-	mov.w	r0,@DRAMCR:16
-	mov.b	#0,r1l
-	mov.b	r1l,@SDRAM_SMR
-	mov.w	#0x84b4,r0
-	mov.w	r0,@DRAMCR:16
-;special thanks to Arizona Cooperative Power
-	
-	/* copy .data */
-	mov.l	#__begin_data,er5
-	mov.l	#__sdata,er6
-	mov.l	#__edata,er4
-	sub.l	er6,er4
-	shlr.l	#2,er4
-1:	
-	mov.l	@er5+,er0
-	mov.l	er0,@er6
-	adds	#4,er6
-	dec.l	#1,er4
-	bne	1b	
-
-	/* .bss clear */
-	mov.l	#__sbss,er5
-	mov.l	#__ebss,er4
-	sub.l	er5,er4
-	shlr.l	#2,er4		
-	sub.l	er0,er0
-1:
-	mov.l	er0,@er5
-	adds	#4,er5
-	dec.l	#1,er4
-	bne	1b
-
-	/* copy kernel commandline */
-	mov.l	#COMMAND_START,er5
-	mov.l	#__command_line,er6
-	mov.w	#512,r4
-	eepmov.w
-
-	/* linux kernel start */
-	ldc	#0x90,ccr	/* running kernel */
-	mov.l	#_init_thread_union,sp
-	add.l	#0x2000,sp
-	jsr	@_start_kernel
-_exit:
-
-	jmp	_exit
-
-	rts
-
-	/* I/O port assign information */
-__platform_gpio_table:	
-	mov.l	#gpio_table,er0
-	rts
-
-#define INIT_REGS_DATA(REGS,DATA) \
-	.word	((REGS) & 0xffff),DATA
-
-init_regs:
-INIT_REGS_DATA(ASTCR,0xff)
-INIT_REGS_DATA(RDNCR,0x00)
-INIT_REGS_DATA(ABWCR,0x80)
-INIT_REGS_DATA(WTCRAH,0x27)
-INIT_REGS_DATA(WTCRAL,0x77)
-INIT_REGS_DATA(WTCRBH,0x71)
-INIT_REGS_DATA(WTCRBL,0x22)
-INIT_REGS_DATA(CSACRH,0x80)
-INIT_REGS_DATA(CSACRL,0x80)
-INIT_REGS_DATA(BROMCRH,0xa0)
-INIT_REGS_DATA(BROMCRL,0xa0)
-INIT_REGS_DATA(P3DDR,0x3a)
-INIT_REGS_DATA(P3ODR,0x06)
-INIT_REGS_DATA(PADDR,0xff)
-INIT_REGS_DATA(PFDDR,0xfe)
-INIT_REGS_DATA(PGDDR,0x0f)
-INIT_REGS_DATA(PHDDR,0x0f)
-INIT_REGS_DATA(PFCR0,0xff)
-INIT_REGS_DATA(PFCR2,0x0d)
-INIT_REGS_DATA(ITSR, 0x00)
-INIT_REGS_DATA(ITSR+1,0x3f)
-INIT_REGS_DATA(INTCR,0x20)
-		
-	.word	0
-
-gpio_table:
-	;; P1DDR
-	.byte	0x00,0x00
-	;; P2DDR
-	.byte	0x00,0x00
-	;; P3DDR
-	.byte	0x00,0x00
-	;; dummy
-	.byte	0x00,0x00
-	;; P5DDR
-	.byte	0x00,0x00
-	;; P6DDR
-	.byte	0x00,0x00
-	;; P7DDR
-	.byte	0x00,0x00
-	;; P8DDR
-	.byte	0x00,0x00
-	;; dummy
-	.byte	0x00,0x00
-	;; PADDR
-	.byte	0x00,0x00
-	;; PBDDR
-	.byte	0x00,0x00
-	;; PCDDR
-	.byte	0x00,0x00
-	;; PDDDR
-	.byte	0x00,0x00
-	;; PEDDR
-	.byte	0x00,0x00
-	;; PFDDR
-	.byte	0x00,0x00
-	;; PGDDR
-	.byte	0x00,0x00
-	;; PHDDR
-	.byte	0x00,0x00
-
-	.section .rodata
-__target_name:	
-	.asciz	"EDOSK-2674"
-	
-	.section .bss
-__command_line:	
-	.space	512
-
-	/* interrupt vector */
-	.section .vectors,"ax"
-	.long	__start
-	.long	__start
-vector	=	2
-	.rept	126
-	.long	_interrupt_redirect_table+vector*4
-vector	=	vector + 1
-	.endr
diff --git a/arch/h8300/platform/h8s/generic/Makefile b/arch/h8300/platform/h8s/generic/Makefile
deleted file mode 100644
index 44b4685..0000000
--- a/arch/h8300/platform/h8s/generic/Makefile
+++ /dev/null
@@ -1,5 +0,0 @@
-#
-# Makefile for the linux kernel.
-#
-
-extra-y =  crt0_$(MODEL).o
diff --git a/arch/h8300/platform/h8s/generic/crt0_ram.S b/arch/h8300/platform/h8s/generic/crt0_ram.S
deleted file mode 100644
index 7018915..0000000
--- a/arch/h8300/platform/h8s/generic/crt0_ram.S
+++ /dev/null
@@ -1,127 +0,0 @@
-/*
- *  linux/arch/h8300/platform/h8s/edosk2674/crt0_ram.S
- *
- *  Yoshinori Sato <ysato@users.sourceforge.jp>
- *
- *  Platform depend startup
- *  Target Archtecture:	generic
- *  Memory Layout     :	RAM
- */
-
-#define ASSEMBLY
-
-#include <asm/linkage.h>
-#include <asm/regs267x.h>
-			
-#if !defined(CONFIG_BLKDEV_RESERVE)
-#if defined(CONFIG_GDB_DEBUG)
-#define RAMEND (__ramend - 0xc000)
-#else
-#define RAMEND __ramend
-#endif
-#else
-#define RAMEND CONFIG_BLKDEV_RESERVE_ADDRESS
-#endif
-	
-	.global __start
-	.global __command_line
-	.global __platform_gpio_table
-	.global __target_name
-	
-	.h8300s
-
-	.section .text
-	.file	"crt0_ram.S"
-
-	/* CPU Reset entry */
-__start:
-	mov.l	#RAMEND,sp
-	ldc	#0x80,ccr
-	ldc	#0x00,exr
-
-	/* Peripheral Setup */
-	bclr	#4,@INTCR:8	/* interrupt mode 2 */
-	bset	#5,@INTCR:8
-
-#if defined(CONFIG_MTD_UCLINUX)
-	/* move romfs image */
-	jsr	@__move_romfs	
-#endif
-	
-	/* .bss clear */
-	mov.l	#__sbss,er5
-	mov.l	er5,er6
-	mov.l	#__ebss,er4
-	sub.l	er5,er4
-	shlr	#2,er4
-	sub.l	er0,er0
-1:	
-	mov.l	er0,@er5
-	adds	#4,er5
-	dec.l	#1,er4
-	bne	1b
-
-	/* copy kernel commandline */
-	mov.l	#COMMAND_START,er5
-	mov.l	#_command_line,er6
-	mov.w	#512,r4
-	eepmov.w
-
-	/* uClinux kernel start */
-	ldc	#0x90,ccr	/* running kernel */
-	mov.l	#_init_thread_union,sp
-	add.l	#0x2000,sp
-	jsr	@_start_kernel
-_exit:
-
-	jmp	_exit
-
-	rts
-
-	/* I/O port assign information */
-__platform_gpio_table:	
-	mov.l	#gpio_table,er0
-	rts
-
-gpio_table:
-	;; P1DDR
-	;;      used,ddr
-	.byte	0x00,0x00
-	;; P2DDR
-	.byte	0x00,0x00
-	;; P3DDR
-	.byte	0x00,0x00
-	;; dummy
-	.byte	0x00,0x00
-	;; P5DDR
-	.byte	0x00,0x00
-	;; P6DDR
-	.byte	0x00,0x00
-	;; P7DDR
-	.byte	0x00,0x00
-	;; P8DDR
-	.byte	0x00,0x00
-	;; dummy
-	.byte	0x00,0x00
-	;; PADDR
-	.byte	0x00,0x00
-	;; PBDDR
-	.byte	0x00,0x00
-	;; PCDDR
-	.byte	0x00,0x00
-	;; PDDDR
-	.byte	0x00,0x00
-	;; PEDDR
-	.byte	0x00,0x00
-	;; PFDDR
-	.byte	0x00,0x00
-	;; PGDDR
-	.byte	0x00,0x00
-	;; PHDDR
-	.byte	0x00,0x00
-
-__target_name:	
-	.asciz	"generic"
-	
-	.section .bootvec,"ax"
-	jmp	@__start
diff --git a/arch/h8300/platform/h8s/generic/crt0_rom.S b/arch/h8300/platform/h8s/generic/crt0_rom.S
deleted file mode 100644
index 623ba78..0000000
--- a/arch/h8300/platform/h8s/generic/crt0_rom.S
+++ /dev/null
@@ -1,128 +0,0 @@
-/*
- *  linux/arch/h8300/platform/h8s/generic/crt0_rom.S
- *
- *  Yoshinori Sato <ysato@users.sourceforge.jp>
- *
- *  Platform depend startup 
- *  Target Archtecture:	generic
- *  Memory Layout     :	ROM
- */
-
-#define ASSEMBLY
-
-#include <asm/linkage.h>
-#include <asm/regs267x.h>
-	
-	.global __start
-	.global __command_line
-	.global __platform_gpio_table
-	.global __target_name
-	
-	.h8300s
-	.section .text
-	.file	"crt0_rom.S"
-
-	/* CPU Reset entry */
-__start:
-	mov.l	#__ramend,sp
-	ldc	#0x80,ccr
-	ldc	#0,exr
-	bclr	#4,@INTCR:8
-	bset	#5,@INTCR:8	/* Interrupt mode 2 */
-	
-	/* Peripheral Setup */
-	
-	/* copy .data */
-#if !defined(CONFIG_H8S_SIM)
-	mov.l	#__begin_data,er5
-	mov.l	#__sdata,er6
-	mov.l	#__edata,er4
-	sub.l	er6,er4
-	shlr.l	#2,er4
-1:	
-	mov.l	@er5+,er0
-	mov.l	er0,@er6
-	adds	#4,er6
-	dec.l	#1,er4
-	bne	1b	
-#endif
-
-	/* .bss clear */
-	mov.l	#__sbss,er5
-	mov.l	#__ebss,er4
-	sub.l	er5,er4
-	shlr.l	#2,er4		
-	sub.l	er0,er0
-1:
-	mov.l	er0,@er5
-	adds	#4,er5
-	dec.l	#1,er4
-	bne	1b
-
-	/* linux kernel start */
-	ldc	#0x90,ccr	/* running kernel */
-	mov.l	#_init_thread_union,sp
-	add.l	#0x2000,sp
-	jsr	@_start_kernel
-_exit:
-
-	jmp	_exit
-
-	rts
-
-	/* I/O port assign information */
-__platform_gpio_table:	
-	mov.l	#gpio_table,er0
-	rts
-
-gpio_table:
-	;; P1DDR
-	.byte	0x00,0x00
-	;; P2DDR
-	.byte	0x00,0x00
-	;; P3DDR
-	.byte	0x00,0x00
-	;; P4DDR
-	.byte	0x00,0x00
-	;; P5DDR
-	.byte	0x00,0x00
-	;; P6DDR
-	.byte	0x00,0x00
-	;; dummy
-	.byte	0x00,0x00
-	;; P8DDR
-	.byte	0x00,0x00
-	;; PADDR
-	.byte	0x00,0x00
-	;; PBDDR
-	.byte	0x00,0x00
-	;; PCDDR
-	.byte	0x00,0x00
-	;; PDDDR
-	.byte	0x00,0x00
-	;; PEDDR
-	.byte	0x00,0x00
-	;; PFDDR
-	.byte	0x00,0x00
-	;; PGDDR
-	.byte	0x00,0x00
-	;; PHDDR
-	.byte	0x00,0x00
-
-	.section .rodata
-__target_name:	
-	.asciz	"generic"
-	
-	.section .bss
-__command_line:	
-	.space	512
-
-	/* interrupt vector */
-	.section .vectors,"ax"
-	.long	__start
-	.long	__start
-vector	=	2
-	.rept	126-1
-	.long	_interrupt_redirect_table+vector*4
-vector	=	vector + 1
-	.endr
diff --git a/arch/h8300/platform/h8s/irq.c b/arch/h8300/platform/h8s/irq.c
deleted file mode 100644
index f3a5511..0000000
--- a/arch/h8300/platform/h8s/irq.c
+++ /dev/null
@@ -1,104 +0,0 @@
-/*
- * linux/arch/h8300/platform/h8s/ints_h8s.c
- * Interrupt handling CPU variants
- *
- * Yoshinori Sato <ysato@users.sourceforge.jp>
- *
- */
-
-#include <linux/init.h>
-#include <linux/errno.h>
-#include <linux/kernel.h>
-
-#include <asm/ptrace.h>
-#include <asm/traps.h>
-#include <asm/irq.h>
-#include <asm/io.h>
-#include <asm/gpio-internal.h>
-#include <asm/regs267x.h>
-
-/* saved vector list */
-const int __initconst h8300_saved_vectors[] = {
-#if defined(CONFIG_GDB_DEBUG)
-	TRACE_VEC,
-	TRAP3_VEC,
-#endif
-	-1
-};
-
-/* trap entry table */
-const H8300_VECTOR __initconst h8300_trap_table[] = {
-	0,0,0,0,0,
-	trace_break,  /* TRACE */
-	0,0,
-	system_call,  /* TRAPA #0 */
-	0,0,0,0,0,0,0
-};
-
-/* IRQ pin assignment */
-struct irq_pins {
-	unsigned char port_no;
-	unsigned char bit_no;
-} __attribute__((aligned(1),packed));
-/* ISTR = 0 */
-static const struct irq_pins irq_assign_table0[16]={
-        {H8300_GPIO_P5,H8300_GPIO_B0},{H8300_GPIO_P5,H8300_GPIO_B1},
-	{H8300_GPIO_P5,H8300_GPIO_B2},{H8300_GPIO_P5,H8300_GPIO_B3},
-	{H8300_GPIO_P5,H8300_GPIO_B4},{H8300_GPIO_P5,H8300_GPIO_B5},
-	{H8300_GPIO_P5,H8300_GPIO_B6},{H8300_GPIO_P5,H8300_GPIO_B7},
-	{H8300_GPIO_P6,H8300_GPIO_B0},{H8300_GPIO_P6,H8300_GPIO_B1},
-	{H8300_GPIO_P6,H8300_GPIO_B2},{H8300_GPIO_P6,H8300_GPIO_B3},
-	{H8300_GPIO_P6,H8300_GPIO_B4},{H8300_GPIO_P6,H8300_GPIO_B5},
-	{H8300_GPIO_PF,H8300_GPIO_B1},{H8300_GPIO_PF,H8300_GPIO_B2},
-};
-/* ISTR = 1 */
-static const struct irq_pins irq_assign_table1[16]={
-	{H8300_GPIO_P8,H8300_GPIO_B0},{H8300_GPIO_P8,H8300_GPIO_B1},
-	{H8300_GPIO_P8,H8300_GPIO_B2},{H8300_GPIO_P8,H8300_GPIO_B3},
-	{H8300_GPIO_P8,H8300_GPIO_B4},{H8300_GPIO_P8,H8300_GPIO_B5},
-	{H8300_GPIO_PH,H8300_GPIO_B2},{H8300_GPIO_PH,H8300_GPIO_B3},
-	{H8300_GPIO_P2,H8300_GPIO_B0},{H8300_GPIO_P2,H8300_GPIO_B1},
-	{H8300_GPIO_P2,H8300_GPIO_B2},{H8300_GPIO_P2,H8300_GPIO_B3},
-	{H8300_GPIO_P2,H8300_GPIO_B4},{H8300_GPIO_P2,H8300_GPIO_B5},
-	{H8300_GPIO_P2,H8300_GPIO_B6},{H8300_GPIO_P2,H8300_GPIO_B7},
-};
-
-/* IRQ to GPIO pin translation */
-#define IRQ_GPIO_MAP(irqbit,irq,port,bit)			  \
-do {								  \
-	if (*(volatile unsigned short *)ITSR & irqbit) {	  \
-		port = irq_assign_table1[irq - EXT_IRQ0].port_no; \
-		bit  = irq_assign_table1[irq - EXT_IRQ0].bit_no;  \
-	} else {						  \
-		port = irq_assign_table0[irq - EXT_IRQ0].port_no; \
-		bit  = irq_assign_table0[irq - EXT_IRQ0].bit_no;  \
-	}							  \
-} while(0)
-
-int h8300_enable_irq_pin(unsigned int irq)
-{
-	if (irq >= EXT_IRQ0 && irq <= EXT_IRQ15) {
-		unsigned short ptn = 1 << (irq - EXT_IRQ0);
-		unsigned int port_no,bit_no;
-		IRQ_GPIO_MAP(ptn, irq, port_no, bit_no);
-		if (H8300_GPIO_RESERVE(port_no, bit_no) == 0)
-			return -EBUSY;                   /* pin already use */
-		H8300_GPIO_DDR(port_no, bit_no, H8300_GPIO_INPUT);
-		*(volatile unsigned short *)ISR &= ~ptn; /* ISR clear */
-	}
-
-	return 0;
-}
-
-void h8300_disable_irq_pin(unsigned int irq)
-{
-	if (irq >= EXT_IRQ0 && irq <= EXT_IRQ15) {
-		/* disable interrupt & release IRQ pin */
-		unsigned short ptn = 1 << (irq - EXT_IRQ0);
-		unsigned short port_no,bit_no;
-		*(volatile unsigned short *)ISR &= ~ptn;
-		*(volatile unsigned short *)IER &= ~ptn;
-		IRQ_GPIO_MAP(ptn, irq, port_no, bit_no);
-		H8300_GPIO_FREE(port_no, bit_no);
-	}
-}
diff --git a/arch/h8300/platform/h8s/ptrace_h8s.c b/arch/h8300/platform/h8s/ptrace_h8s.c
deleted file mode 100644
index c058ab1..0000000
--- a/arch/h8300/platform/h8s/ptrace_h8s.c
+++ /dev/null
@@ -1,84 +0,0 @@
-/*
- *  linux/arch/h8300/platform/h8s/ptrace_h8s.c
- *    ptrace cpu depend helper functions
- *
- *  Yoshinori Sato <ysato@users.sourceforge.jp>
- *
- * This file is subject to the terms and conditions of the GNU General
- * Public License.  See the file COPYING in the main directory of
- * this archive for more details.
- */
-
-#include <linux/linkage.h>
-#include <linux/sched.h>
-#include <linux/errno.h>
-#include <asm/ptrace.h>
-
-#define CCR_MASK  0x6f
-#define EXR_TRACE 0x80
-
-/* Mapping from PT_xxx to the stack offset at which the register is
-   saved.  Notice that usp has no stack-slot and needs to be treated
-   specially (see get_reg/put_reg below). */
-static const int h8300_register_offset[] = {
-	PT_REG(er1), PT_REG(er2), PT_REG(er3), PT_REG(er4),
-	PT_REG(er5), PT_REG(er6), PT_REG(er0), PT_REG(orig_er0),
-	PT_REG(ccr), PT_REG(pc),  0,           PT_REG(exr)
-};
-
-/* read register */
-long h8300_get_reg(struct task_struct *task, int regno)
-{
-	switch (regno) {
-	case PT_USP:
-		return task->thread.usp + sizeof(long)*2 + 2;
-	case PT_CCR:
-	case PT_EXR:
-	    return *(unsigned short *)(task->thread.esp0 + h8300_register_offset[regno]);
-	default:
-	    return *(unsigned long *)(task->thread.esp0 + h8300_register_offset[regno]);
-	}
-}
-
-/* write register */
-int h8300_put_reg(struct task_struct *task, int regno, unsigned long data)
-{
-	unsigned short oldccr;
-	switch (regno) {
-	case PT_USP:
-		task->thread.usp = data - sizeof(long)*2 - 2;
-	case PT_CCR:
-		oldccr = *(unsigned short *)(task->thread.esp0 + h8300_register_offset[regno]);
-		oldccr &= ~CCR_MASK;
-		data &= CCR_MASK;
-		data |= oldccr;
-		*(unsigned short *)(task->thread.esp0 + h8300_register_offset[regno]) = data;
-		break;
-	case PT_EXR:
-		/* exr modify not support */
-		return -EIO;
-	default:
-		*(unsigned long *)(task->thread.esp0 + h8300_register_offset[regno]) = data;
-		break;
-	}
-	return 0;
-}
-
-/* disable singlestep */
-void user_disable_single_step(struct task_struct *child)
-{
-	*(unsigned short *)(child->thread.esp0 + h8300_register_offset[PT_EXR]) &= ~EXR_TRACE;
-}
-
-/* enable singlestep */
-void user_enable_single_step(struct task_struct *child)
-{
-	*(unsigned short *)(child->thread.esp0 + h8300_register_offset[PT_EXR]) |= EXR_TRACE;
-}
-
-asmlinkage void trace_trap(unsigned long bp)
-{
-	(void)bp;
-	force_sig(SIGTRAP,current);
-}
-
diff --git a/include/linux/serial_sci.h b/include/linux/serial_sci.h
index d340497..50fe651 100644
--- a/include/linux/serial_sci.h
+++ b/include/linux/serial_sci.h
@@ -5,7 +5,7 @@
 #include <linux/sh_dma.h>
 
 /*
- * Generic header for SuperH (H)SCI(F) (used by sh/sh64/h8300 and related parts)
+ * Generic header for SuperH (H)SCI(F) (used by sh/sh64 and related parts)
  */
 
 #define SCIx_NOT_SUPPORTED	(-1)
diff --git a/tools/testing/ktest/examples/crosstests.conf b/tools/testing/ktest/examples/crosstests.conf
index 4673660..a1203148 100644
--- a/tools/testing/ktest/examples/crosstests.conf
+++ b/tools/testing/ktest/examples/crosstests.conf
@@ -133,12 +133,6 @@ CROSS = frv-linux
 ARCH = frv
 GCC_VER = 4.5.1
 
-# h8300 - failed make defconfig??
-TEST_START IF ${RUN} == h8300 || ${DO_FAILED}
-CROSS = h8300-elf
-ARCH = h8300
-GCC_VER = 4.5.1
-
 # m68k fails with error?
 TEST_START IF ${RUN} == m68k || ${DO_DEFAULT}
 CROSS = m68k-linux
-- 
1.7.9.7
