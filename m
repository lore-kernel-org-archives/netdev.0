From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Fri, 1 Feb 2008 05:36:05 +0100
Message-ID: <20080201043605.GC10720@one.firstfloor.org>
References: <47A20CDC.5090104@trash.net> <20080131183735.GC4671@one.firstfloor.org> <20080131100846.00934e25@extreme> <20080131185328.GD4671@one.firstfloor.org> <47A211A0.1040502@trash.net> <20080131190125.GE4671@one.firstfloor.org> <D5C1322C3E673F459512FB59E0DDC32904700E40@orsmsx414.amr.corp.intel.com> <20080131193406.GH4671@one.firstfloor.org> <D5C1322C3E673F459512FB59E0DDC32904700F27@orsmsx414.amr.corp.intel.com> <20080131231045.GA5543@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Andi Kleen <andi@firstfloor.org>,
	Patrick McHardy <kaber@trash.net>,
	Stephen H
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:45367 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756658AbYBAEBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 23:01:37 -0500
Content-Disposition: inline
In-Reply-To: <20080131231045.GA5543@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Well, it could be just that when using such qdiscs TSO would be
> disabled, but the user could override this by using ethtool after
> loading the qdiscs.

If anything TC, not ethtool. Do you have an useful scenario where
GSO makes sense with TBF et.al.?

-Andi
