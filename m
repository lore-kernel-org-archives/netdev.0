From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 1/2] smc91x: always use 8-bit access if necessary
Date: Fri, 26 Aug 2016 00:32:02 +0800
Message-ID: <201608260030.Cb4uir4X%fengguang.wu@intel.com>
References: <20160825144633.1850889-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bp/iNruPH9dso1Pn"
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


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Arnd,

[auto build test WARNING on net-next/master]
[also build test WARNING on v4.8-rc3 next-20160825]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
[Suggest to use git(>=2.9.0) format-patch --base=<commit> (or --base=auto for convenience) to record what (public, well-known) commit your patch series was built on]
[Check https://git-scm.com/docs/git-format-patch for more information]

url:    https://github.com/0day-ci/linux/commits/Arnd-Bergmann/smc91x-always-use-8-bit-access-if-necessary/20160825-225929
config: m32r-defconfig (attached as .config)
compiler: m32r-linux-gcc (GCC) 4.9.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=m32r 

All warnings (new ones prefixed by >>):

   In file included from drivers/net/ethernet/smsc/smc91x.c:92:0:
   drivers/net/ethernet/smsc/smc91x.h:444:0: warning: "SMC_insw" redefined
    #define SMC_insw(a, r, p, l)  BUG()
    ^
   drivers/net/ethernet/smsc/smc91x.h:110:0: note: this is the location of the previous definition
    #define SMC_insw(a, r, p, l) insw(((u32)a) + (r), p, l)
    ^
   drivers/net/ethernet/smsc/smc91x.h:445:0: warning: "SMC_outsw" redefined
    #define SMC_outsw(a, r, p, l)  BUG()
    ^
   drivers/net/ethernet/smsc/smc91x.h:111:0: note: this is the location of the previous definition
    #define SMC_outsw(a, r, p, l) outsw(((u32)a) + (r), p, l)
    ^
   drivers/net/ethernet/smsc/smc91x.h:455:0: warning: "SMC_inb" redefined
    #define SMC_inb(ioaddr, reg)  ({ BUG(); 0; })
    ^
   drivers/net/ethernet/smsc/smc91x.h:106:0: note: this is the location of the previous definition
    #define SMC_inb(a, r)  inb(((u32)a) + (r))
    ^
   drivers/net/ethernet/smsc/smc91x.h:456:0: warning: "SMC_outb" redefined
    #define SMC_outb(x, ioaddr, reg) BUG()
    ^
   drivers/net/ethernet/smsc/smc91x.h:108:0: note: this is the location of the previous definition
    #define SMC_outb(v, a, r) outb(v, ((u32)a) + (r))
    ^
   drivers/net/ethernet/smsc/smc91x.h:1128:2: error: #endif without #if
    #endif  /* _SMC91X_H_ */
     ^
   drivers/net/ethernet/smsc/smc91x.c: In function 'smc_reset':
>> drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
>> drivers/net/ethernet/smsc/smc91x.h:944:4: note: in expansion of macro 'SMC_out16'
       SMC_out16(x, ioaddr, BANK_SELECT);  \
       ^
   drivers/net/ethernet/smsc/smc91x.c:261:2: note: in expansion of macro 'SMC_SELECT_BANK'
     SMC_SELECT_BANK(lp, 2);
     ^
>> drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
>> drivers/net/ethernet/smsc/smc91x.h:944:4: note: in expansion of macro 'SMC_out16'
       SMC_out16(x, ioaddr, BANK_SELECT);  \
       ^
   drivers/net/ethernet/smsc/smc91x.c:278:2: note: in expansion of macro 'SMC_SELECT_BANK'
     SMC_SELECT_BANK(lp, 0);
     ^
>> drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
   drivers/net/ethernet/smsc/smc91x.h:999:28: note: in expansion of macro 'SMC_out16'
    #define SMC_SET_RCR(lp, x) SMC_out16(x, ioaddr, RCR_REG(lp))
                               ^
   drivers/net/ethernet/smsc/smc91x.c:279:2: note: in expansion of macro 'SMC_SET_RCR'
     SMC_SET_RCR(lp, RCR_SOFTRST);
     ^
>> drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
>> drivers/net/ethernet/smsc/smc91x.h:944:4: note: in expansion of macro 'SMC_out16'
       SMC_out16(x, ioaddr, BANK_SELECT);  \
       ^
   drivers/net/ethernet/smsc/smc91x.c:286:2: note: in expansion of macro 'SMC_SELECT_BANK'
     SMC_SELECT_BANK(lp, 1);
     ^
>> drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
   drivers/net/ethernet/smsc/smc91x.h:953:31: note: in expansion of macro 'SMC_out16'
    #define SMC_SET_CONFIG(lp, x) SMC_out16(x, ioaddr, CONFIG_REG(lp))
                                  ^
   drivers/net/ethernet/smsc/smc91x.c:304:2: note: in expansion of macro 'SMC_SET_CONFIG'
     SMC_SET_CONFIG(lp, cfg);
     ^
>> drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
>> drivers/net/ethernet/smsc/smc91x.h:944:4: note: in expansion of macro 'SMC_out16'
       SMC_out16(x, ioaddr, BANK_SELECT);  \
       ^
   drivers/net/ethernet/smsc/smc91x.c:317:2: note: in expansion of macro 'SMC_SELECT_BANK'
     SMC_SELECT_BANK(lp, 0);
     ^
>> drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
   drivers/net/ethernet/smsc/smc91x.h:999:28: note: in expansion of macro 'SMC_out16'
    #define SMC_SET_RCR(lp, x) SMC_out16(x, ioaddr, RCR_REG(lp))
                               ^
   drivers/net/ethernet/smsc/smc91x.c:318:2: note: in expansion of macro 'SMC_SET_RCR'
     SMC_SET_RCR(lp, RCR_CLEAR);
     ^
>> drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
   drivers/net/ethernet/smsc/smc91x.h:1015:28: note: in expansion of macro 'SMC_out16'
    #define SMC_SET_TCR(lp, x) SMC_out16(x, ioaddr, TCR_REG(lp))
                               ^
   drivers/net/ethernet/smsc/smc91x.c:319:2: note: in expansion of macro 'SMC_SET_TCR'
     SMC_SET_TCR(lp, TCR_CLEAR);
     ^
>> drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
>> drivers/net/ethernet/smsc/smc91x.h:944:4: note: in expansion of macro 'SMC_out16'
       SMC_out16(x, ioaddr, BANK_SELECT);  \
       ^
   drivers/net/ethernet/smsc/smc91x.c:321:2: note: in expansion of macro 'SMC_SELECT_BANK'
     SMC_SELECT_BANK(lp, 1);
     ^
>> drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
   drivers/net/ethernet/smsc/smc91x.h:959:28: note: in expansion of macro 'SMC_out16'
    #define SMC_SET_CTL(lp, x) SMC_out16(x, ioaddr, CTL_REG(lp))
                               ^
   drivers/net/ethernet/smsc/smc91x.c:333:2: note: in expansion of macro 'SMC_SET_CTL'
     SMC_SET_CTL(lp, ctl);
     ^
>> drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
>> drivers/net/ethernet/smsc/smc91x.h:944:4: note: in expansion of macro 'SMC_out16'
       SMC_out16(x, ioaddr, BANK_SELECT);  \
       ^
   drivers/net/ethernet/smsc/smc91x.c:336:2: note: in expansion of macro 'SMC_SELECT_BANK'
     SMC_SELECT_BANK(lp, 2);
     ^
>> drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
   drivers/net/ethernet/smsc/smc91x.h:981:32: note: in expansion of macro 'SMC_out16'
    #define SMC_SET_MMU_CMD(lp, x) SMC_out16(x, ioaddr, MMU_CMD_REG(lp))
                                   ^
   drivers/net/ethernet/smsc/smc91x.c:337:2: note: in expansion of macro 'SMC_SET_MMU_CMD'
     SMC_SET_MMU_CMD(lp, MC_RESET);
     ^
   drivers/net/ethernet/smsc/smc91x.c: In function 'smc_enable':
>> drivers/net/ethernet/smsc/smc91x.h:424:16: warning: unused variable '__val16' [-Wunused-variable]
      unsigned int __val16 = (x);         \
                   ^
>> drivers/net/ethernet/smsc/smc91x.h:944:4: note: in expansion of macro 'SMC_out16'
       SMC_out16(x, ioaddr, BANK_SELECT);  \
       ^
   drivers/net/ethernet/smsc/smc91x.c:353:2: note: in expansion of macro 'SMC_SELECT_BANK'
     SMC_SELECT_BANK(lp, 0);
     ^

vim +/__val16 +424 drivers/net/ethernet/smsc/smc91x.h

09779c6d drivers/net/smc91x.h               Nicolas Pitre 2006-03-20  408  #define SMC_insl(a, r, p, l)		BUG()
09779c6d drivers/net/smc91x.h               Nicolas Pitre 2006-03-20  409  #define SMC_outsl(a, r, p, l)		BUG()
09779c6d drivers/net/smc91x.h               Nicolas Pitre 2006-03-20  410  #endif
09779c6d drivers/net/smc91x.h               Nicolas Pitre 2006-03-20  411  
09779c6d drivers/net/smc91x.h               Nicolas Pitre 2006-03-20  412  #if !defined(SMC_insl) || !defined(SMC_outsl)
09779c6d drivers/net/smc91x.h               Nicolas Pitre 2006-03-20  413  #define SMC_insl(a, r, p, l)		BUG()
09779c6d drivers/net/smc91x.h               Nicolas Pitre 2006-03-20  414  #define SMC_outsl(a, r, p, l)		BUG()
09779c6d drivers/net/smc91x.h               Nicolas Pitre 2006-03-20  415  #endif
09779c6d drivers/net/smc91x.h               Nicolas Pitre 2006-03-20  416  
09779c6d drivers/net/smc91x.h               Nicolas Pitre 2006-03-20  417  /*
39e82d37 drivers/net/ethernet/smsc/smc91x.h Arnd Bergmann 2016-08-25  418   * Any 16-bit register access is performed with two 8-bit accesses if the
39e82d37 drivers/net/ethernet/smsc/smc91x.h Arnd Bergmann 2016-08-25  419   * hardware can't do it directly.
09779c6d drivers/net/smc91x.h               Nicolas Pitre 2006-03-20  420   */
39e82d37 drivers/net/ethernet/smsc/smc91x.h Arnd Bergmann 2016-08-25  421  #define SMC_out16(x, ioaddr, reg)					     \
09779c6d drivers/net/smc91x.h               Nicolas Pitre 2006-03-20  422  do {									     \
39e82d37 drivers/net/ethernet/smsc/smc91x.h Arnd Bergmann 2016-08-25  423  	if (SMC_CAN_USE_8BIT && !SMC_16BIT(lp)) {			     \
09779c6d drivers/net/smc91x.h               Nicolas Pitre 2006-03-20 @424  		unsigned int __val16 = (x);				     \
09779c6d drivers/net/smc91x.h               Nicolas Pitre 2006-03-20  425  		SMC_outb(__val16, ioaddr, reg );			     \
09779c6d drivers/net/smc91x.h               Nicolas Pitre 2006-03-20  426  		SMC_outb(__val16 >> 8, ioaddr, reg + (1 << SMC_IO_SHIFT));   \
39e82d37 drivers/net/ethernet/smsc/smc91x.h Arnd Bergmann 2016-08-25  427  	} else {							     \
39e82d37 drivers/net/ethernet/smsc/smc91x.h Arnd Bergmann 2016-08-25  428  		SMC_outw(x, ioaddr, reg);				     \
39e82d37 drivers/net/ethernet/smsc/smc91x.h Arnd Bergmann 2016-08-25  429  	}								     \
09779c6d drivers/net/smc91x.h               Nicolas Pitre 2006-03-20  430  } while (0)
39e82d37 drivers/net/ethernet/smsc/smc91x.h Arnd Bergmann 2016-08-25  431  
39e82d37 drivers/net/ethernet/smsc/smc91x.h Arnd Bergmann 2016-08-25  432  #define SMC_in16(ioaddr, reg)						     \

:::::: The code at line 424 was first introduced by commit
:::::: 09779c6df2dbe95483269d194b327d41fe2cc57e [PATCH] smc91x: allow for dynamic bus access configs

:::::: TO: Nicolas Pitre <nico@cam.org>
:::::: CC: Jeff Garzik <jeff@garzik.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--bp/iNruPH9dso1Pn
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--bp/iNruPH9dso1Pn--
