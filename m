From: kbuild test robot <fengguang.wu@intel.com>
Subject: net/ipv4/tcp_ipv4.c:950:23: sparse: symbol 'tcp_md5_do_lookup_exact'
 was not declared. Should it be static?
Date: Thu, 6 Jul 2017 07:58:53 +0800
Message-ID: <201707060719.Zvm7chOj%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org,
        Bob Gilligan <gilligan@arista.com>,
        Eric Mowat <mowat@arista.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Ivan Delalande <colona@arista.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   b4b8cbf679c4866a523a35d1454884a31bd5d8dc
commit: 6797318e623da68dfbacd0cb5c246f5ecd2baf6e tcp: md5: add an address prefix for key lookup
date:   2 weeks ago
reproduce:
        # apt-get install sparse
        git checkout 6797318e623da68dfbacd0cb5c246f5ecd2baf6e
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> net/ipv4/tcp_ipv4.c:950:23: sparse: symbol 'tcp_md5_do_lookup_exact' was not declared. Should it be static?
   net/ipv4/tcp_ipv4.c:1614:17: sparse: context imbalance in 'tcp_add_backlog' - unexpected unlock
   net/ipv4/tcp_ipv4.c:1799:21: sparse: context imbalance in 'tcp_v4_rcv' - different lock contexts for basic block
   net/ipv4/tcp_ipv4.c:1985:20: sparse: context imbalance in 'listening_get_next' - unexpected unlock
   net/ipv4/tcp_ipv4.c:2045:9: sparse: context imbalance in 'established_get_first' - wrong count at exit
   net/ipv4/tcp_ipv4.c:2065:40: sparse: context imbalance in 'established_get_next' - unexpected unlock
   net/ipv4/tcp_ipv4.c:2193:36: sparse: context imbalance in 'tcp_seq_stop' - unexpected unlock

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
