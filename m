From: Niki Waibel <niki.waibel@newlogic.com>
Subject: linux-2.5.71 on pc164/alpha
Date: Tue, 17 Jun 2003 12:25:34 +0200 (MEST)
Sender: axp-list-admin@redhat.com
Message-ID: <200306171025.h5HAPYxr016179@enterprise2.newlogic.at>
Reply-To: axp-list@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: kraxel@bytesex.org, vojtech@suse.cz, jbglaw@lug-owl.de,
	netdev@oss.sgi.com
Return-path: <axp-list-admin@redhat.com>
To: axp-list@redhat.com
Errors-To: axp-list-admin@redhat.com
List-Help: <mailto:axp-list-request@redhat.com?subject=help>
List-Post: <mailto:axp-list@redhat.com>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/axp-list>,
	<mailto:axp-list-request@redhat.com?subject=subscribe>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/axp-list>,
	<mailto:axp-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/mailman/private/axp-list/>
List-Id: netdev.vger.kernel.org

        * matrox frambuffer device works now.

        * sb16 alsa audio compiles but i have not yet
verified if it is working.

        * ERROR (warning) in arch/alpha/kernel/srmcons.c:
===
  CC      arch/alpha/kernel/srmcons.o
arch/alpha/kernel/srmcons.c:269: warning: `srmcons_ops' defined but not used
make[1]: *** [arch/alpha/kernel/srmcons.o] Error 1
make: *** [arch/alpha/kernel] Error 2
===
after removing srmcons_ops and all references of the functions inside
that structure compiling was okay...

        * still troubles with bttv:
===
  LD      vmlinux
drivers/built-in.o(.text+0x81294): In function `bttv_apply_geo':
: undefined reference to `readl'
drivers/built-in.o(.text+0x812a0): In function `bttv_apply_geo':
: undefined reference to `readl'
drivers/built-in.o(.text+0x812c0): In function `bttv_apply_geo':
: undefined reference to `writel'
drivers/built-in.o(.text+0x812cc): In function `bttv_apply_geo':
: undefined reference to `writel'
drivers/built-in.o(.text+0x812e4): In function `bttv_apply_geo':
: undefined reference to `writel'
drivers/built-in.o(.text+0x812f8): In function `bttv_apply_geo':
: undefined reference to `writel'
drivers/built-in.o(.text+0x8130c): In function `bttv_apply_geo':
: undefined reference to `writel'
drivers/built-in.o(.text+0x8131c): more undefined references to `writel' follow
drivers/built-in.o(.text+0x81354): In function `bttv_apply_geo':
: undefined reference to `readl'
drivers/built-in.o(.text+0x81368): In function `bttv_apply_geo':
: undefined reference to `readl'
drivers/built-in.o(.text+0x81388): In function `bttv_apply_geo':
: undefined reference to `writel'
drivers/built-in.o(.text+0x81394): In function `bttv_apply_geo':
: undefined reference to `writel'
drivers/built-in.o(.text+0x813ac): In function `bttv_apply_geo':
: undefined reference to `writel'
drivers/built-in.o(.text+0x813b8): In function `bttv_apply_geo':
: undefined reference to `writel'
drivers/built-in.o(.text+0x813cc): In function `bttv_apply_geo':
: undefined reference to `writel'
drivers/built-in.o(.text+0x813d8): more undefined references to `writel' follow
drivers/built-in.o(.text+0x81494): In function `bttv_apply_geo':
: undefined reference to `readl'
drivers/built-in.o(.text+0x814a0): In function `bttv_apply_geo':
: undefined reference to `readl'
drivers/built-in.o(.text+0x81608): In function `bttv_set_dma':
: undefined reference to `readl'
drivers/built-in.o(.text+0x81618): In function `bttv_set_dma':
: undefined reference to `readl'
drivers/built-in.o(.text+0x81634): In function `bttv_set_dma':
: undefined reference to `writel'
drivers/built-in.o(.text+0x81640): In function `bttv_set_dma':
: undefined reference to `writel'
drivers/built-in.o(.text+0x81688): In function `bttv_set_dma':
: undefined reference to `writel'
drivers/built-in.o(.text+0x81690): In function `bttv_set_dma':
: undefined reference to `writel'
drivers/built-in.o(.text+0x816a0): In function `bttv_set_dma':
: undefined reference to `readl'
drivers/built-in.o(.text+0x816a8): In function `bttv_set_dma':
: undefined reference to `readl'
drivers/built-in.o(.text+0x816bc): In function `bttv_set_dma':
: undefined reference to `writel'
drivers/built-in.o(.text+0x816cc): In function `bttv_set_dma':
: undefined reference to `writel'
drivers/built-in.o(.text+0x816fc): In function `bttv_set_dma':
: undefined reference to `readl'
drivers/built-in.o(.text+0x81704): In function `bttv_set_dma':
: undefined reference to `readl'
drivers/built-in.o(.text+0x8171c): In function `bttv_set_dma':
: undefined reference to `writel'
drivers/built-in.o(.text+0x8172c): In function `bttv_set_dma':
: undefined reference to `writel'
drivers/built-in.o(.text+0x81b74): In function `bttv_buffer_activate':
: undefined reference to `readl'
drivers/built-in.o(.text+0x81b7c): In function `bttv_buffer_activate':
: undefined reference to `readl'
drivers/built-in.o(.text+0x81b9c): In function `bttv_buffer_activate':
: undefined reference to `writel'
drivers/built-in.o(.text+0x81ba8): In function `bttv_buffer_activate':
: undefined reference to `writel'
drivers/built-in.o(.text+0x81bc8): In function `bttv_buffer_activate':
: undefined reference to `readl'
drivers/built-in.o(.text+0x81bcc): In function `bttv_buffer_activate':
: undefined reference to `readl'
drivers/built-in.o(.text+0x81bec): In function `bttv_buffer_activate':
: undefined reference to `writel'
drivers/built-in.o(.text+0x81bf8): In function `bttv_buffer_activate':
: undefined reference to `writel'
drivers/built-in.o(.text+0x81c9c): In function `bttv_buffer_activate':
: undefined reference to `readl'
drivers/built-in.o(.text+0x81ca4): In function `bttv_buffer_activate':
: undefined reference to `readl'
drivers/built-in.o(.text+0x81cc4): In function `bttv_buffer_activate':
: undefined reference to `writel'
drivers/built-in.o(.text+0x81cd0): In function `bttv_buffer_activate':
: undefined reference to `writel'
drivers/built-in.o(.text+0x81d7c): In function `bttv_buffer_activate':
: undefined reference to `readl'
drivers/built-in.o(.text+0x81d8c): In function `bttv_buffer_activate':
: undefined reference to `readl'
drivers/built-in.o(.text+0x81dac): In function `bttv_buffer_activate':
: undefined reference to `writel'
drivers/built-in.o(.text+0x81db8): In function `bttv_buffer_activate':
: undefined reference to `writel'
===
i disabled the bttv driver...

        * another strange thing in net/core/flow.c:
===
  LD      vmlinux
net/built-in.o(.init.text+0x4a4): In function `flow_cache_init':
: undefined reference to `register_cpu_notifier'
net/built-in.o(.init.text+0x4ac): In function `flow_cache_init':
: undefined reference to `register_cpu_notifier'
===
i simply removed the line which called register_cpu_notifier...
then the kernel built.

        * there is still the caps lock problem!
if caps lock is pressed the console freezes ... or the keyboard imput...
i dont know. machine is still okay (network access is possible).
this is not the case if X is running.
i am not 100% but afair num lock and scroll lock cause the same problem.

niki (using gcc-3.3/binutils-2.14)
-- 
niki w. waibel - system administrator @ newlogic technologies ag
