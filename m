From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 11/72] cassini/niu/sun*: Move the Sun drivers
Date: Sat, 25 Jun 2011 16:56:39 -0700 (PDT)
Message-ID: <20110625.165639.1842566865962804457.davem@davemloft.net>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1309010363-22750-12-git-send-email-jeffrey.t.kirsher@intel.com>
	<4E05F4D3.9020407@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	sammy@sammy.net, asun@darksunrising.com, benh@kernel.crashing.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59949 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447Ab1FYX7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 19:59:51 -0400
In-Reply-To: <4E05F4D3.9020407@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Sat, 25 Jun 2011 16:46:43 +0200

> On 25.06.2011 15:58, Jeff Kirsher wrote:
>> Moves the Sun drivers into drivers/net/ethernet/sun/ and make
>> the necessary Kconfig and Makefile changes.
>> 
> 
> (..)
> 
>> ---
>>  MAINTAINERS                                 |    1 +
>>  drivers/net/Kconfig                         |   75 ----------------------
>>  drivers/net/Makefile                        |   11 +---
>>  drivers/net/ethernet/Kconfig                |    1 +
>>  drivers/net/ethernet/Makefile               |    1 +
>>  drivers/net/ethernet/sun/Kconfig            |   91 +++++++++++++++++++++++++++
>>  drivers/net/ethernet/sun/Makefile           |   12 ++++
>>  drivers/net/{ => ethernet/sun}/cassini.c    |    0
>>  drivers/net/{ => ethernet/sun}/cassini.h    |    0
>>  drivers/net/{ => ethernet/sun}/niu.c        |    0
>>  drivers/net/{ => ethernet/sun}/niu.h        |    0
>>  drivers/net/{ => ethernet/sun}/sun3_82586.c |    0
>>  drivers/net/{ => ethernet/sun}/sun3_82586.h |    0
> 
> s/sun3_// in filenames?

It's a special instance of the chip which only ever
appears on the motherboard of m68k based sun3 systems.

The sun3 prefix is absolutely appropriate.
