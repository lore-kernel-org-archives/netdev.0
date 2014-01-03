From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: [net-next v4 07/16] i40e: Rx checksum offload for VXLAN
Date: Fri, 3 Jan 2014 11:07:39 -0800 (PST)
Message-ID: <alpine.LFD.2.03.1401031106520.6092@intel.com>
References: <1388200940-9113-1-git-send-email-jeffrey.t.kirsher@intel.com> <1388200940-9113-8-git-send-email-jeffrey.t.kirsher@intel.com> <CAJZOPZ+XpHNcMdOKYpALvUXq5-yYuxcwAqG2AEe4DU=d=VGPtg@mail.gmail.com> <alpine.LFD.2.03.1401021252500.4979@intel.com>
 <CAJZOPZK_b=Ve1YXsHfZjyeOQiMxj_jAKscmgZT_AKCEK1+V1UA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36251 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158AbaACStd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jan 2014 13:49:33 -0500
In-Reply-To: <CAJZOPZK_b=Ve1YXsHfZjyeOQiMxj_jAKscmgZT_AKCEK1+V1UA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 2 Jan 2014, Or Gerlitz wrote:

> On Thu, Jan 2, 2014 at 10:57 PM, Joseph Gasparakis
> <joseph.gasparakis@intel.com> wrote:
> 
> >
> > > The comment says that the driver has to compute the udp checksum
> > > **if** the packet has an outer udp checksum,
> > > but the driver call to issue checksumming is done unconditionally
> >
> >
> > This code runs when the right bits are set in the rx hardware descriptor
> > field (rx_ptype and rx_status), which implies the hardware has detected
> > ipv4 tunneling and there is non zero UDP csum.
> 
> 
> Got it -- thanks for explaining, also for the pointer on where
> skb->encapsulation is set
> 

Any time Or. And thanks for your reviews.
