From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/2 net-2.6.26] [NETNS]: Compilation fix for
 include/linux/netdevice.h.
Date: Wed, 26 Mar 2008 17:07:02 +0900 (JST)
Message-ID: <20080326.170702.24448643.yoshfuji@linux-ipv6.org>
References: <1206517259-29152-1-git-send-email-den@openvz.org>
	<20080326.004742.92048899.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, xemul@openvz.org, dlezcano@fr.ibm.com,
	yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55289 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753969AbYCZIFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 04:05:38 -0400
In-Reply-To: <20080326.004742.92048899.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080326.004742.92048899.davem@davemloft.net> (at Wed, 26 Mar 2008 00:47:42 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> From: "Denis V. Lunev" <den@openvz.org>
> Date: Wed, 26 Mar 2008 10:40:58 +0300
> 
> > Commit commit c346dca10840a874240c78efe3f39acf4312a1f2
> > ([NET] NETNS: Omit net_device->nd_net without CONFIG_NET_NS)
> > breaks compilation with CONFIG_NET_NS set.
> > 
> > Fix the typo.
> > 
> > Signed-off-by: Denis V. Lunev <den@openvz.org>
> 
> Applied.
> 
> Too bad allmodconfig doesn't enable things which are y/n only.

Sorry for the typo.

Unfortunately, NET_NS depends on !SYSFS,
so allyesconfig might not help...

--yoshfuji
