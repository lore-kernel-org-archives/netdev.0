From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ipv6: remove unnecessary codes in
 tcp_ipv6.c
Date: Thu, 05 Jul 2012 03:13:33 -0700 (PDT)
Message-ID: <20120705.031333.1076060553032699410.davem@davemloft.net>
References: <1341199140-17135-1-git-send-email-roy.qing.li@gmail.com>
	<1341220067.5269.37.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55088 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752950Ab2GEKNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 06:13:33 -0400
In-Reply-To: <1341220067.5269.37.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Jul 2012 11:07:47 +0200

> On Mon, 2012-07-02 at 11:18 +0800, roy.qing.li@gmail.com wrote:
>> From: RongQing.Li <roy.qing.li@gmail.com>
>> 
>> opt always equals np->opts, so it is meaningless to define opt, and
>> check if opt does not equal np->opts and then try to free opt.
>> 
>> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
>> ---
>>  net/ipv6/tcp_ipv6.c |   16 +++-------------
>>  1 files changed, 3 insertions(+), 13 deletions(-)
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Ok I now understand better why these changes are correct,
applied.
