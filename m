From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2 0/3] net: forbid net devices named "all"
 "default" or "config"
Date: Tue, 29 Jul 2014 11:44:14 -0700 (PDT)
Message-ID: <20140729.114414.292663024559656037.davem@davemloft.net>
References: <1406327110-17227-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephane.chazelas@gmail.com,
	f.fainelli@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165AbaG2SoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 14:44:15 -0400
In-Reply-To: <1406327110-17227-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 25 Jul 2014 15:25:07 -0700

> /proc/sys/net/ipv[46]/conf/<dev> could conflict with
> /proc/sys/net/ipv[46]/conf/(all|default). And /proc/net/vlan/<dev>
> could conflict with /proc/net/vlan/config. Besides kernel warnings,
> undefined behavior such as duplicated proc files also appears, therefore
> we should forbid these names.
> 
> v2: introduce a helper function, suggested by Florian 
>     fix error handling for ipv6_add_dev() in addrconf_init()

Series applied, thank you.
