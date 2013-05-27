From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ARM: kirkwood: proper retain MAC address
 workaround on DT ethernet
Date: Mon, 27 May 2013 15:17:44 -0700 (PDT)
Message-ID: <20130527.151744.1526437556583356156.davem@davemloft.net>
References: <1369655404.3557.33.camel@pasglop>
	<2255648.0KEmXfjCx5@wuerfel>
	<1369691406.3557.35.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, linuxppc-dev@lists.ozlabs.org,
	sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
	jason@lakedaemon.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, buytenh@wantstofly.org,
	grant.likely@linaro.org, linux-arm-kernel@lists.infradead.org
To: benh@kernel.crashing.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369691406.3557.35.camel@pasglop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 28 May 2013 07:50:06 +1000

> On Mon, 2013-05-27 at 14:47 +0200, Arnd Bergmann wrote:
>> On Monday 27 May 2013 21:50:04 Benjamin Herrenschmidt wrote:
>> > However, that wouldn't help much with the allocation/leak problem,
>> > though at least it would be easier to use. It could also *try* to re-use
>> > the current allocation if the new content is of smaller or equal size.
>> 
>> I thought that dtc tried to aggressively save space by folding identical
>> strings. If you tried to reuse a property that had its contents shared
>> with another one, you would get interesting results I guess.
> 
> It used to be only property names, unless that has changed in recent
> dtc. But that's a good point, we probably want a flag in struct property
> like we have for nodes, indicating whether it comes from the original
> fdt data pool or not.

This is similar to what the "OF_IS_DYNAMIC()" thing on sparc
indicates.
