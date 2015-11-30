From: David Miller <davem@davemloft.net>
Subject: Re: Increasing skb->mark size
Date: Sun, 29 Nov 2015 20:58:54 -0500 (EST)
Message-ID: <20151129.205854.160622377475841200.davem@davemloft.net>
References: <1448397144.14854.27.camel@mattb-dl>
	<CAKD1Yr3URKzAooiNH7i4kHVR0-TQjEAkQEdqjarAm6uxH7u-Mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Matt.Bennett@alliedtelesis.co.nz, netdev@vger.kernel.org,
	Luuk.Paulussen@alliedtelesis.co.nz
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46224 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbbK3B66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 20:58:58 -0500
In-Reply-To: <CAKD1Yr3URKzAooiNH7i4kHVR0-TQjEAkQEdqjarAm6uxH7u-Mw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Sun, 29 Nov 2015 17:37:11 +0900

> On Wed, Nov 25, 2015 at 5:32 AM, Matt Bennett
> <Matt.Bennett@alliedtelesis.co.nz> wrote:
>> I'm emailing this list for feedback on the feasibility of increasing
>> skb->mark or adding a new field for marking. Perhaps this extension
>> could be done under a new CONFIG option.
> 
> 64-bit marks (both skb->mark and sk->sk_mark) would be useful for
> hosts doing complex policy routing as well. Current Android releases
> use 20 of the 32 bits. If the mark were 64 bits, we could put the UID
> in it, and stop using ip rules to implement per-UID routing.

If you guys, really anyone, can find a way to remove some other
32-bit item from sk_buff, you can expand skb->mark to 64-bits.

But otherwise, I'm going to be strongly against it.

sk_buff is already enormous and larger than it should be.  So
I'm going to resist any change that makes it even larger.

Thanks.
