From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 20:34:06 +0100
Message-ID: <20080131193406.GH4671@one.firstfloor.org>
References: <20080131124632.GA25299@basil.nowhere.org> <20080131092327.75b9c369@extreme> <20080131183322.GA4671@one.firstfloor.org> <47A20CDC.5090104@trash.net> <20080131183735.GC4671@one.firstfloor.org> <20080131100846.00934e25@extreme> <20080131185328.GD4671@one.firstfloor.org> <47A211A0.1040502@trash.net> <20080131190125.GE4671@one.firstfloor.org> <D5C1322C3E673F459512FB59E0DDC32904700E40@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:40854 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897AbYAaS7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:59:40 -0500
Content-Disposition: inline
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32904700E40@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> TSO by nature is bursty.  But disabling TSO without the option of having
> it on or off to me seems to aggressive.  If someone is using a qdisc
> that TSO is interfering with the effectiveness of the traffic shaping,
> then they should turn off TSO via ethtool on the target device.  Some

The philosophical problem I have with this suggestion is that I expect
that the large majority of users will be more happy with disabled TSO
if they use non standard qdiscs and defaults that do not fit 
the majority use case are bad.

Basically you're suggesting that nearly everyone using tc should learn about
another obscure command.

-Andi
