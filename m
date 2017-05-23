From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v4 next 3/3] modules:capabilities: add a per-task modules
 auto-load mode
Date: Tue, 23 May 2017 22:18:58 +0800
Message-ID: <201705232255.t9X5Tbez%fengguang.wu@intel.com>
References: <1495454226-10027-4-git-send-email-tixxdz@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="jRHKVT23PllUwdXP"
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
        kernel-hardening@lists.openwall.com,
        Andy Lutomirski <luto@kernel.org>,
        Kees Cook <keescook@chromium.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Rusty Russell <rusty@rustcorp.com.au>,
        "Serge E. Hallyn" <serge@hallyn.com>, Jessica Yu <jeyu@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <paul@paul-moore.com>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        Ingo Molnar <mingo@kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        Dongsu Park <dpark@posteo.net>,
        Casey Schaufler <casey@schaufler-c
To: Djalal Harouni <tixxdz@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1495454226-10027-4-git-send-email-tixxdz@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--jRHKVT23PllUwdXP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Djalal,

[auto build test ERROR on next-20170522]

url:    https://github.com/0day-ci/linux/commits/Djalal-Harouni/modules-automatic-module-loading-restrictions/20170523-193128
config: sparc64-allnoconfig (attached as .config)
compiler: sparc64-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
reproduce:
        wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=sparc64 

All errors (new ones prefixed by >>):

   In file included from arch/sparc/kernel/setup_64.c:32:0:
   include/linux/module.h:683:30: error: storage class specified for parameter '__module_address'
    static inline struct module *__module_address(unsigned long addr)
                                 ^~~~~~~~~~~~~~~~
   include/linux/module.h:683:30: error: parameter '__module_address' declared 'inline' [-Werror]
>> include/linux/module.h:684:1: error: 'always_inline' attribute ignored [-Werror=attributes]
    {
    ^
   include/linux/module.h:683:30: error: 'no_instrument_function' attribute applies only to functions
    static inline struct module *__module_address(unsigned long addr)
                                 ^~~~~~~~~~~~~~~~
   include/linux/module.h:684:1: error: expected ';', ',' or ')' before '{' token
    {
    ^
   cc1: all warnings being treated as errors

vim +/always_inline +684 include/linux/module.h

98702500 Djalal Harouni 2017-05-22  677  static inline int task_modules_autoload_mode(struct task_struct *task)
98702500 Djalal Harouni 2017-05-22  678  {
98702500 Djalal Harouni 2017-05-22  679  	return -ENOSYS;
98702500 Djalal Harouni 2017-05-22  680  }
98702500 Djalal Harouni 2017-05-22  681  
98702500 Djalal Harouni 2017-05-22  682  static inline bool within_module_core(unsigned long addr,
e610499e Rusty Russell  2009-03-31 @683  static inline struct module *__module_address(unsigned long addr)
e610499e Rusty Russell  2009-03-31 @684  {
e610499e Rusty Russell  2009-03-31  685  	return NULL;
e610499e Rusty Russell  2009-03-31  686  }
e610499e Rusty Russell  2009-03-31  687  

:::::: The code at line 684 was first introduced by commit
:::::: e610499e2656e61975affd0af56b26eb73964c84 module: __module_address

:::::: TO: Rusty Russell <rusty@rustcorp.com.au>
:::::: CC: Rusty Russell <rusty@rustcorp.com.au>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--jRHKVT23PllUwdXP
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
YP/tRducmXeC+EcWCMfGkP8H2xYOjX1IAAA=

--jRHKVT23PllUwdXP--
