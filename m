From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for Aug 12 (benet/be2net)
Date: Fri, 12 Aug 2011 23:20:12 -0700 (PDT)
Message-ID: <20110812.232012.2290296405050164118.davem@davemloft.net>
References: <20110812135618.a209d9af.rdunlap@xenotime.net>
	<20110812150607.2303e10e@nehalam.ftrdhcpuser.net>
	<20110812151409.b8af0108.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com
To: rdunlap@xenotime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33490 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091Ab1HMGWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2011 02:22:18 -0400
In-Reply-To: <20110812151409.b8af0108.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@xenotime.net>
Date: Fri, 12 Aug 2011 15:14:09 -0700

> On Fri, 12 Aug 2011 15:06:07 -0700 Stephen Hemminger wrote:
> 
>> On Fri, 12 Aug 2011 13:56:18 -0700
>> Randy Dunlap <rdunlap@xenotime.net> wrote:
>> 
>> > On Fri, 12 Aug 2011 17:13:11 +1000 Stephen Rothwell wrote:
>> > 
>> > > Hi all,
>> > > 
>> > > [The kernel.org mirroring is being very slow today]
>> > 
>> >   [s.l.o.w.]
>> >  
>> > > The net tree gained a build failure do I used the version from
>> > > next-20110811.
>> > 
>> > 
>> > On i386:
>> > 
>> > drivers/built-in.o: In function `be_rx_eqd_update':
>> > be_main.c:(.text+0x569229): undefined reference to `__udivdi3'
>> > 
>> 
>> Already fixed:
> 
> That's really good news.  It appears to be re-b0rked
> or this patch is not in linux-next yet.

Stephen Rothwell dropped the net-next tree from -next yesterday due to
some other unrelated fallout.
