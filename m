From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next-2.6 PATCH 1/2] ethtool: Add PHY type to ethtool
 get_drvinfo
Date: Tue, 17 Nov 2009 16:41:04 -0800
Message-ID: <20091117164104.5da05b81@nehalam>
References: <20091117161309.11341.9165.stgit@localhost.localdomain>
	<20091117090719.7d83492a@nehalam>
	<Pine.WNT.4.64.0911171156090.15476@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56501 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751891AbZKRAlJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2009 19:41:09 -0500
In-Reply-To: <Pine.WNT.4.64.0911171156090.15476@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Nov 2009 11:56:57 -0800 (Pacific Standard Time)
"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com> wrote:

> On Tue, 17 Nov 2009, Stephen Hemminger wrote:
> 
> > On Tue, 17 Nov 2009 08:13:24 -0800
> > Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> > 
> > > From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> > > 
> > > Allow the PHY type to be passed from a driver to ethtool when
> > > ethtool -i ethX is called.  With newer network cards having SFP
> > > and SFP+ PHY cages, this information can be useful, especially
> > > if the NIC supports hot-swapping of the PHY modules.
> > > 
> > > Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> > > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > > ---
> > 
> > Maybe revive usage of connector port in ethtool rather than adding new API?
> > It is already there but values are out of date with current hardware.
> 
> You're referring to the MODE_GSET port settings?  If so, I like this 
> approach, and will update my patches accordingly.

Yes. cmd->port is always PORT_TP or PORT_FIBRE now but could be extended
Likewise cmd->transceiver could be modified.  I haven't seen an external transceiver
since the old fat yellow cable with vampire taps (and that was 20 yrs ago).
