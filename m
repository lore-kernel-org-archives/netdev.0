From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 4720/12950] net/core/dst_cache.c:31:6: sparse:
 symbol 'dst_cache_per_cpu_dst_set' was not declared. Should it be static?
Date: Fri, 18 Mar 2016 23:27:28 +0800
Message-ID: <201603182348.v699gI0M%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   5e3497cca281616e7930b74a0076b7324dcc2057
commit: 607f725f6f7d5ec3759fbc16224afb60e2152a5b [4720/12950] net: replace dst_cache ip6_tunnel implementation with the generic one
reproduce:
        # apt-get install sparse
        git checkout 607f725f6f7d5ec3759fbc16224afb60e2152a5b
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> net/core/dst_cache.c:31:6: sparse: symbol 'dst_cache_per_cpu_dst_set' was not declared. Should it be static?
>> net/core/dst_cache.c:42:18: sparse: symbol 'dst_cache_per_cpu_get' was not declared. Should it be static?

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
