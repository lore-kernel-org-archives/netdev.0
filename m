From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv6: remove useless spin_lock/spin_unlock
Date: Tue, 09 Dec 2014 13:18:43 -0500 (EST)
Message-ID: <20141209.131843.1036852937243395534.davem@davemloft.net>
References: <547E6832.4070403@cn.fujitsu.com>
	<547E7594.7010301@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37154 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005AbaLISSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 13:18:46 -0500
In-Reply-To: <547E7594.7010301@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Wed, 3 Dec 2014 10:29:40 +0800

> xchg is atomic, so there is no necessary to use spin_lock/spin_unlock
> to protect it. At last, remove the redundant
> opt = xchg(&inet6_sk(sk)->opt, opt); statement.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> ---
> v2: remove the redundant opt = xchg(&inet6_sk(sk)->opt, opt); statement.

Applied, thank you.
