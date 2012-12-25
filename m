From: David Miller <davem@davemloft.net>
Subject: Re: [Patch v2] arp: fix a regression in arp_solicit()
Date: Mon, 24 Dec 2012 18:43:26 -0800 (PST)
Message-ID: <20121224.184326.555443730875272088.davem@davemloft.net>
References: <1356312196-23185-1-git-send-email-xiyou.wangcong@gmail.com>
	<1356367274.20133.9176.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	sedat.dilek@gmail.com, edumazet@google.com, ja@ssi.bg
To: erdnetdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46700 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753385Ab2LYCn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2012 21:43:27 -0500
In-Reply-To: <1356367274.20133.9176.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <erdnetdev@gmail.com>
Date: Mon, 24 Dec 2012 08:41:14 -0800

> On Mon, 2012-12-24 at 09:23 +0800, Cong Wang wrote:
>> From: Cong Wang <xiyou.wangcong@gmail.com>
>> 
>> Sedat reported the following commit caused a regression:
>> 
>> commit 9650388b5c56578fdccc79c57a8c82fb92b8e7f1
>> Author: Eric Dumazet <edumazet@google.com>
>> Date:   Fri Dec 21 07:32:10 2012 +0000
>> 
>>     ipv4: arp: fix a lockdep splat in arp_solicit
>> 
>> This is due to the 6th parameter of arp_send() needs to be NULL
>> for the broadcast case, the above commit changed it to an all-zero
>> array by mistake.
>> 
>> Reported-by: Sedat Dilek <sedat.dilek@gmail.com>
>> Tested-by: Sedat Dilek <sedat.dilek@gmail.com>
>> Cc: Sedat Dilek <sedat.dilek@gmail.com>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: Julian Anastasov <ja@ssi.bg>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> 
>> ---
> 
> Oops, thanks for fixing this.
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
