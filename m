From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net-2.6.26] [NETNS]: Compilation fix for
 include/linux/netdevice.h.
Date: Wed, 26 Mar 2008 00:47:42 -0700 (PDT)
Message-ID: <20080326.004742.92048899.davem@davemloft.net>
References: <1206517259-29152-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, xemul@openvz.org,
	yoshfuji@linux-ipv6.org, dlezcano@fr.ibm.com
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52096
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751938AbYCZHrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 03:47:46 -0400
In-Reply-To: <1206517259-29152-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Wed, 26 Mar 2008 10:40:58 +0300

> Commit commit c346dca10840a874240c78efe3f39acf4312a1f2
> ([NET] NETNS: Omit net_device->nd_net without CONFIG_NET_NS)
> breaks compilation with CONFIG_NET_NS set.
> 
> Fix the typo.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied.

Too bad allmodconfig doesn't enable things which are y/n only.
