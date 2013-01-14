From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix a panic on UP machines in
 reqsk_fastopen_remove
Date: Mon, 14 Jan 2013 18:10:30 -0500 (EST)
Message-ID: <20130114.181030.1911364060960863615.davem@davemloft.net>
References: <1358137311.8744.1590.camel@edumazet-glaptop>
	<CAPshTCiNcSPbC7uCzo5MV2tGuZyoCwyE_XKcGb9smknZ8Rqb2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, ketkulka@gmail.com,
	ycheng@google.com
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35480 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756919Ab3ANXKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 18:10:34 -0500
In-Reply-To: <CAPshTCiNcSPbC7uCzo5MV2tGuZyoCwyE_XKcGb9smknZ8Rqb2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>
Date: Mon, 14 Jan 2013 00:26:26 -0800

> On Sun, Jan 13, 2013 at 8:21 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> spin_is_locked() on a non !SMP build is kind of useless.
>>
>> BUG_ON(!spin_is_locked(xx)) is guaranteed to crash.
>>
>> Just remove this check in reqsk_fastopen_remove() as
>> the callers do hold the socket lock.
>>
>> Reported-by: Ketan Kulkarni <ketkulka@gmail.com>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
 ...
> Thanks, Eric. (I thought the assertion would be transparent to UP...)
> 
> Acked-by: H.K. Jerry Chu <hkchu@google.com>
> 

Applied, thanks.
