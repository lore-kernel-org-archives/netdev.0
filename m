From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 1/7] lwt: Add net to build_state argument
Date: Thu, 15 Sep 2016 08:42:13 +0800
Message-ID: <201609150842.ZXSuouZ1%fengguang.wu@intel.com>
References: <1473895376-347096-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="4Ckj6UjgE2iN1+kY"
Cc: kbuild-all@01.org, davem@davemloft.net, netdev@vger.kernel.org,
        tgraf@suug.ch, roopa@cumulusnetworks.com, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:30782 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754432AbcIOAnG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 20:43:06 -0400
Content-Disposition: inline
In-Reply-To: <1473895376-347096-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Tom,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Tom-Herbert/net-ILA-resolver-and-generic-resolver-backend/20160915-073357
config: microblaze-mmu_defconfig (attached as .config)
compiler: microblaze-linux-gcc (GCC) 4.9.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=microblaze 

All warnings (new ones prefixed by >>):

   net/ipv4/fib_semantics.c: In function 'fib_encap_match':
>> net/ipv4/fib_semantics.c:614:8: warning: passing argument 1 of 'lwtunnel_build_state' from incompatible pointer type
     ret = lwtunnel_build_state(net, dev, encap_type, encap,
           ^
   In file included from net/ipv4/fib_semantics.c:45:0:
   include/net/lwtunnel.h:172:19: note: expected 'struct net_device *' but argument is of type 'struct net *'
    static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
                      ^
   net/ipv4/fib_semantics.c:614:8: warning: passing argument 2 of 'lwtunnel_build_state' makes integer from pointer without a cast
     ret = lwtunnel_build_state(net, dev, encap_type, encap,
           ^
   In file included from net/ipv4/fib_semantics.c:45:0:
   include/net/lwtunnel.h:172:19: note: expected 'u16' but argument is of type 'struct net_device *'
    static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
                      ^
   net/ipv4/fib_semantics.c:614:8: warning: passing argument 3 of 'lwtunnel_build_state' makes pointer from integer without a cast
     ret = lwtunnel_build_state(net, dev, encap_type, encap,
           ^
   In file included from net/ipv4/fib_semantics.c:45:0:
   include/net/lwtunnel.h:172:19: note: expected 'struct nlattr *' but argument is of type 'u16'
    static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
                      ^
   net/ipv4/fib_semantics.c:614:8: warning: passing argument 4 of 'lwtunnel_build_state' makes integer from pointer without a cast
     ret = lwtunnel_build_state(net, dev, encap_type, encap,
           ^
   In file included from net/ipv4/fib_semantics.c:45:0:
   include/net/lwtunnel.h:172:19: note: expected 'unsigned int' but argument is of type 'struct nlattr *'
    static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
                      ^
   net/ipv4/fib_semantics.c:614:8: warning: passing argument 5 of 'lwtunnel_build_state' makes pointer from integer without a cast
     ret = lwtunnel_build_state(net, dev, encap_type, encap,
           ^
   In file included from net/ipv4/fib_semantics.c:45:0:
   include/net/lwtunnel.h:172:19: note: expected 'const void *' but argument is of type 'int'
    static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
                      ^
   net/ipv4/fib_semantics.c:614:8: warning: passing argument 6 of 'lwtunnel_build_state' from incompatible pointer type
     ret = lwtunnel_build_state(net, dev, encap_type, encap,
           ^
   In file included from net/ipv4/fib_semantics.c:45:0:
   include/net/lwtunnel.h:172:19: note: expected 'struct lwtunnel_state **' but argument is of type 'const struct fib_config *'
    static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
                      ^
   net/ipv4/fib_semantics.c:614:8: error: too many arguments to function 'lwtunnel_build_state'
     ret = lwtunnel_build_state(net, dev, encap_type, encap,
           ^
   In file included from net/ipv4/fib_semantics.c:45:0:
   include/net/lwtunnel.h:172:19: note: declared here
    static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
                      ^
   net/ipv4/fib_semantics.c: In function 'fib_create_info':
   net/ipv4/fib_semantics.c:1102:10: warning: passing argument 1 of 'lwtunnel_build_state' from incompatible pointer type
       err = lwtunnel_build_state(net, dev, cfg->fc_encap_type,
             ^
   In file included from net/ipv4/fib_semantics.c:45:0:
   include/net/lwtunnel.h:172:19: note: expected 'struct net_device *' but argument is of type 'struct net *'
    static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
                      ^
   net/ipv4/fib_semantics.c:1102:10: warning: passing argument 2 of 'lwtunnel_build_state' makes integer from pointer without a cast
       err = lwtunnel_build_state(net, dev, cfg->fc_encap_type,
             ^
   In file included from net/ipv4/fib_semantics.c:45:0:
   include/net/lwtunnel.h:172:19: note: expected 'u16' but argument is of type 'struct net_device *'
    static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
                      ^
   net/ipv4/fib_semantics.c:1102:10: warning: passing argument 3 of 'lwtunnel_build_state' makes pointer from integer without a cast
       err = lwtunnel_build_state(net, dev, cfg->fc_encap_type,
             ^
   In file included from net/ipv4/fib_semantics.c:45:0:
   include/net/lwtunnel.h:172:19: note: expected 'struct nlattr *' but argument is of type 'u16'
    static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
                      ^
   net/ipv4/fib_semantics.c:1102:10: warning: passing argument 4 of 'lwtunnel_build_state' makes integer from pointer without a cast
       err = lwtunnel_build_state(net, dev, cfg->fc_encap_type,
             ^
   In file included from net/ipv4/fib_semantics.c:45:0:
   include/net/lwtunnel.h:172:19: note: expected 'unsigned int' but argument is of type 'struct nlattr *'
    static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
                      ^
   net/ipv4/fib_semantics.c:1102:10: warning: passing argument 5 of 'lwtunnel_build_state' makes pointer from integer without a cast
       err = lwtunnel_build_state(net, dev, cfg->fc_encap_type,
             ^
   In file included from net/ipv4/fib_semantics.c:45:0:
   include/net/lwtunnel.h:172:19: note: expected 'const void *' but argument is of type 'int'
    static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
                      ^
   net/ipv4/fib_semantics.c:1102:10: warning: passing argument 6 of 'lwtunnel_build_state' from incompatible pointer type
       err = lwtunnel_build_state(net, dev, cfg->fc_encap_type,
             ^
   In file included from net/ipv4/fib_semantics.c:45:0:
   include/net/lwtunnel.h:172:19: note: expected 'struct lwtunnel_state **' but argument is of type 'struct fib_config *'
    static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
                      ^
   net/ipv4/fib_semantics.c:1102:10: error: too many arguments to function 'lwtunnel_build_state'
       err = lwtunnel_build_state(net, dev, cfg->fc_encap_type,
             ^
   In file included from net/ipv4/fib_semantics.c:45:0:
   include/net/lwtunnel.h:172:19: note: declared here
    static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
                      ^

vim +/lwtunnel_build_state +614 net/ipv4/fib_semantics.c

   598	#endif /* CONFIG_IP_ROUTE_MULTIPATH */
   599	
   600	static int fib_encap_match(struct net *net, u16 encap_type,
   601				   struct nlattr *encap,
   602				   int oif, const struct fib_nh *nh,
   603				   const struct fib_config *cfg)
   604	{
   605		struct lwtunnel_state *lwtstate;
   606		struct net_device *dev = NULL;
   607		int ret, result = 0;
   608	
   609		if (encap_type == LWTUNNEL_ENCAP_NONE)
   610			return 0;
   611	
   612		if (oif)
   613			dev = __dev_get_by_index(net, oif);
 > 614		ret = lwtunnel_build_state(net, dev, encap_type, encap,
   615					   AF_INET, cfg, &lwtstate);
   616		if (!ret) {
   617			result = lwtunnel_cmp_encap(lwtstate, nh->nh_lwtstate);
   618			lwtstate_free(lwtstate);
   619		}
   620	
   621		return result;
   622	}

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--4Ckj6UjgE2iN1+kY
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--4Ckj6UjgE2iN1+kY--
