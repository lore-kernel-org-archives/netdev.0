From: David Miller <davem@davemloft.net>
Subject: Re: what's causing "ip_rt_bug"?
Date: Tue, 28 Jun 2011 01:41:17 -0700 (PDT)
Message-ID: <20110628.014117.92807428115239742.davem@davemloft.net>
References: <alpine.LFD.2.00.1106182036001.1425@ja.ssi.bg>
	<20110627.205544.111681152997205782.davem@davemloft.net>
	<alpine.LFD.2.00.1106281029490.1880@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mangoo@wpkg.org, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	bazsi@balabit.hu, hidden@balabit.hu
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34153 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755226Ab1F1Il1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 04:41:27 -0400
In-Reply-To: <alpine.LFD.2.00.1106281029490.1880@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Tue, 28 Jun 2011 11:13:25 +0300 (EEST)

> On Mon, 27 Jun 2011, David Miller wrote:
> 
>> TPROXY has special code to make sure that time-wait sockets
>> are not assigned to skb->sk, as explained in commit
>> d503b30bd648b3cb4e5f50b65d27e389960cc6d9, that would cause
>> all kinds of crashes in nfnetlink_log etc.
>> 
>> Therefore we would see skb->sk==NULL at ip_route_me_harder()
>> in that case.
> 
> 	Aha, after this clarification other changes should not
> be needed.

By this do you mean that you think your patch in this thread
is completely sufficient?
