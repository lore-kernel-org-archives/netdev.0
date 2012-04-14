From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] tcp: bind() use stronger condition for
 bind_conflict
Date: Sat, 14 Apr 2012 15:29:14 -0400 (EDT)
Message-ID: <20120414.152914.905196046418805495.davem@davemloft.net>
References: <1334305305-19952-1-git-send-email-alex.mihai.c@gmail.com>
	<1334307191.5300.8793.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.mihai.c@gmail.com, fbl@redhat.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, dbaluta@ixiacom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753859Ab2DNTcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2012 15:32:11 -0400
In-Reply-To: <1334307191.5300.8793.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 13 Apr 2012 10:53:11 +0200

> On Fri, 2012-04-13 at 11:21 +0300, Alexandru Copot wrote:
>> From: Alex Copot <alex.mihai.c@gmail.com>
>> 
>> We must try harder to get unique (addr, port) pairs when
>> doing port autoselection for sockets with SO_REUSEADDR
>> option set.
> 
> ...
> 
>>  			}
>> +			if (!relax && reuse && sk2->sk_reuse &&
>> +			   sk2->sk_state != TCP_LISTEN) {
>> +				const __be32 sk2_rcv_saddr = sk_rcv_saddr(sk2);
>> +
> 
> 
> Oh well, missing space here :(
> 
> I said :
> 
> if (condition_one ||
>     condition_two) {
> 
> not
> 
> if (condition_one ||
>    condition_two) {

I'll fix this up.

> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
