From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 630/633] net/bridge/br_netlink.c:1110:1:
 warning: the frame size of 2160 bytes is larger than 2048 bytes
Date: Mon, 05 Oct 2015 02:47:17 -0700 (PDT)
Message-ID: <20151005.024717.1982719584385972843.davem@davemloft.net>
References: <201510051053.L0S9UKIW%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@cumulusnetworks.com, kbuild-all@01.org,
	netdev@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752275AbbJEJbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 05:31:42 -0400
In-Reply-To: <201510051053.L0S9UKIW%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Mon, 5 Oct 2015 10:42:54 +0800

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   3e087caa23ef36370bfb925d3bbca78e8302d3ce
> commit: 7e4df51eb35deedd3ba8d4db92a6c36fb7eff90a [630/633] bridge: netlink: add support for igmp's intervals
> config: x86_64-randconfig-s0-10051005 (attached as .config)
> reproduce:
>         git checkout 7e4df51eb35deedd3ba8d4db92a6c36fb7eff90a
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All warnings (new ones prefixed by >>):
> 
>    net/bridge/br_netlink.c: In function 'br_fill_info':
>>> net/bridge/br_netlink.c:1110:1: warning: the frame size of 2160 bytes is larger than 2048 bytes [-Wframe-larger-than=]
>     }

Nikolay, please look into this.
