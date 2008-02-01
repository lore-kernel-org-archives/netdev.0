From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Fri, 01 Feb 2008 08:25:57 +0100
Message-ID: <47A2C985.30409@trash.net>
References: <20080131183322.GA4671@one.firstfloor.org> <47A20CDC.5090104@trash.net> <20080131183735.GC4671@one.firstfloor.org> <20080131100846.00934e25@extreme> <20080131185328.GD4671@one.firstfloor.org> <47A211A0.1040502@trash.net> <20080131190125.GE4671@one.firstfloor.org> <D5C1322C3E673F459512FB59E0DDC32904700E40@orsmsx414.amr.corp.intel.com> <20080131193406.GH4671@one.firstfloor.org> <1201847738.17656.5.camel@roma.44ansell.gdt.id.au> <20080201074600.GA12644@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Glen Turner <gdt@gdt.id.au>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39248 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754685AbYBAH0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 02:26:03 -0500
In-Reply-To: <20080201074600.GA12644@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
>> The problem with ethtool is that it's a non-obvious nerd knob.  At
>> the least the ethtool documentation should be updated to indicate that 
>> activating TSO effects tc accuracy.
> 
> TSO tends to be activated by default in the driver; very few people who use it
> do even know that ethtool exist or what TSO is.


Indeed. As an example of an unknowing user, this discussion made me
check whether my cablemodem device (on which I'm using HFSC) uses
TSO :)

