From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 2/6] arcnet: com20020: add enable and disable
 device on open/close
Date: Thu, 22 Oct 2015 01:18:53 +0800
Message-ID: <201510220121.IavQe5iv%fengguang.wu@intel.com>
References: <1445442332-10625-3-git-send-email-m.grzeschik@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, davem@davemloft.net, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: Michael Grzeschik <m.grzeschik@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:9896 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751236AbbJURQB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2015 13:16:01 -0400
Content-Disposition: inline
In-Reply-To: <1445442332-10625-3-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael,

[auto build test WARNING on net-next/master -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Michael-Grzeschik/arcnet-move-dev_free_skb-to-its-only-user/20151021-235034
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/net/arcnet/com20020.c:167:5: sparse: symbol 'com20020_netdev_open' was not declared. Should it be static?
>> drivers/net/arcnet/com20020.c:178:5: sparse: symbol 'com20020_netdev_close' was not declared. Should it be static?

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
