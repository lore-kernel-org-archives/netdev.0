From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 276/294] net/switchdev/switchdev.c:190:5: sparse:
 symbol '__switchdev_port_obj_add' was not declared. Should it be static?
Date: Wed, 13 May 2015 07:44:30 +0800
Message-ID: <201505130704.czRDM6qD%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, Jiri Pirko <jiri@resnulli.us>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   a62b70ddd13993e3706acf3021bf2680461195f4
commit: 491d0f1533ac750260406dbf84cdad44fd3d8a29 [276/294] switchdev: introduce switchdev add/del obj ops
reproduce:
  # apt-get install sparse
  git checkout 491d0f1533ac750260406dbf84cdad44fd3d8a29
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> net/switchdev/switchdev.c:190:5: sparse: symbol '__switchdev_port_obj_add' was not declared. Should it be static?

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
