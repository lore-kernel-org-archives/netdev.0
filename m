From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 11:39:55 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC32904700F27@orsmsx414.amr.corp.intel.com>
References: <20080131124632.GA25299@basil.nowhere.org> <20080131092327.75b9c369@extreme> <20080131183322.GA4671@one.firstfloor.org> <47A20CDC.5090104@trash.net> <20080131183735.GC4671@one.firstfloor.org> <20080131100846.00934e25@extreme> <20080131185328.GD4671@one.firstfloor.org> <47A211A0.1040502@trash.net> <20080131190125.GE4671@one.firstfloor.org> <D5C1322C3E673F459512FB59E0DDC32904700E40@orsmsx414.amr.corp.intel.com> <20080131193406.GH4671@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Patrick McHardy" <kaber@trash.net>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	<netdev@vger.kernel.org>
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10449 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753241AbYAaTj7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 14:39:59 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080131193406.GH4671@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The philosophical problem I have with this suggestion is that 
> I expect that the large majority of users will be more happy 
> with disabled TSO if they use non standard qdiscs and 
> defaults that do not fit the majority use case are bad.
> 
> Basically you're suggesting that nearly everyone using tc 
> should learn about another obscure command.

If someone is using tc to load and configure a qdisc, I'd really hope
knowing or learning ethtool wouldn't be a stretch for them...  And I'm
not arguing the majority of people will want this or not, but taking
away the ability to use TSO at the kernel level here without allowing a
tuneable is making that decision for them, which is wrong IMO.

Cheers,

-PJ Waskiewicz
<peter.p.waskiewicz.jr@intel.com>
