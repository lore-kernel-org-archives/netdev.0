From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] phylib: Support phy module autoloading
Date: Thu, 01 Apr 2010 19:38:10 -0700 (PDT)
Message-ID: <20100401.193810.172601735.davem@davemloft.net>
References: <1270096441.12516.18.camel@localhost>
	<1270141428.3101.399.camel@macbook.infradead.org>
	<20100401180511.GQ16821@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, netdev@vger.kernel.org, 553024@bugs.debian.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39369
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754916Ab0DBCiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 22:38:09 -0400
In-Reply-To: <20100401180511.GQ16821@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 1 Apr 2010 19:05:12 +0100

> On Thu, Apr 01, 2010 at 06:03:48PM +0100, David Woodhouse wrote:
>> On Thu, 2010-04-01 at 05:34 +0100, Ben Hutchings wrote:
> [...]
>> > Since you've dealt with (a), and (b) is not really as important, I would
>> > just like to suggest some minor changes to your patch 1 (see below).
>> > Feel free to fold them in.  Your patch 2 would then need the
>> > substitutions s/phy_device_id/mdio_device_id/; s/TABLE(phy/TABLE(mdio/.
>> 
>> I'll tolerate the silly __u32 crap if I must for consistency, but
>> normally I prefer to write in C.
>> 
>> I did think about 'mdio:' for the module alias, but I decided that
>> 'phy:' probably made more sense since these are PHY driver modules and
>> the number is the phy_id.
> [...]
> 
> Many multi-layered communication standards have distinct PHY devices,
> and they presumably have their own ID spaces.  phylib deals only with
> management of Ethernet PHYs over an MDIO bus, identified using MDIO
> ID registers.

Agreed, PHYs exist on so many different kinds of topologies, the ones
here are definitely specific to Ethernet and MDIO and therefore that
is probably the more useful basis for naming.

David can you freshen things up in this area and integrate whatever
you deem useful and immediate from Ben's patch?  Whatever you submit
next I'd like to toss into net-next-2.6 so it can cook for a while
and maybe we'll backport it so that this bug can be fixed for good
upstream and then perhaps even in -stable.

Thanks!
