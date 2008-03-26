From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH 1/2 net-2.6.26] [NETNS]: Compilation fix for
	include/linux/netdevice.h.
Date: Wed, 26 Mar 2008 10:52:12 +0300
Message-ID: <1206517932.20894.5.camel@iris.sw.ru>
References: <1206517259-29152-1-git-send-email-den@openvz.org>
	 <20080326.004742.92048899.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, xemul@openvz.org,
	yoshfuji@linux-ipv6.org, dlezcano@fr.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:3998 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752274AbYCZHwH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 03:52:07 -0400
In-Reply-To: <20080326.004742.92048899.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-03-26 at 00:47 -0700, David Miller wrote:
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

We are in trouble for this right now :( there we do not work with SYSFS
enabled right now.

