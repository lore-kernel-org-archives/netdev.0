From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Thu, 22 May 2008 11:18:59 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329051F3761@orsmsx414.amr.corp.intel.com>
References: <E1JyqZL-0005qz-00@gondolin.me.apana.org.au> <48344DAA.4060107@trash.net> <20080521233952.GA27138@gondor.apana.org.au> <D5C1322C3E673F459512FB59E0DDC329051F36F5@orsmsx414.amr.corp.intel.com> <4835B556.4020308@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4629 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757726AbYEVSS7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 14:18:59 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4835B556.4020308@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Waskiewicz Jr, Peter P wrote:
> >>> I thought about this myself, my second idea was to add a mask for 
> >>> feature bits to be propagated. Unless there is a need for
> >>>       
> >> the driver
> >>     
> >>> to determine them at runtime, thats slightly simpler. The
> >>>       
> >> driver would
> >>     
> >>> do:
> >>>
> >>> dev->vlan_features = NETIF_F_CSUM_ALL | ...
> >>>
> >>> What do you think about this?
> >>>       
> >> Yes that sounds great!
> >>     
> >
> > The issue is how does the driver know how to pull those 
> flags off the 
> > VLAN device when the parent has TSO or CSUM offload disabled?  The 
> > only way I could come up with it was in my original patch in the 
> > drivers to loop through the entire VLAN group array, and clear the 
> > flag on existing devices.
> >   
> 
> Yes, thats also what my patch is doing. Not a big deal I 
> guess, we're doing that for all kinds of notifications 
> already and nobody ever complained.

I guess I misunderstood what you were suggesting to re-implement with
Herbert.  I like your current patch as-is, but if something different is
coming, I'll just sit tight for it.  I already spun the ixgbe, igb, and
e1000e patches to use the new interface, and they should be coming out
shortly.  But if we need to update them later, that's cool.

Cheers,
-PJ Waskiewicz
