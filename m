From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 1847/1910] drivers/s390/net/ctcm_fsms.c:220:14:
 error: passing argument 2 of 'atomic_add' from incompatible pointer type
Date: Sun, 2 Jul 2017 11:29:25 +0800
Message-ID: <201707021118.OZcdUfzn%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="mP3DRpeJDSE+ciuQ"
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
        Hans Liljestrand <ishkamiel@gmail.com>,
        Kees Cook <keescook@chromium.org>,
        David Windsor <dave@nullcore.net>
To: "Reshetova, Elena" <elena.reshetova@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51427 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751697AbdGBD3s (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 1 Jul 2017 23:29:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--mP3DRpeJDSE+ciuQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   bcdb239b456265b927a809c4078f0a1f433a6e18
commit: 633547973ffc32fd2c815639d4675e1531f0896f [1847/1910] net: convert sk_buff.users from atomic_t to refcount_t
config: s390-default_defconfig (attached as .config)
compiler: s390x-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
reproduce:
        wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 633547973ffc32fd2c815639d4675e1531f0896f
        # save the attached .config to linux build tree
        make.cross ARCH=s390 

All errors (new ones prefixed by >>):

   In file included from include/linux/atomic.h:4:0,
                    from include/linux/debug_locks.h:5,
                    from include/linux/lockdep.h:25,
                    from include/linux/spinlock_types.h:18,
                    from include/linux/spinlock.h:81,
                    from include/linux/seqlock.h:35,
                    from include/linux/time.h:5,
                    from include/linux/stat.h:18,
                    from include/linux/module.h:10,
                    from drivers/s390/net/ctcm_fsms.c:17:
   drivers/s390/net/ctcm_fsms.c: In function 'ctcm_purge_skb_queue':
>> drivers/s390/net/ctcm_fsms.c:220:14: error: passing argument 2 of 'atomic_add' from incompatible pointer type [-Werror=incompatible-pointer-types]
      atomic_dec(&skb->users);
                 ^
   arch/s390/include/asm/atomic.h:61:52: note: in definition of macro 'atomic_sub'
    #define atomic_sub(_i, _v)  atomic_add(-(int)(_i), _v)
                                                       ^~
   drivers/s390/net/ctcm_fsms.c:220:3: note: in expansion of macro 'atomic_dec'
      atomic_dec(&skb->users);
      ^~~~~~~~~~
   arch/s390/include/asm/atomic.h:46:20: note: expected 'atomic_t * {aka struct <anonymous> *}' but argument is of type 'refcount_t * {aka struct refcount_struct *}'
    static inline void atomic_add(int i, atomic_t *v)
                       ^~~~~~~~~~
   drivers/s390/net/ctcm_fsms.c: In function 'chx_txdone':
   drivers/s390/net/ctcm_fsms.c:274:14: error: passing argument 2 of 'atomic_add' from incompatible pointer type [-Werror=incompatible-pointer-types]
      atomic_dec(&skb->users);
                 ^
   arch/s390/include/asm/atomic.h:61:52: note: in definition of macro 'atomic_sub'
    #define atomic_sub(_i, _v)  atomic_add(-(int)(_i), _v)
                                                       ^~
   drivers/s390/net/ctcm_fsms.c:274:3: note: in expansion of macro 'atomic_dec'
      atomic_dec(&skb->users);
      ^~~~~~~~~~
   arch/s390/include/asm/atomic.h:46:20: note: expected 'atomic_t * {aka struct <anonymous> *}' but argument is of type 'refcount_t * {aka struct refcount_struct *}'
    static inline void atomic_add(int i, atomic_t *v)
                       ^~~~~~~~~~
   drivers/s390/net/ctcm_fsms.c:300:15: error: passing argument 2 of 'atomic_add' from incompatible pointer type [-Werror=incompatible-pointer-types]
       atomic_dec(&skb->users);
                  ^
   arch/s390/include/asm/atomic.h:61:52: note: in definition of macro 'atomic_sub'
    #define atomic_sub(_i, _v)  atomic_add(-(int)(_i), _v)
                                                       ^~
   drivers/s390/net/ctcm_fsms.c:300:4: note: in expansion of macro 'atomic_dec'
       atomic_dec(&skb->users);
       ^~~~~~~~~~
   arch/s390/include/asm/atomic.h:46:20: note: expected 'atomic_t * {aka struct <anonymous> *}' but argument is of type 'refcount_t * {aka struct refcount_struct *}'
    static inline void atomic_add(int i, atomic_t *v)
                       ^~~~~~~~~~
   drivers/s390/net/ctcm_fsms.c: In function 'ctcmpc_chx_txdone':
   drivers/s390/net/ctcm_fsms.c:1251:14: error: passing argument 2 of 'atomic_add' from incompatible pointer type [-Werror=incompatible-pointer-types]
      atomic_dec(&skb->users);
                 ^
   arch/s390/include/asm/atomic.h:61:52: note: in definition of macro 'atomic_sub'
    #define atomic_sub(_i, _v)  atomic_add(-(int)(_i), _v)
                                                       ^~
   drivers/s390/net/ctcm_fsms.c:1251:3: note: in expansion of macro 'atomic_dec'
      atomic_dec(&skb->users);
      ^~~~~~~~~~
   arch/s390/include/asm/atomic.h:46:20: note: expected 'atomic_t * {aka struct <anonymous> *}' but argument is of type 'refcount_t * {aka struct refcount_struct *}'
    static inline void atomic_add(int i, atomic_t *v)
                       ^~~~~~~~~~
   drivers/s390/net/ctcm_fsms.c:1301:14: error: passing argument 2 of 'atomic_add' from incompatible pointer type [-Werror=incompatible-pointer-types]
      atomic_dec(&skb->users);
                 ^
   arch/s390/include/asm/atomic.h:61:52: note: in definition of macro 'atomic_sub'
    #define atomic_sub(_i, _v)  atomic_add(-(int)(_i), _v)
                                                       ^~
   drivers/s390/net/ctcm_fsms.c:1301:3: note: in expansion of macro 'atomic_dec'
      atomic_dec(&skb->users);
      ^~~~~~~~~~
   arch/s390/include/asm/atomic.h:46:20: note: expected 'atomic_t * {aka struct <anonymous> *}' but argument is of type 'refcount_t * {aka struct refcount_struct *}'
    static inline void atomic_add(int i, atomic_t *v)
                       ^~~~~~~~~~
   drivers/s390/net/ctcm_fsms.c: In function 'ctcmpc_chx_send_sweep':
   drivers/s390/net/ctcm_fsms.c:1798:14: error: passing argument 2 of 'atomic_add' from incompatible pointer type [-Werror=incompatible-pointer-types]
      atomic_inc(&skb->users);
                 ^
   arch/s390/include/asm/atomic.h:58:40: note: in definition of macro 'atomic_inc'
    #define atomic_inc(_v)   atomic_add(1, _v)
                                           ^~
   arch/s390/include/asm/atomic.h:46:20: note: expected 'atomic_t * {aka struct <anonymous> *}' but argument is of type 'refcount_t * {aka struct refcount_struct *}'
    static inline void atomic_add(int i, atomic_t *v)
                       ^~~~~~~~~~
   cc1: some warnings being treated as errors

vim +/atomic_add +220 drivers/s390/net/ctcm_fsms.c

293d984f Peter Tiedemann 2008-02-08  214  {
293d984f Peter Tiedemann 2008-02-08  215  	struct sk_buff *skb;
293d984f Peter Tiedemann 2008-02-08  216  
aa3f2cb6 Peter Tiedemann 2008-07-18  217  	CTCM_DBF_TEXT(TRACE, CTC_DBF_DEBUG, __func__);
293d984f Peter Tiedemann 2008-02-08  218  
293d984f Peter Tiedemann 2008-02-08  219  	while ((skb = skb_dequeue(q))) {
293d984f Peter Tiedemann 2008-02-08 @220  		atomic_dec(&skb->users);
293d984f Peter Tiedemann 2008-02-08  221  		dev_kfree_skb_any(skb);
293d984f Peter Tiedemann 2008-02-08  222  	}
293d984f Peter Tiedemann 2008-02-08  223  }

:::::: The code at line 220 was first introduced by commit
:::::: 293d984f0e3604c04dcdbf00117ddc1e5d4b1909 ctcm: infrastructure for replaced ctc driver

:::::: TO: Peter Tiedemann <ptiedem@de.ibm.com>
:::::: CC: Jeff Garzik <jeff@garzik.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--mP3DRpeJDSE+ciuQ
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
l67h3QwbmzLTMYyNRdX/AWVqqX/KEAEA

--mP3DRpeJDSE+ciuQ--
