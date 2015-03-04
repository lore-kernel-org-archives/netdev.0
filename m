From: kbuild test robot <fengguang.wu@intel.com>
Subject: [jtkirshe-net-next:community 284/296] net/mpls/af_mpls.c:215:25:
 sparse: symbol 'rtm_mpls_policy' was not declared. Should it be static?
Date: Thu, 5 Mar 2015 05:33:53 +0800
Message-ID: <201503050540.GRC4YbDo%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54389 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753020AbbCDVeW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2015 16:34:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   jtkirshe-net-next/community
head:   2d7208e1fa7f4f7667632746c0e1b6fa3640e0b3
commit: 03c0566542f4c7a45ce3193f27cbf5700b506c18 [284/296] mpls: Netlink commands to add, remove, and dump routes
reproduce:
  # apt-get install sparse
  git checkout 03c0566542f4c7a45ce3193f27cbf5700b506c18
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> net/mpls/af_mpls.c:215:25: sparse: symbol 'rtm_mpls_policy' was not declared. Should it be static?
   net/mpls/af_mpls.c:237:22: sparse: incorrect type in argument 1 (different base types)
   net/mpls/af_mpls.c:237:22:    expected unsigned long [unsigned] [usertype] size
   net/mpls/af_mpls.c:237:22:    got restricted gfp_t
   net/mpls/af_mpls.c:237:46: sparse: incorrect type in argument 2 (different base types)
   net/mpls/af_mpls.c:237:46:    expected restricted gfp_t [usertype] flags
   net/mpls/af_mpls.c:237:46:    got unsigned long
   net/mpls/af_mpls.c:257:12: sparse: incorrect type in assignment (different address spaces)
   net/mpls/af_mpls.c:257:12:    expected struct mpls_route *rt
   net/mpls/af_mpls.c:257:12:    got struct mpls_route [noderef] <asn:4>*[noderef] <asn:4><noident>
   net/mpls/af_mpls.c:259:17: sparse: cast removes address space of expression
   net/mpls/af_mpls.c:327:13: sparse: incorrect type in assignment (different address spaces)
   net/mpls/af_mpls.c:327:13:    expected struct mpls_route *old
   net/mpls/af_mpls.c:327:13:    got struct mpls_route [noderef] <asn:4>*[noderef] <asn:4><noident>
   net/mpls/af_mpls.c:392:65: sparse: incorrect type in initializer (different address spaces)
   net/mpls/af_mpls.c:392:65:    expected struct mpls_route *rt
   net/mpls/af_mpls.c:392:65:    got struct mpls_route [noderef] <asn:4>*[noderef] <asn:4><noident>
   net/mpls/af_mpls.c:681:20: sparse: incorrect type in assignment (different address spaces)
   net/mpls/af_mpls.c:681:20:    expected struct mpls_route *rt
   net/mpls/af_mpls.c:681:20:    got struct mpls_route [noderef] <asn:4>*[noderef] <asn:4><noident>
   net/mpls/af_mpls.c:737:13: sparse: incorrect type in assignment (different address spaces)
   net/mpls/af_mpls.c:737:13:    expected struct mpls_route [noderef] <asn:4>**old
   net/mpls/af_mpls.c:737:13:    got struct mpls_route [noderef] <asn:4>*[noderef] <asn:4>*platform_label
   net/mpls/af_mpls.c:754:50: sparse: incorrect type in assignment (different address spaces)
   net/mpls/af_mpls.c:754:50:    expected struct mpls_route [noderef] <asn:4>*<noident>
   net/mpls/af_mpls.c:754:50:    got struct mpls_route *[assigned] rt2
   net/mpls/af_mpls.c:760:50: sparse: incorrect type in assignment (different address spaces)
   net/mpls/af_mpls.c:760:50:    expected struct mpls_route [noderef] <asn:4>*<noident>
   net/mpls/af_mpls.c:760:50:    got struct mpls_route *[assigned] rt0
   net/mpls/af_mpls.c:766:34: sparse: incorrect type in assignment (different address spaces)
   net/mpls/af_mpls.c:766:34:    expected struct mpls_route [noderef] <asn:4>*[noderef] <asn:4>*platform_label
   net/mpls/af_mpls.c:766:34:    got struct mpls_route [noderef] <asn:4>**[assigned] labels
   net/mpls/af_mpls.c:860:65: sparse: incorrect type in initializer (different address spaces)
   net/mpls/af_mpls.c:860:65:    expected struct mpls_route *rt
   net/mpls/af_mpls.c:860:65:    got struct mpls_route [noderef] <asn:4>*[noderef] <asn:4><noident>
   net/mpls/af_mpls.c:861:17: sparse: cast removes address space of expression
   net/mpls/af_mpls.c:866:25: sparse: incorrect type in argument 1 (different address spaces)
   net/mpls/af_mpls.c:866:25:    expected void const *addr
   net/mpls/af_mpls.c:866:25:    got struct mpls_route [noderef] <asn:4>*[noderef] <asn:4>*platform_label
   net/mpls/af_mpls.c:271:46: sparse: dereference of noderef expression
   net/mpls/af_mpls.c:392:65: sparse: dereference of noderef expression
   net/mpls/af_mpls.c:860:65: sparse: dereference of noderef expression

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
