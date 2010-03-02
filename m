From: David Miller <davem@davemloft.net>
Subject: Re: sparse checking prevented by "net: fix kmemcheck annotations"
Date: Mon, 01 Mar 2010 18:39:55 -0800 (PST)
Message-ID: <20100301.183955.258219526.davem@davemloft.net>
References: <4B8BAE79.9000609@s5r6.in-berlin.de>
	<1267448966.3039.22.camel@edumazet-laptop>
	<4B8BE8BE.9070505@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: stefanr@s5r6.in-berlin.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B8BE8BE.9070505@s5r6.in-berlin.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Date: Mon, 01 Mar 2010 17:18:06 +0100

> Eric Dumazet wrote:
>> [PATCH] net: fix protocol sk_buff field
>> 
>> Commit e992cd9b72a18 (kmemcheck: make bitfield annotations truly no-ops
>> when disabled) allows us to revert a workaround we did in the past to
>> not add holes in sk_buff structure.
>> 
>> This patch partially reverts commit 14d18a81b5171
>> (net: fix kmemcheck annotations) so that sparse doesnt complain:
>> 
>> include/linux/skbuff.h:357:41: error: invalid bitfield specifier for
>> type restricted __be16.
> 
> Great, very appreciated.

Applied, thanks everyone.
