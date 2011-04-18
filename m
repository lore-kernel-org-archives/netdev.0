From: David Miller <davem@davemloft.net>
Subject: Re: Driver build-testing
Date: Mon, 18 Apr 2011 14:23:21 -0700 (PDT)
Message-ID: <20110418.142321.241429379.davem@davemloft.net>
References: <20110418122522.GC9462@sirena.org.uk>
	<20110418145102.GA2555@rere.qmqm.pl>
	<20110418160732.GE9462@sirena.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org
To: broonie@opensource.wolfsonmicro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46029
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751621Ab1DRVXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 17:23:55 -0400
In-Reply-To: <20110418160732.GE9462@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Date: Mon, 18 Apr 2011 17:07:33 +0100

> On Mon, Apr 18, 2011 at 04:51:02PM +0200, Micha? Miros?aw wrote:
> 
>> I wonder if allyesconfig/allmodconfig is supposed to include code that's
>> known not to work for a particular architecture.
> 
> Well, it's certainly supposed to include things that aren't *useful*
> which is more the point here.  all*config is clearly building a
> configuration which isn't terribly useful for any particular machine.

Right.

To be honest, any driver submitted now which has CONFIG_ARCH
dependencies is totally crap and we shouldn't merge.

We have portable interfaces for every aspect of operation that a
driver might need to use, and for where that isn't the case we should
fix that.

Even architecture specific hypervisor interfaces should have NOP
versions defined when building on other systems.

Frankly, every single driver under drivers/ should be available to
build on any platform, and it should build cleanly.

So the drivers that aren't available to build on all platforms right
now are just bugs waiting to be fixed :)
