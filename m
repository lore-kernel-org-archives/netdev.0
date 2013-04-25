From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 3/5] sock_diag: allow to dump bpf filters
Date: Thu, 25 Apr 2013 01:16:36 -0400 (EDT)
Message-ID: <20130425.011636.238533615622671655.davem@davemloft.net>
References: <1366818756-4234-1-git-send-email-nicolas.dichtel@6wind.com>
	<1366818756-4234-4-git-send-email-nicolas.dichtel@6wind.com>
	<1366820565.8964.78.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47947 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763Ab3DYFQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 01:16:38 -0400
In-Reply-To: <1366820565.8964.78.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 24 Apr 2013 09:22:45 -0700

> On Wed, 2013-04-24 at 17:52 +0200, Nicolas Dichtel wrote:
>> This patch allows to dump BPF filters attached to a socket with
>> SO_ATTACH_FILTER. In other words, users allowing to open netlink sockets can
>> see filters set on a socket (when the diag module of the socket family is
>> loaded).
> 
> To my knowledge, opening netlink sockets is not restricted.
> 
> I do not want user lambda being able to see my BPF filters.

I agree, this change is not reasonable.  And therefore the notifiers
added in the subsequent patches of this series are not appropriate
either.
