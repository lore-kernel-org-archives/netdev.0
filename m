From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 0/3] net: forbid net devices named "all"
 "default" or "config"
Date: Thu, 24 Jul 2014 23:32:54 -0700 (PDT)
Message-ID: <20140724.233254.1343189609913837881.davem@davemloft.net>
References: <1406153852-22511-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephane.chazelas@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58803 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044AbaGYGc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 02:32:56 -0400
In-Reply-To: <1406153852-22511-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 23 Jul 2014 15:17:29 -0700

> /proc/sys/net/ipv[46]/conf/<dev> could conflict with
> /proc/sys/net/ipv[46]/conf/(all|default). And /proc/net/vlan/<dev>
> could conflict with /proc/net/vlan/config. Besides kernel warnings,
> undefined behavior such as duplicated proc files also appears, therefore
> we should forbid these names.
> 
> Cong Wang (3):
>   ipv4: fail early when creating netdev named all or default
>   ipv6: fail early when creating netdev named all or default
>   vlan: fail early when creating netdev named config

As suggested, please make a common helper for ipv4/ipv6, the restrictions
are identical currently.
