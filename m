From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 1/2] smc91x: always use 8-bit access if necessary
Date: Sat, 27 Aug 2016 06:39:16 +0800
Message-ID: <201608270623.7fH0YSH3%fengguang.wu@intel.com>
References: <20160825144633.1850889-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="wac7ysb48OaltWcw"
Cc: kbuild-all@01.org, Russell King <linux@armlinux.org.uk>,
        linux-arm-kernel@lists.infradead.org,
        Arnd Bergmann <arnd@arndb.de>,
        Nicolas Pitre <nico@fluxnic.net>,
        "David S. Miller" <davem@davemloft.net>,
        Robert Jarzmik <robert.jarzmik@free.fr>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160825144633.1850889-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Arnd,

[auto build test WARNING on net-next/master]
[also build test WARNING on v4.8-rc3 next-20160825]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
[Suggest to use git(>=2.9.0) format-patch --base=<commit> (or --base=auto for convenience) to record what (public, well-known) commit your patch series was built on]
[Check https://git-scm.com/docs/git-format-patch for more information]

url:    https://github.com/0day-ci/linux/commits/Arnd-Bergmann/smc91x-always-use-8-bit-access-if-necessary/20160825-225929
config: sh-microdev_defconfig (attached as .config)
compiler: sh4-linux-gnu-gcc (Debian 5.4.0-6) 5.4.0 20160609
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=sh 

All warnings (new ones prefixed by >>):

                    from drivers/net/ethernet/smsc/smc91x.c:72:
   arch/sh/include/asm/io.h:159:25: note: expected 'long unsigned int' but argument is of type 'void *'
    static inline void pfx##out##bwlq##p(type val, unsigned long port) \
                            ^
   arch/sh/include/asm/io.h:181:2: note: in expansion of macro '__BUILD_IOPORT_SINGLE'
     __BUILD_IOPORT_SINGLE(bus, bwlq, type, ,)   \
     ^
   arch/sh/include/asm/io.h:185:2: note: in expansion of macro '__BUILD_IOPORT_PFX'
     __BUILD_IOPORT_PFX(, bwlq, type)
     ^
   arch/sh/include/asm/io.h:188:1: note: in expansion of macro 'BUILDIO_IOPORT'
    BUILDIO_IOPORT(w, u16)
    ^
   In file included from drivers/net/ethernet/smsc/smc91x.c:92:0:
   drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
   drivers/net/ethernet/smsc/smc91x.h:1015:28: note: in expansion of macro 'SMC_out16'
    #define SMC_SET_TCR(lp, x) SMC_out16(x, ioaddr, TCR_REG(lp))
                               ^
   drivers/net/ethernet/smsc/smc91x.c:319:2: note: in expansion of macro 'SMC_SET_TCR'
     SMC_SET_TCR(lp, TCR_CLEAR);
     ^
   drivers/net/ethernet/smsc/smc91x.h:91:35: warning: passing argument 2 of 'outw' makes integer from pointer without a cast [-Wint-conversion]
    #define SMC_outw(v, a, r) outw(v, (a) + (r) - 0xa0000000)
                                      ^
   drivers/net/ethernet/smsc/smc91x.h:428:3: note: in expansion of macro 'SMC_outw'
      SMC_outw(x, ioaddr, reg);         \
      ^
   drivers/net/ethernet/smsc/smc91x.h:1015:28: note: in expansion of macro 'SMC_out16'
    #define SMC_SET_TCR(lp, x) SMC_out16(x, ioaddr, TCR_REG(lp))
                               ^
   drivers/net/ethernet/smsc/smc91x.c:319:2: note: in expansion of macro 'SMC_SET_TCR'
     SMC_SET_TCR(lp, TCR_CLEAR);
     ^
   In file included from include/linux/io.h:25:0,
                    from include/linux/irq.h:24,
                    from arch/sh/include/asm/hardirq.h:5,
                    from include/linux/hardirq.h:8,
                    from include/linux/interrupt.h:12,
                    from drivers/net/ethernet/smsc/smc91x.c:72:
   arch/sh/include/asm/io.h:159:25: note: expected 'long unsigned int' but argument is of type 'void *'
    static inline void pfx##out##bwlq##p(type val, unsigned long port) \
                            ^
   arch/sh/include/asm/io.h:181:2: note: in expansion of macro '__BUILD_IOPORT_SINGLE'
     __BUILD_IOPORT_SINGLE(bus, bwlq, type, ,)   \
     ^
   arch/sh/include/asm/io.h:185:2: note: in expansion of macro '__BUILD_IOPORT_PFX'
     __BUILD_IOPORT_PFX(, bwlq, type)
     ^
   arch/sh/include/asm/io.h:188:1: note: in expansion of macro 'BUILDIO_IOPORT'
    BUILDIO_IOPORT(w, u16)
    ^
   In file included from drivers/net/ethernet/smsc/smc91x.c:92:0:
   drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
   drivers/net/ethernet/smsc/smc91x.h:944:4: note: in expansion of macro 'SMC_out16'
       SMC_out16(x, ioaddr, BANK_SELECT);  \
       ^
   drivers/net/ethernet/smsc/smc91x.c:321:2: note: in expansion of macro 'SMC_SELECT_BANK'
     SMC_SELECT_BANK(lp, 1);
     ^
   drivers/net/ethernet/smsc/smc91x.h:91:35: warning: passing argument 2 of 'outw' makes integer from pointer without a cast [-Wint-conversion]
    #define SMC_outw(v, a, r) outw(v, (a) + (r) - 0xa0000000)
                                      ^
   drivers/net/ethernet/smsc/smc91x.h:428:3: note: in expansion of macro 'SMC_outw'
      SMC_outw(x, ioaddr, reg);         \
      ^
   drivers/net/ethernet/smsc/smc91x.h:944:4: note: in expansion of macro 'SMC_out16'
       SMC_out16(x, ioaddr, BANK_SELECT);  \
       ^
   drivers/net/ethernet/smsc/smc91x.c:321:2: note: in expansion of macro 'SMC_SELECT_BANK'
     SMC_SELECT_BANK(lp, 1);
     ^
   In file included from include/linux/io.h:25:0,
                    from include/linux/irq.h:24,
                    from arch/sh/include/asm/hardirq.h:5,
                    from include/linux/hardirq.h:8,
                    from include/linux/interrupt.h:12,
                    from drivers/net/ethernet/smsc/smc91x.c:72:
   arch/sh/include/asm/io.h:159:25: note: expected 'long unsigned int' but argument is of type 'void *'
    static inline void pfx##out##bwlq##p(type val, unsigned long port) \
                            ^
   arch/sh/include/asm/io.h:181:2: note: in expansion of macro '__BUILD_IOPORT_SINGLE'
     __BUILD_IOPORT_SINGLE(bus, bwlq, type, ,)   \
     ^
   arch/sh/include/asm/io.h:185:2: note: in expansion of macro '__BUILD_IOPORT_PFX'
     __BUILD_IOPORT_PFX(, bwlq, type)
     ^
   arch/sh/include/asm/io.h:188:1: note: in expansion of macro 'BUILDIO_IOPORT'
    BUILDIO_IOPORT(w, u16)
    ^
   In file included from drivers/net/ethernet/smsc/smc91x.c:92:0:
   drivers/net/ethernet/smsc/smc91x.h:88:28: warning: passing argument 1 of 'inw' makes integer from pointer without a cast [-Wint-conversion]
    #define SMC_inw(a, r)  inw((a) + (r) - 0xa0000000)
                               ^
   drivers/net/ethernet/smsc/smc91x.h:439:13: note: in expansion of macro 'SMC_inw'
      __val16 = SMC_inw(ioaddr, reg);         \
                ^
>> drivers/net/ethernet/smsc/smc91x.h:957:26: note: in expansion of macro 'SMC_in16'
    #define SMC_GET_CTL(lp)  SMC_in16(ioaddr, CTL_REG(lp))
                             ^
   drivers/net/ethernet/smsc/smc91x.c:322:8: note: in expansion of macro 'SMC_GET_CTL'
     ctl = SMC_GET_CTL(lp) | CTL_LE_ENABLE;
           ^
   In file included from include/linux/io.h:25:0,
                    from include/linux/irq.h:24,
                    from arch/sh/include/asm/hardirq.h:5,
                    from include/linux/hardirq.h:8,
                    from include/linux/interrupt.h:12,
                    from drivers/net/ethernet/smsc/smc91x.c:72:
   arch/sh/include/asm/io.h:168:25: note: expected 'long unsigned int' but argument is of type 'void *'
    static inline type pfx##in##bwlq##p(unsigned long port)   \
                            ^
   arch/sh/include/asm/io.h:181:2: note: in expansion of macro '__BUILD_IOPORT_SINGLE'
     __BUILD_IOPORT_SINGLE(bus, bwlq, type, ,)   \
     ^
   arch/sh/include/asm/io.h:185:2: note: in expansion of macro '__BUILD_IOPORT_PFX'
     __BUILD_IOPORT_PFX(, bwlq, type)
     ^
   arch/sh/include/asm/io.h:188:1: note: in expansion of macro 'BUILDIO_IOPORT'
    BUILDIO_IOPORT(w, u16)
    ^
   In file included from drivers/net/ethernet/smsc/smc91x.c:92:0:
   drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
   drivers/net/ethernet/smsc/smc91x.h:959:28: note: in expansion of macro 'SMC_out16'
    #define SMC_SET_CTL(lp, x) SMC_out16(x, ioaddr, CTL_REG(lp))
                               ^
   drivers/net/ethernet/smsc/smc91x.c:333:2: note: in expansion of macro 'SMC_SET_CTL'
     SMC_SET_CTL(lp, ctl);
     ^
   drivers/net/ethernet/smsc/smc91x.h:91:35: warning: passing argument 2 of 'outw' makes integer from pointer without a cast [-Wint-conversion]
    #define SMC_outw(v, a, r) outw(v, (a) + (r) - 0xa0000000)
                                      ^
   drivers/net/ethernet/smsc/smc91x.h:428:3: note: in expansion of macro 'SMC_outw'
      SMC_outw(x, ioaddr, reg);         \
      ^
   drivers/net/ethernet/smsc/smc91x.h:959:28: note: in expansion of macro 'SMC_out16'
    #define SMC_SET_CTL(lp, x) SMC_out16(x, ioaddr, CTL_REG(lp))
                               ^
   drivers/net/ethernet/smsc/smc91x.c:333:2: note: in expansion of macro 'SMC_SET_CTL'
     SMC_SET_CTL(lp, ctl);
     ^
   In file included from include/linux/io.h:25:0,
                    from include/linux/irq.h:24,
                    from arch/sh/include/asm/hardirq.h:5,
                    from include/linux/hardirq.h:8,
                    from include/linux/interrupt.h:12,
                    from drivers/net/ethernet/smsc/smc91x.c:72:
   arch/sh/include/asm/io.h:159:25: note: expected 'long unsigned int' but argument is of type 'void *'
    static inline void pfx##out##bwlq##p(type val, unsigned long port) \
                            ^
   arch/sh/include/asm/io.h:181:2: note: in expansion of macro '__BUILD_IOPORT_SINGLE'
     __BUILD_IOPORT_SINGLE(bus, bwlq, type, ,)   \
     ^
   arch/sh/include/asm/io.h:185:2: note: in expansion of macro '__BUILD_IOPORT_PFX'
     __BUILD_IOPORT_PFX(, bwlq, type)
     ^
   arch/sh/include/asm/io.h:188:1: note: in expansion of macro 'BUILDIO_IOPORT'
    BUILDIO_IOPORT(w, u16)
    ^
   In file included from drivers/net/ethernet/smsc/smc91x.c:92:0:
   drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
   drivers/net/ethernet/smsc/smc91x.h:944:4: note: in expansion of macro 'SMC_out16'
       SMC_out16(x, ioaddr, BANK_SELECT);  \
       ^
   drivers/net/ethernet/smsc/smc91x.c:336:2: note: in expansion of macro 'SMC_SELECT_BANK'
     SMC_SELECT_BANK(lp, 2);
     ^
   drivers/net/ethernet/smsc/smc91x.h:91:35: warning: passing argument 2 of 'outw' makes integer from pointer without a cast [-Wint-conversion]
    #define SMC_outw(v, a, r) outw(v, (a) + (r) - 0xa0000000)
                                      ^
   drivers/net/ethernet/smsc/smc91x.h:428:3: note: in expansion of macro 'SMC_outw'
      SMC_outw(x, ioaddr, reg);         \
      ^
   drivers/net/ethernet/smsc/smc91x.h:944:4: note: in expansion of macro 'SMC_out16'
       SMC_out16(x, ioaddr, BANK_SELECT);  \
       ^
   drivers/net/ethernet/smsc/smc91x.c:336:2: note: in expansion of macro 'SMC_SELECT_BANK'
     SMC_SELECT_BANK(lp, 2);
     ^
   In file included from include/linux/io.h:25:0,
                    from include/linux/irq.h:24,
                    from arch/sh/include/asm/hardirq.h:5,
                    from include/linux/hardirq.h:8,
                    from include/linux/interrupt.h:12,
                    from drivers/net/ethernet/smsc/smc91x.c:72:
   arch/sh/include/asm/io.h:159:25: note: expected 'long unsigned int' but argument is of type 'void *'
    static inline void pfx##out##bwlq##p(type val, unsigned long port) \
                            ^
   arch/sh/include/asm/io.h:181:2: note: in expansion of macro '__BUILD_IOPORT_SINGLE'
     __BUILD_IOPORT_SINGLE(bus, bwlq, type, ,)   \
     ^
   arch/sh/include/asm/io.h:185:2: note: in expansion of macro '__BUILD_IOPORT_PFX'
     __BUILD_IOPORT_PFX(, bwlq, type)
     ^
--
   arch/sh/include/asm/io.h:168:25: note: expected 'long unsigned int' but argument is of type 'void *'
    static inline type pfx##in##bwlq##p(unsigned long port)   \
                            ^
   arch/sh/include/asm/io.h:181:2: note: in expansion of macro '__BUILD_IOPORT_SINGLE'
     __BUILD_IOPORT_SINGLE(bus, bwlq, type, ,)   \
     ^
   arch/sh/include/asm/io.h:185:2: note: in expansion of macro '__BUILD_IOPORT_PFX'
     __BUILD_IOPORT_PFX(, bwlq, type)
     ^
   arch/sh/include/asm/io.h:188:1: note: in expansion of macro 'BUILDIO_IOPORT'
    BUILDIO_IOPORT(w, u16)
    ^
   In file included from drivers/net/ethernet/smsc/smc91x.c:92:0:
   drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
   drivers/net/ethernet/smsc/smc91x.h:944:4: note: in expansion of macro 'SMC_out16'
       SMC_out16(x, ioaddr, BANK_SELECT);  \
       ^
   drivers/net/ethernet/smsc/smc91x.c:1178:2: note: in expansion of macro 'SMC_SELECT_BANK'
     SMC_SELECT_BANK(lp, 2);
     ^
   drivers/net/ethernet/smsc/smc91x.h:91:35: warning: passing argument 2 of 'outw' makes integer from pointer without a cast [-Wint-conversion]
    #define SMC_outw(v, a, r) outw(v, (a) + (r) - 0xa0000000)
                                      ^
   drivers/net/ethernet/smsc/smc91x.h:428:3: note: in expansion of macro 'SMC_outw'
      SMC_outw(x, ioaddr, reg);         \
      ^
   drivers/net/ethernet/smsc/smc91x.h:944:4: note: in expansion of macro 'SMC_out16'
       SMC_out16(x, ioaddr, BANK_SELECT);  \
       ^
   drivers/net/ethernet/smsc/smc91x.c:1178:2: note: in expansion of macro 'SMC_SELECT_BANK'
     SMC_SELECT_BANK(lp, 2);
     ^
   In file included from include/linux/io.h:25:0,
                    from include/linux/irq.h:24,
                    from arch/sh/include/asm/hardirq.h:5,
                    from include/linux/hardirq.h:8,
                    from include/linux/interrupt.h:12,
                    from drivers/net/ethernet/smsc/smc91x.c:72:
   arch/sh/include/asm/io.h:159:25: note: expected 'long unsigned int' but argument is of type 'void *'
    static inline void pfx##out##bwlq##p(type val, unsigned long port) \
                            ^
   arch/sh/include/asm/io.h:181:2: note: in expansion of macro '__BUILD_IOPORT_SINGLE'
     __BUILD_IOPORT_SINGLE(bus, bwlq, type, ,)   \
     ^
   arch/sh/include/asm/io.h:185:2: note: in expansion of macro '__BUILD_IOPORT_PFX'
     __BUILD_IOPORT_PFX(, bwlq, type)
     ^
   arch/sh/include/asm/io.h:188:1: note: in expansion of macro 'BUILDIO_IOPORT'
    BUILDIO_IOPORT(w, u16)
    ^
   In file included from drivers/net/ethernet/smsc/smc91x.c:92:0:
   drivers/net/ethernet/smsc/smc91x.c: In function 'smc_eph_interrupt':
   drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
   drivers/net/ethernet/smsc/smc91x.h:944:4: note: in expansion of macro 'SMC_out16'
       SMC_out16(x, ioaddr, BANK_SELECT);  \
       ^
   drivers/net/ethernet/smsc/smc91x.c:1200:2: note: in expansion of macro 'SMC_SELECT_BANK'
     SMC_SELECT_BANK(lp, 1);
     ^
   drivers/net/ethernet/smsc/smc91x.h:91:35: warning: passing argument 2 of 'outw' makes integer from pointer without a cast [-Wint-conversion]
    #define SMC_outw(v, a, r) outw(v, (a) + (r) - 0xa0000000)
                                      ^
   drivers/net/ethernet/smsc/smc91x.h:428:3: note: in expansion of macro 'SMC_outw'
      SMC_outw(x, ioaddr, reg);         \
      ^
   drivers/net/ethernet/smsc/smc91x.h:944:4: note: in expansion of macro 'SMC_out16'
       SMC_out16(x, ioaddr, BANK_SELECT);  \
       ^
   drivers/net/ethernet/smsc/smc91x.c:1200:2: note: in expansion of macro 'SMC_SELECT_BANK'
     SMC_SELECT_BANK(lp, 1);
     ^
   In file included from include/linux/io.h:25:0,
                    from include/linux/irq.h:24,
                    from arch/sh/include/asm/hardirq.h:5,
                    from include/linux/hardirq.h:8,
                    from include/linux/interrupt.h:12,
                    from drivers/net/ethernet/smsc/smc91x.c:72:
   arch/sh/include/asm/io.h:159:25: note: expected 'long unsigned int' but argument is of type 'void *'
    static inline void pfx##out##bwlq##p(type val, unsigned long port) \
                            ^
   arch/sh/include/asm/io.h:181:2: note: in expansion of macro '__BUILD_IOPORT_SINGLE'
     __BUILD_IOPORT_SINGLE(bus, bwlq, type, ,)   \
     ^
   arch/sh/include/asm/io.h:185:2: note: in expansion of macro '__BUILD_IOPORT_PFX'
     __BUILD_IOPORT_PFX(, bwlq, type)
     ^
   arch/sh/include/asm/io.h:188:1: note: in expansion of macro 'BUILDIO_IOPORT'
    BUILDIO_IOPORT(w, u16)
    ^
   In file included from drivers/net/ethernet/smsc/smc91x.c:92:0:
   drivers/net/ethernet/smsc/smc91x.h:88:28: warning: passing argument 1 of 'inw' makes integer from pointer without a cast [-Wint-conversion]
    #define SMC_inw(a, r)  inw((a) + (r) - 0xa0000000)
                               ^
   drivers/net/ethernet/smsc/smc91x.h:439:13: note: in expansion of macro 'SMC_inw'
      __val16 = SMC_inw(ioaddr, reg);         \
                ^
>> drivers/net/ethernet/smsc/smc91x.h:957:26: note: in expansion of macro 'SMC_in16'
    #define SMC_GET_CTL(lp)  SMC_in16(ioaddr, CTL_REG(lp))
                             ^
   drivers/net/ethernet/smsc/smc91x.c:1201:8: note: in expansion of macro 'SMC_GET_CTL'
     ctl = SMC_GET_CTL(lp);
           ^
   In file included from include/linux/io.h:25:0,
                    from include/linux/irq.h:24,
                    from arch/sh/include/asm/hardirq.h:5,
                    from include/linux/hardirq.h:8,
                    from include/linux/interrupt.h:12,
                    from drivers/net/ethernet/smsc/smc91x.c:72:
   arch/sh/include/asm/io.h:168:25: note: expected 'long unsigned int' but argument is of type 'void *'
    static inline type pfx##in##bwlq##p(unsigned long port)   \
                            ^
   arch/sh/include/asm/io.h:181:2: note: in expansion of macro '__BUILD_IOPORT_SINGLE'
     __BUILD_IOPORT_SINGLE(bus, bwlq, type, ,)   \
     ^
   arch/sh/include/asm/io.h:185:2: note: in expansion of macro '__BUILD_IOPORT_PFX'
     __BUILD_IOPORT_PFX(, bwlq, type)
     ^
   arch/sh/include/asm/io.h:188:1: note: in expansion of macro 'BUILDIO_IOPORT'
    BUILDIO_IOPORT(w, u16)
    ^
   In file included from drivers/net/ethernet/smsc/smc91x.c:92:0:
   drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
   drivers/net/ethernet/smsc/smc91x.h:959:28: note: in expansion of macro 'SMC_out16'
    #define SMC_SET_CTL(lp, x) SMC_out16(x, ioaddr, CTL_REG(lp))
                               ^
   drivers/net/ethernet/smsc/smc91x.c:1202:2: note: in expansion of macro 'SMC_SET_CTL'
     SMC_SET_CTL(lp, ctl & ~CTL_LE_ENABLE);
     ^
   drivers/net/ethernet/smsc/smc91x.h:91:35: warning: passing argument 2 of 'outw' makes integer from pointer without a cast [-Wint-conversion]
    #define SMC_outw(v, a, r) outw(v, (a) + (r) - 0xa0000000)
                                      ^
   drivers/net/ethernet/smsc/smc91x.h:428:3: note: in expansion of macro 'SMC_outw'
      SMC_outw(x, ioaddr, reg);         \
      ^
   drivers/net/ethernet/smsc/smc91x.h:959:28: note: in expansion of macro 'SMC_out16'
    #define SMC_SET_CTL(lp, x) SMC_out16(x, ioaddr, CTL_REG(lp))
                               ^
   drivers/net/ethernet/smsc/smc91x.c:1202:2: note: in expansion of macro 'SMC_SET_CTL'
     SMC_SET_CTL(lp, ctl & ~CTL_LE_ENABLE);
     ^
   In file included from include/linux/io.h:25:0,
                    from include/linux/irq.h:24,
                    from arch/sh/include/asm/hardirq.h:5,
                    from include/linux/hardirq.h:8,
                    from include/linux/interrupt.h:12,
                    from drivers/net/ethernet/smsc/smc91x.c:72:
   arch/sh/include/asm/io.h:159:25: note: expected 'long unsigned int' but argument is of type 'void *'
    static inline void pfx##out##bwlq##p(type val, unsigned long port) \
                            ^
   arch/sh/include/asm/io.h:181:2: note: in expansion of macro '__BUILD_IOPORT_SINGLE'
     __BUILD_IOPORT_SINGLE(bus, bwlq, type, ,)   \
     ^
   arch/sh/include/asm/io.h:185:2: note: in expansion of macro '__BUILD_IOPORT_PFX'
     __BUILD_IOPORT_PFX(, bwlq, type)
     ^
   arch/sh/include/asm/io.h:188:1: note: in expansion of macro 'BUILDIO_IOPORT'
    BUILDIO_IOPORT(w, u16)
    ^
   In file included from drivers/net/ethernet/smsc/smc91x.c:92:0:
   drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
   drivers/net/ethernet/smsc/smc91x.h:959:28: note: in expansion of macro 'SMC_out16'
    #define SMC_SET_CTL(lp, x) SMC_out16(x, ioaddr, CTL_REG(lp))
                               ^
   drivers/net/ethernet/smsc/smc91x.c:1203:2: note: in expansion of macro 'SMC_SET_CTL'
     SMC_SET_CTL(lp, ctl);
     ^
   drivers/net/ethernet/smsc/smc91x.h:91:35: warning: passing argument 2 of 'outw' makes integer from pointer without a cast [-Wint-conversion]
    #define SMC_outw(v, a, r) outw(v, (a) + (r) - 0xa0000000)
                                      ^
   drivers/net/ethernet/smsc/smc91x.h:428:3: note: in expansion of macro 'SMC_outw'
      SMC_outw(x, ioaddr, reg);         \
      ^
   drivers/net/ethernet/smsc/smc91x.h:959:28: note: in expansion of macro 'SMC_out16'
    #define SMC_SET_CTL(lp, x) SMC_out16(x, ioaddr, CTL_REG(lp))
                               ^
   drivers/net/ethernet/smsc/smc91x.c:1203:2: note: in expansion of macro 'SMC_SET_CTL'
     SMC_SET_CTL(lp, ctl);
     ^
   In file included from include/linux/io.h:25:0,
                    from include/linux/irq.h:24,
                    from arch/sh/include/asm/hardirq.h:5,
                    from include/linux/hardirq.h:8,
                    from include/linux/interrupt.h:12,
                    from drivers/net/ethernet/smsc/smc91x.c:72:
   arch/sh/include/asm/io.h:159:25: note: expected 'long unsigned int' but argument is of type 'void *'
    static inline void pfx##out##bwlq##p(type val, unsigned long port) \
                            ^
   arch/sh/include/asm/io.h:181:2: note: in expansion of macro '__BUILD_IOPORT_SINGLE'
     __BUILD_IOPORT_SINGLE(bus, bwlq, type, ,)   \
     ^
   arch/sh/include/asm/io.h:185:2: note: in expansion of macro '__BUILD_IOPORT_PFX'
     __BUILD_IOPORT_PFX(, bwlq, type)
     ^
..

vim +/SMC_in16 +957 drivers/net/ethernet/smsc/smc91x.h

   941			if (SMC_MUST_ALIGN_WRITE(lp))				\
   942				SMC_outl((x)<<16, ioaddr, 12<<SMC_IO_SHIFT);	\
   943			else							\
   944				SMC_out16(x, ioaddr, BANK_SELECT);		\
   945		} while (0)
   946	
   947	#define SMC_GET_BASE(lp)	SMC_in16(ioaddr, BASE_REG(lp))
   948	
   949	#define SMC_SET_BASE(lp, x)	SMC_out16(x, ioaddr, BASE_REG(lp))
   950	
   951	#define SMC_GET_CONFIG(lp)	SMC_in16(ioaddr, CONFIG_REG(lp))
   952	
   953	#define SMC_SET_CONFIG(lp, x)	SMC_out16(x, ioaddr, CONFIG_REG(lp))
   954	
   955	#define SMC_GET_COUNTER(lp)	SMC_in16(ioaddr, COUNTER_REG(lp))
   956	
 > 957	#define SMC_GET_CTL(lp)		SMC_in16(ioaddr, CTL_REG(lp))
   958	
   959	#define SMC_SET_CTL(lp, x)	SMC_out16(x, ioaddr, CTL_REG(lp))
   960	
   961	#define SMC_GET_MII(lp)		SMC_in16(ioaddr, MII_REG(lp))
   962	
   963	#define SMC_GET_GP(lp)		SMC_in16(ioaddr, GP_REG(lp))
   964	
   965	#define SMC_SET_GP(lp, x)						\

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--wac7ysb48OaltWcw
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--wac7ysb48OaltWcw--
