From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [net-next:master 37/84] drivers/net/ethernet/cadence/macb.h:563:2:
 error: implicit declaration of function '__raw_readl'
Date: Sat, 27 Oct 2012 10:44:17 +0800
Message-ID: <20121027024417.GA10393@localhost>
References: <508b2da7.GOPJdv0OiXMlnVxU%yuanhan.liu@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joachim Eastwood <manabian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2336 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758292Ab2J0CoT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2012 22:44:19 -0400
Content-Disposition: inline
In-Reply-To: <508b2da7.GOPJdv0OiXMlnVxU%yuanhan.liu@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joachim,

FYI, kernel build failed on

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   f019948dbb388eacbc0fb61db1d30e686224df77
commit: 84222e20c1823b5fd3216be46689693bd913bd0b [37/84] net/cadence: get rid of HAVE_NET_MACB
config: s390-allmodconfig # make ARCH=s390 allmodconfig

All error/warnings:

In file included from drivers/net/ethernet/cadence/macb.c:30:0:
drivers/net/ethernet/cadence/macb.h: In function 'macb_is_gem':
drivers/net/ethernet/cadence/macb.h:563:2: error: implicit declaration of function '__raw_readl' [-Werror=implicit-function-declaration]
drivers/net/ethernet/cadence/macb.c: In function '__macb_set_hwaddr':
drivers/net/ethernet/cadence/macb.c:65:2: error: implicit declaration of function '__raw_writel' [-Werror=implicit-function-declaration]
drivers/net/ethernet/cadence/macb.c: In function 'macb_probe':
drivers/net/ethernet/cadence/macb.c:1350:2: error: implicit declaration of function 'ioremap' [-Werror=implicit-function-declaration]
drivers/net/ethernet/cadence/macb.c:1350:11: warning: assignment makes pointer from integer without a cast [enabled by default]
drivers/net/ethernet/cadence/macb.c:1436:2: error: implicit declaration of function 'iounmap' [-Werror=implicit-function-declaration]
cc1: some warnings being treated as errors

vim +563 drivers/net/ethernet/cadence/macb.h

f75ba50b drivers/net/ethernet/cadence/macb.h Jamie Iles         2011-11-08  561  static inline bool macb_is_gem(struct macb *bp)
f75ba50b drivers/net/ethernet/cadence/macb.h Jamie Iles         2011-11-08  562  {
f75ba50b drivers/net/ethernet/cadence/macb.h Jamie Iles         2011-11-08 @563  	return MACB_BFEXT(IDNUM, macb_readl(bp, MID)) == 0x2;
f75ba50b drivers/net/ethernet/cadence/macb.h Jamie Iles         2011-11-08  564  }


---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
