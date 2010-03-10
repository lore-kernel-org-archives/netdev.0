From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Wed, 10 Mar 2010 08:35:47 -0800 (PST)
Message-ID: <20100310.083547.213194954.davem@davemloft.net>
References: <20100310131317.GA6267@linux.vnet.ibm.com>
	<20100310140729.GA25704@gondor.apana.org.au>
	<20100310162658.GI6267@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, eric.dumazet@gmail.com, arnd@arndb.de,
	netdev@vger.kernel.org, shemminger@vyatta.com
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35826
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756284Ab0CJQf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 11:35:29 -0500
In-Reply-To: <20100310162658.GI6267@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Wed, 10 Mar 2010 08:26:58 -0800

> On Wed, Mar 10, 2010 at 10:07:29PM +0800, Herbert Xu wrote:
>> On Wed, Mar 10, 2010 at 05:13:18AM -0800, Paul E. McKenney wrote:
>> >
>> > If CONFIG_PROVE_RCU is set, rcu_dereference() checks for rcu_read_lock()
>> > and rcu_dereference_bh() checks for either rcu_read_lock_bh() or BH
>> > being disabled.  Yes, this is a bit restrictive, but there are a few too
>> > many to check by hand these days.
>> 
>> Fair enough.  We should get those fixed then.  In fact I reckon
>> most of them should be using the BH variant so we might be able
>> to kill a few rcu_read_lock's which would be a real gain.
> 
> I have -tip commit a898def29e4119bc01ebe7ca97423181f4c0ea2d that
> converts some of the rcu_dereference()s in net/core/filter.c,
> net/core/dev.c, net/decnet/dn_route.c, net/packet/af_packet.c, and
> net/ipv4/route.c to rcu_dereference_bh().
> 
> How should we coordinate the removal of the rcu_read_lock() calls?

Paul if you want to do this via your tree, feel free.
