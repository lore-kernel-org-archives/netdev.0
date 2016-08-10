From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 2/4] flow_dissector: Get vlan priority in
 addition to vlan id
Date: Thu, 11 Aug 2016 05:54:04 +0800
Message-ID: <201608110512.NtMEBDul%fengguang.wu@intel.com>
References: <1470835943-9042-3-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="UugvWAfsgieZRqgk"
Cc: kbuild-all@01.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
	Tom Herbert <tom@herbertland.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:34972 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750998AbcHJVym (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2016 17:54:42 -0400
Content-Disposition: inline
In-Reply-To: <1470835943-9042-3-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Hadar,

[auto build test ERROR on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Hadar-Hen-Zion/flow_dissector-Get-vlan-info-from-skb-vlan_tci-instead-of-skb-data/20160811-042500
config: m68k-sun3_defconfig (attached as .config)
compiler: m68k-linux-gcc (GCC) 4.9.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=m68k 

All error/warnings (new ones prefixed by >>):

   In file included from include/linux/linkage.h:4:0,
                    from include/linux/kernel.h:6,
                    from net/core/flow_dissector.c:1:
   In function 'flow_keys_hash_length.isra.3',
       inlined from 'flow_hash_from_keys' at net/core/flow_dissector.c:599:9:
>> include/linux/compiler.h:491:38: error: call to '__compiletime_assert_512' declared with attribute error: BUILD_BUG_ON failed: (sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) % sizeof(u32)
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                         ^
   include/linux/compiler.h:474:4: note: in definition of macro '__compiletime_assert'
       prefix ## suffix();    \
       ^
   include/linux/compiler.h:491:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^
   include/linux/bug.h:51:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^
   include/linux/bug.h:75:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
     ^
>> net/core/flow_dissector.c:512:2: note: in expansion of macro 'BUILD_BUG_ON'
     BUILD_BUG_ON((sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) % sizeof(u32));
     ^
   In function 'flow_keys_hash_length.isra.3',
       inlined from '__skb_get_hash' at net/core/flow_dissector.c:599:9:
>> include/linux/compiler.h:491:38: error: call to '__compiletime_assert_512' declared with attribute error: BUILD_BUG_ON failed: (sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) % sizeof(u32)
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                         ^
   include/linux/compiler.h:474:4: note: in definition of macro '__compiletime_assert'
       prefix ## suffix();    \
       ^
   include/linux/compiler.h:491:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^
   include/linux/bug.h:51:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^
   include/linux/bug.h:75:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
     ^
>> net/core/flow_dissector.c:512:2: note: in expansion of macro 'BUILD_BUG_ON'
     BUILD_BUG_ON((sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) % sizeof(u32));
     ^
   In function 'flow_keys_hash_length.isra.3',
       inlined from 'skb_get_hash_perturb' at net/core/flow_dissector.c:599:9:
>> include/linux/compiler.h:491:38: error: call to '__compiletime_assert_512' declared with attribute error: BUILD_BUG_ON failed: (sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) % sizeof(u32)
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                         ^
   include/linux/compiler.h:474:4: note: in definition of macro '__compiletime_assert'
       prefix ## suffix();    \
       ^
   include/linux/compiler.h:491:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^
   include/linux/bug.h:51:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^
   include/linux/bug.h:75:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
     ^
>> net/core/flow_dissector.c:512:2: note: in expansion of macro 'BUILD_BUG_ON'
     BUILD_BUG_ON((sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) % sizeof(u32));
     ^
   In function 'flow_keys_hash_length.isra.3',
       inlined from '__skb_get_hash_symmetric' at net/core/flow_dissector.c:599:9:
>> include/linux/compiler.h:491:38: error: call to '__compiletime_assert_512' declared with attribute error: BUILD_BUG_ON failed: (sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) % sizeof(u32)
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                         ^
   include/linux/compiler.h:474:4: note: in definition of macro '__compiletime_assert'
       prefix ## suffix();    \
       ^
   include/linux/compiler.h:491:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^
   include/linux/bug.h:51:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^
   include/linux/bug.h:75:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
     ^
>> net/core/flow_dissector.c:512:2: note: in expansion of macro 'BUILD_BUG_ON'
     BUILD_BUG_ON((sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) % sizeof(u32));
     ^

vim +/BUILD_BUG_ON +512 net/core/flow_dissector.c

20a17bf6 David S. Miller      2015-09-01  496  					     u32 keyval)
42aecaa9 Tom Herbert          2015-06-04  497  {
42aecaa9 Tom Herbert          2015-06-04  498  	return jhash2(words, length, keyval);
42aecaa9 Tom Herbert          2015-06-04  499  }
42aecaa9 Tom Herbert          2015-06-04  500  
20a17bf6 David S. Miller      2015-09-01  501  static inline const u32 *flow_keys_hash_start(const struct flow_keys *flow)
66415cf8 Hannes Frederic Sowa 2013-10-23  502  {
20a17bf6 David S. Miller      2015-09-01  503  	const void *p = flow;
20a17bf6 David S. Miller      2015-09-01  504  
42aecaa9 Tom Herbert          2015-06-04  505  	BUILD_BUG_ON(FLOW_KEYS_HASH_OFFSET % sizeof(u32));
20a17bf6 David S. Miller      2015-09-01  506  	return (const u32 *)(p + FLOW_KEYS_HASH_OFFSET);
42aecaa9 Tom Herbert          2015-06-04  507  }
42aecaa9 Tom Herbert          2015-06-04  508  
20a17bf6 David S. Miller      2015-09-01  509  static inline size_t flow_keys_hash_length(const struct flow_keys *flow)
42aecaa9 Tom Herbert          2015-06-04  510  {
c3f83241 Tom Herbert          2015-06-04  511  	size_t diff = FLOW_KEYS_HASH_OFFSET + sizeof(flow->addrs);
42aecaa9 Tom Herbert          2015-06-04 @512  	BUILD_BUG_ON((sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) % sizeof(u32));
c3f83241 Tom Herbert          2015-06-04  513  	BUILD_BUG_ON(offsetof(typeof(*flow), addrs) !=
c3f83241 Tom Herbert          2015-06-04  514  		     sizeof(*flow) - sizeof(flow->addrs));
c3f83241 Tom Herbert          2015-06-04  515  
c3f83241 Tom Herbert          2015-06-04  516  	switch (flow->control.addr_type) {
c3f83241 Tom Herbert          2015-06-04  517  	case FLOW_DISSECTOR_KEY_IPV4_ADDRS:
c3f83241 Tom Herbert          2015-06-04  518  		diff -= sizeof(flow->addrs.v4addrs);
c3f83241 Tom Herbert          2015-06-04  519  		break;
c3f83241 Tom Herbert          2015-06-04  520  	case FLOW_DISSECTOR_KEY_IPV6_ADDRS:

:::::: The code at line 512 was first introduced by commit
:::::: 42aecaa9bb2bd57eb8d61b4565cee5d3640863fb net: Get skb hash over flow_keys structure

:::::: TO: Tom Herbert <tom@herbertland.com>
:::::: CC: David S. Miller <davem@davemloft.net>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--UugvWAfsgieZRqgk
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
3UwCTqiBarH/B1tuUQZwsAAA

--UugvWAfsgieZRqgk--
