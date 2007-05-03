From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Thu, 3 May 2007 14:03:07 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902C70A5C@orsmsx414.amr.corp.intel.com>
References: <1178109829.4074.48.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Patrick McHardy" <kaber@trash.net>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	<netdev@vger.kernel.org>, <jgarzik@pobox.com>,
	"cramerj" <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	<davem@davemloft.net>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24198 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S637734AbXECVDK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 17:03:10 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1178109829.4074.48.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Lets come up with some terminology; lets call multiqueue what 
> the qdiscs do; lets call what the NICs do multi-ring.
> Note, i have thus far said you need to have both and they 
> must be in sync.

I agree with the terminology.

> This maybe _the_ main difference we have in opinion.
> Like i said earlier, I used to hold the same thoughts you do.
> And i think you should challenge my assertion that it doesnt 
> matter if you have a single entry point; [my assumptions are 
> back in what i called #b and #c].

Here is a paper that describes what exactly we're trying to do:
http://www.ieee802.org/3/ar/public/0503/wadekar_1_0503.pdf.  Basically
we need the ability to pause a queue independantly of another queue.
Because of this requirement, the kernel needs visibility into the driver
and to have knowledge of and provide control of each queue.  Please note
that the API I'm proposing is a generic representation of the Datacenter
Ethernet mentioned in the paper; I figured if we're putting in an
interface to support it, it should be generic so other technologies out
there could easily use it.

Hopefully that paper can help people understand the motivation why I've
done things the way they are in the patches.  Given this information,
I'd really like to solicit feedback on the patches as they stand (both
approach and implementation).

Cheers,

-PJ Waskiewicz
