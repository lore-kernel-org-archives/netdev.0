From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 RESEND 2/3] neigh: only allow init_net to change the
 default neigh_parms
Date: Wed, 19 Jun 2013 21:13:47 -0700 (PDT)
Message-ID: <20130619.211347.1643221165823238693.davem@davemloft.net>
References: <1371693694-18531-1-git-send-email-gaofeng@cn.fujitsu.com>
	<1371693694-18531-2-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48555 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711Ab3FTENr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 00:13:47 -0400
In-Reply-To: <1371693694-18531-2-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Thu, 20 Jun 2013 10:01:33 +0800

> Though we don't export the /proc/sys/net/ipv[4,6]/neigh/default/
> directory to the un-init_net, but we can still use cmd such as
> "ip ntable change name arp_cache locktime 129" to change the locktime
> of default neigh_parms.
> 
> This patch disallows the un-init_net to find out the neigh_table.parms.
> So the un-init_net will failed to influence the init_net.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Applied.
