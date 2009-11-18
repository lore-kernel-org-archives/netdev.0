From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next-2.6 PATCH 1/2] ethtool: Add PHY type to ethtool
 get_drvinfo
Date: Tue, 17 Nov 2009 16:47:16 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.0911171646450.14640@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20091117161309.11341.9165.stgit@localhost.localdomain>
 <20091117090719.7d83492a@nehalam> <Pine.WNT.4.64.0911171156090.15476@ppwaskie-MOBL2.amr.corp.intel.com>
 <20091117164104.5da05b81@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:33283 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752373AbZKRArJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2009 19:47:09 -0500
In-Reply-To: <20091117164104.5da05b81@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Nov 2009, Stephen Hemminger wrote:

> On Tue, 17 Nov 2009 11:56:57 -0800 (Pacific Standard Time)
> "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com> wrote:
> 
> > On Tue, 17 Nov 2009, Stephen Hemminger wrote:
> > 
> > > On Tue, 17 Nov 2009 08:13:24 -0800
> > > Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> > > 
> > > > From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> > > > 
> > > > Allow the PHY type to be passed from a driver to ethtool when
> > > > ethtool -i ethX is called.  With newer network cards having SFP
> > > > and SFP+ PHY cages, this information can be useful, especially
> > > > if the NIC supports hot-swapping of the PHY modules.
> > > > 
> > > > Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> > > > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > > > ---
> > > 
> > > Maybe revive usage of connector port in ethtool rather than adding new API?
> > > It is already there but values are out of date with current hardware.
> > 
> > You're referring to the MODE_GSET port settings?  If so, I like this 
> > approach, and will update my patches accordingly.
> 
> Yes. cmd->port is always PORT_TP or PORT_FIBRE now but could be extended
> Likewise cmd->transceiver could be modified.  I haven't seen an external transceiver
> since the old fat yellow cable with vampire taps (and that was 20 yrs ago).

I have patches that I sent to Jeff for internal testing that fixes up the 
cmd->port field (per your and Ben's suggestion).  I like it much better 
too.  :-)

-PJ
