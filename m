From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dns_resolver: convert time_t to time64_t
Date: Wed, 18 Nov 2015 16:30:15 -0500 (EST)
Message-ID: <20151118.163015.168193621097563379.davem@davemloft.net>
References: <20151118063643.GA16239@waves>
	<20151118.152025.1846834961092956563.davem@davemloft.net>
	<4702816.H75zDcB06x@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mahfouz.saif.elyazal@gmail.com, dhowells@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4702816.H75zDcB06x@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 18 Nov 2015 22:08:54 +0100

> On Wednesday 18 November 2015 15:20:25 David Miller wrote:
>> From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
>> Date: Wed, 18 Nov 2015 08:36:44 +0200
>> 
>> > Changes the definition of the pointer _expiry from time_t to
>> > time64_t. This is to handle the Y2038 problem where time_t
>> > will overflow in the year 2038. The change is safe because
>> > the kernel subsystems that call dns_query pass NULL.
>> > 
>> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> > Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
>> > ---
>> > Changelog:
>> > v1: The changes were originally made by Arnd Bergmann in
>> > relation to time_t. I've broken down a patch sent to me
>> > into two independent patches.
>> 
>> Want me to apply this to 'net'?
> 
> Yes, I think that would be good. The original patch was touching
> both the key and net subsystems, but this patch makes sense by itself
> now, and it helps keep the other half isolated to the key code.

OK, it sounds like we can simply delete the argument if nobody in-tree
uses it.

But whatever... applied thanks.
