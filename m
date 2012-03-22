From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] ipv6: Fix problem with expired dst cache
Date: Wed, 21 Mar 2012 22:47:37 -0400 (EDT)
Message-ID: <20120321.224737.2210116778476735927.davem@davemloft.net>
References: <1330931762-1466-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20120316.223353.988595838790067214.davem@davemloft.net>
	<4F6682AF.6020307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48951 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753142Ab2CVCrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 22:47:46 -0400
In-Reply-To: <4F6682AF.6020307@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Mon, 19 Mar 2012 08:49:51 +0800

> BUT what confuse me is that, in func ip6_rt_copy should we do
> rt6_set_from in any case or only when the ort has flag RTF_ADDRCONF
> and RTF_DEFAULT?

Your guess is as good as mine, unfortunately.  A lot of code in
this area is hard to decipher.

For example, I've spent the past several months trying to figure out
which kinds of ipv6 routes have explicit neighbour entries attached at
route insert time, which do not, etc.
