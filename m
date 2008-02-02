From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Sat, 2 Feb 2008 06:20:08 +0100
Message-ID: <20080202052008.GA26132@one.firstfloor.org>
References: <47A211A0.1040502@trash.net> <20080131190125.GE4671@one.firstfloor.org> <D5C1322C3E673F459512FB59E0DDC32904700E40@orsmsx414.amr.corp.intel.com> <20080131193406.GH4671@one.firstfloor.org> <1201847738.17656.5.camel@roma.44ansell.gdt.id.au> <20080201074600.GA12644@one.firstfloor.org> <47A2C985.30409@trash.net> <D5C1322C3E673F459512FB59E0DDC32904737A42@orsmsx414.amr.corp.intel.com> <47A2ECE9.5000103@trash.net> <1201867609.4465.50.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Andi Kleen <andi@firstfloor.org>, Glen Turner <gdt@gdt.id.au>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:40225 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755665AbYBBEpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 23:45:35 -0500
Content-Disposition: inline
In-Reply-To: <1201867609.4465.50.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Turning TSO off at netdev registration time with a warning will be a
> cleaner IMO. Or alternatively introducing a kernel-config "I know what

You mean the qdisc should force TSO off on the underlying device? 

> TSO is" option which is then used at netdev registration. From a
> usability perspective it would make more sense to just keep ethtool as
> the only way to configure TSO. 

Ok, reasonable point.

-Andi
