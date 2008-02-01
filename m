From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Fri, 01 Feb 2008 07:46:41 +0100
Message-ID: <47A2C051.8050802@trash.net>
References: <20080131124632.GA25299@basil.nowhere.org>	 <20080131092327.75b9c369@extreme>	 <20080131183322.GA4671@one.firstfloor.org> <47A20CDC.5090104@trash.net>	 <20080131183735.GC4671@one.firstfloor.org>	 <20080131100846.00934e25@extreme>	 <20080131185328.GD4671@one.firstfloor.org> <47A211A0.1040502@trash.net>	 <20080131190125.GE4671@one.firstfloor.org>	 <D5C1322C3E673F459512FB59E0DDC32904700E40@orsmsx414.amr.corp.intel.com>	 <20080131193406.GH4671@one.firstfloor.org> <1201847738.17656.5.camel@roma.44ansell.gdt.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Glen Turner <gdt@gdt.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38496 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753035AbYBAGqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 01:46:52 -0500
In-Reply-To: <1201847738.17656.5.camel@roma.44ansell.gdt.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Glen Turner wrote:
> On Thu, 2008-01-31 at 20:34 +0100, Andi Kleen wrote:
> 
>> The philosophical problem I have with this suggestion is that I expect
>> that the large majority of users will be more happy with disabled TSO
>> if they use non standard qdiscs and defaults that do not fit 
>> the majority use case are bad.
> 
> I wouldn't be so fast to assume that all users need an exact playout
> rate, as people seem to do fine with the 8Kbps playout steps in Cisco
> IOS.  A nerd-knob which expresses user's preference in the
> accuracy/performance trade-off would be nice.
> 
> The problem with ethtool is that it's a non-obvious nerd knob.  At
> the least the ethtool documentation should be updated to indicate that 
> activating TSO effects tc accuracy.


I agree with Andi, most user neither know nor care about TSO.
It should work properly by default and optimizations should
be explicitly configured. This is especially true if you
consider the common userbase of qdiscs - which is mostly
slow DSL lines, cablemodems etc.
