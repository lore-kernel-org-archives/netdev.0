From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] snmp: 64bit ipstats_mib for all arches
Date: Wed, 30 Jun 2010 13:30:34 -0700 (PDT)
Message-ID: <20100630.133034.139124730.davem@davemloft.net>
References: <1277398051.2816.644.camel@edumazet-laptop>
	<1277819286.3531.555.camel@edumazet-laptop>
	<4C2A0C22.4010202@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44770
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755219Ab0F3UaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 16:30:20 -0400
In-Reply-To: <4C2A0C22.4010202@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Wed, 30 Jun 2010 00:07:14 +0900

> Hello.
> 
> Thank you for doing this work!
> 
> Eric Dumazet wrote:
>> /proc/net/snmp and /proc/net/netstat expose SNMP counters.
>> Width of these counters is either 32 or 64 bits, depending on the size
>> of "unsigned long" in kernel.
>> This means user program parsing these files must already be prepared
>> to
>> deal with 64bit values, regardless of user program being 32 or 64 bit.
> 
> Well, I'm rather not in favor of breaking user-space apps.

Eric has explained that applications must already be able to cope with
64-bit values here.  I think this is a valid change to make and
telling users that non-broken (read as: 64-bit) stats are only
available via netlink is not a reasonable thing at all.

I'm going to apply Eric's patch.
