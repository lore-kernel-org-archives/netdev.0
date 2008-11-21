From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [NET-NEXT v4 PATCH 1/5] ixgbe: this patch adds support for DCB to the	kernel and ixgbe driver
Date: Fri, 21 Nov 2008 09:58:37 -0800
Message-ID: <adaabbtgdv6.fsf@cisco.com>
References: <20081121020055.22180.24154.stgit@gitlost.lost>
	<4926B26C.7010200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jeff@garzik.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:65455 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752955AbYKUR6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 12:58:42 -0500
In-Reply-To: <4926B26C.7010200@trash.net> (Patrick McHardy's message of "Fri,
	21 Nov 2008 14:06:52 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > > --- /dev/null
 > > +++ b/net/dcb/Kconfig
 > > @@ -0,0 +1,12 @@
 > > +config DCB
 > > +        tristate "Data Center Bridging support"

 > A help text would be nice to have.

Yes, agreed -- something giving a hint about what DCB is (per-priority
pause, BCN) and guidance for the user that this should be enabled if
using DCB-capable NICs and switches.

 > > +
 > > +config DCBNL
 > > +	bool "Data Center Bridging netlink interface support"
 > > +	depends on DCB
 > > +	default n
 > > +	---help---
 > > +	  This option turns on the netlink interface
 > > +	  (dcbnl) for Data Center Bridging capable devices.
 > > +
 > > +	  If unsure, say N.

Now that I look at this config, it looks rather strange.  When does is
ever make sense to enable DCB but not DCBNL?  How else does one
configure all the DCB parameters except by running dcbd in userspace?
Should there even be a separate DCBNL option at all?

 - R.
