From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next-2.6 PATCH 4/5] ixgbe: Add Flow Director configuration
 support as a mod parameter
Date: Fri, 8 Jan 2010 00:36:30 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.1001080036070.15300@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20100107044928.28605.62132.stgit@localhost.localdomain>
 <20100108.002449.190520102.davem@davemloft.net>
 <Pine.WNT.4.64.1001080027500.15300@ppwaskie-MOBL2.amr.corp.intel.com>
 <20100108.003244.67199934.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"deri@ntop.org" <deri@ntop.org>,
	"Gasparakis, Joseph" <joseph.gasparakis@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58496 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750982Ab0AHIgc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2010 03:36:32 -0500
In-Reply-To: <20100108.003244.67199934.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 8 Jan 2010, David Miller wrote:

> From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
> Date: Fri, 8 Jan 2010 00:28:17 -0800 (Pacific Standard Time)
> 
> > On Fri, 8 Jan 2010, David Miller wrote:
> > 
> >> Use a generic ethtool boolean flag or similar, not "yet another
> >> different-in-every-driver" module parameter please.
> > 
> > Something added to the setflags routine perhaps?
> 
> Yeah, something via 'struct ethtool_flags' is probably appropriate.

Cool.  I'll respin and get rid of the module parameter.

Thanks for the review,

-PJ
