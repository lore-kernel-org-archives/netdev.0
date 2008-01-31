From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 21:10:45 -0200
Message-ID: <20080131231045.GA5543@ghostprotocols.net>
References: <20080131183322.GA4671@one.firstfloor.org> <47A20CDC.5090104@trash.net> <20080131183735.GC4671@one.firstfloor.org> <20080131100846.00934e25@extreme> <20080131185328.GD4671@one.firstfloor.org> <47A211A0.1040502@trash.net> <20080131190125.GE4671@one.firstfloor.org> <D5C1322C3E673F459512FB59E0DDC32904700E40@orsmsx414.amr.corp.intel.com> <20080131193406.GH4671@one.firstfloor.org> <D5C1322C3E673F459512FB59E0DDC32904700F27@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55018 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752434AbYAaXLB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 18:11:01 -0500
Content-Disposition: inline
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32904700F27@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Jan 31, 2008 at 11:39:55AM -0800, Waskiewicz Jr, Peter P escreveu:
> > The philosophical problem I have with this suggestion is that 
> > I expect that the large majority of users will be more happy 
> > with disabled TSO if they use non standard qdiscs and 
> > defaults that do not fit the majority use case are bad.
> > 
> > Basically you're suggesting that nearly everyone using tc 
> > should learn about another obscure command.
> 
> If someone is using tc to load and configure a qdisc, I'd really hope
> knowing or learning ethtool wouldn't be a stretch for them...  And I'm
> not arguing the majority of people will want this or not, but taking
> away the ability to use TSO at the kernel level here without allowing a
> tuneable is making that decision for them, which is wrong IMO.

Well, it could be just that when using such qdiscs TSO would be
disabled, but the user could override this by using ethtool after
loading the qdiscs.

- Arnaldo
