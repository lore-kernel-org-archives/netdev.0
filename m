From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] Disable TSO for non standard qdiscs
Date: Fri, 1 Feb 2008 11:02:23 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC32904737D65@orsmsx414.amr.corp.intel.com>
References: <20080131183322.GA4671@one.firstfloor.org> <47A20CDC.5090104@trash.net> <20080131183735.GC4671@one.firstfloor.org> <20080131100846.00934e25@extreme> <20080131185328.GD4671@one.firstfloor.org> <47A211A0.1040502@trash.net> <20080131190125.GE4671@one.firstfloor.org> <D5C1322C3E673F459512FB59E0DDC32904700E40@orsmsx414.amr.corp.intel.com> <20080131193406.GH4671@one.firstfloor.org> <1201847738.17656.5.camel@roma.44ansell.gdt.id.au> <20080201074600.GA12644@one.firstfloor.org> <47A2C985.30409@trash.net> <D5C1322C3E673F459512FB59E0DDC32904737A42@orsmsx414.amr.corp.intel.com> <47A2ECE9.5000103@trash.net> <1201867609.4465.50.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Andi Kleen" <andi@firstfloor.org>, "Glen Turner" <gdt@gdt.id.au>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	<netdev@vger.kernel.org>
To: <hadi@cyberus.ca>, "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61094 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753083AbYBATDr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 14:03:47 -0500
Content-class: urn:content-classes:message
In-Reply-To: <1201867609.4465.50.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Right - Essentially it is a usability issue:
> People who know how to use TSO (Peter for example) will be 
> clueful enough to turn it on. Which means the default should 
> be to protect the clueless and turn it off.
> On Andis approach:
> Turning TSO off at netdev registration time with a warning 
> will be a cleaner IMO. Or alternatively introducing a 
> kernel-config "I know what TSO is" option which is then used 
> at netdev registration. From a usability perspective it would 
> make more sense to just keep ethtool as the only way to 
> configure TSO. 

To me this sounds like the most reasonable approach.  I've put out my
concerns, so I'll get out of the way now so we can move forward in some
direction.  :-)

Cheers,

-PJ Waskiewicz
