From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next-2.6 PATCH 4/5] ixgbe: Add Flow Director configuration
 support as a mod parameter
Date: Fri, 8 Jan 2010 00:28:17 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.1001080027500.15300@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20100107044741.28605.31414.stgit@localhost.localdomain>
 <20100107044928.28605.62132.stgit@localhost.localdomain>
 <20100108.002449.190520102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"deri@ntop.org" <deri@ntop.org>,
	"Gasparakis, Joseph" <joseph.gasparakis@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2964 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751445Ab0AHI2V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2010 03:28:21 -0500
In-Reply-To: <20100108.002449.190520102.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 8 Jan 2010, David Miller wrote:

> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Wed, 06 Jan 2010 20:49:29 -0800
> 
> > From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> > 
> > This patch adds the ability to change the Flow Director behavior in
> > ixgbe through a module parameter.  ixgbe, on 82599 hardware, can support
> > hash-based or perfect-based filtering.  It currently uses hash-based, and
> > should have a knob to enable perfect-based filtering.
> > 
> > This will be used in conjunction with the ethtool n-tuple filter
> > programming support.
> > 
> > Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Use a generic ethtool boolean flag or similar, not "yet another
> different-in-every-driver" module parameter please.

Something added to the setflags routine perhaps?

-PJ
