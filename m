From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: extending ndo_add_rx_vxlan_port
Date: Mon, 28 Oct 2013 14:13:08 -0700 (PDT)
Message-ID: <alpine.LFD.2.03.1310281408090.10719@intel.com>
References: <526D2F8F.1070204@mellanox.com> <alpine.LFD.2.03.1310271017120.19783@intel.com> <CAJZOPZ+S6ngqMjV-2ZMcpzkuWzzLWwCQMtd_1_SjDkqWh_tbYg@mail.gmail.com> <alpine.LFD.2.03.1310271635540.15400@intel.com> <CAJZOPZLAg+5dYS=bUCkDMyYq8EmA_uvEv1Zi+drq6Qqe5onrzQ@mail.gmail.com>
 <alpine.LFD.2.03.1310281049210.31450@intel.com> <CAJZOPZJ3J7T=i2QXQPr80Qb-V8RT3uPJaNFDnrOpYxJ1Mt_LNQ@mail.gmail.com> <alpine.LFD.2.03.1310281322500.10719@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Yan Burman <yanb@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:35597 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751668Ab3J1U45 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Oct 2013 16:56:57 -0400
In-Reply-To: <alpine.LFD.2.03.1310281322500.10719@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 28 Oct 2013, Joseph Gasparakis wrote:

> 
> 
> On Mon, 28 Oct 2013, Or Gerlitz wrote:
> 
> > On Mon, Oct 28, 2013 at 7:59 PM, Joseph Gasparakis
> > > On Mon, 28 Oct 2013, Or Gerlitz wrote:
> > >> On Mon, Oct 28, 2013 at 1:44 AM, Joseph Gasparakis wrote:
> > 
> > >> > VXLAN implementation is not done like VLAN. VLANs are stacked on top of
> > >> > real interfaces and what you are saying makes sense. VXLAN however is
> > >> > using ip[6]_tunnel_xmit, and this is why we need to notify all the
> > >>
> > >> As the name of the ndo you added ndo_add_rx_vxlan_port suggests -- HW
> > >> needs that for RX offloads. So basically, what I am saying is: in a
> > >> similar manner that we already program the NIC "over which" the vxlan
> > >> instance is set to listen on the multicast address which is associated
> > >> with that vxlan segement, lets give them a hint that packets arriving
> > >> on this group are vxlan ones, so they can use it for programming
> > >> steering rules.
> > >
> > > Why don't you write up some code so everyone has something to look at?
> > > Then we can see what makes sense to do in terms of the existing or new ndos.
> > 
> > sure, code talks, indeed, still, looking on net-next, for the current
> > ndo there's no in tree consumer unless I miss anything, did I?
> > 
> > Or.
> > 
> 
> I don't think you missed anything. My patches for the i40e are currently 
> in our trees and making their way to netdev. It will be very soon.
> 
> 

Oh! And I also forgot to mention that if you want to see how it 
will be used, together with the patch mentioned above that introduces 
the ndos, I had added an RFC patch against ixgbe that showcases how the 
driver could use them. The RFC patch was just loging the info, but the 
actual talking to the HW would be vendor specific anyway.
