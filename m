From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Thu, 22 May 2008 10:47:40 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329051F36F5@orsmsx414.amr.corp.intel.com>
References: <E1JyqZL-0005qz-00@gondolin.me.apana.org.au> <48344DAA.4060107@trash.net> <20080521233952.GA27138@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:26672 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754713AbYEVRrj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 13:47:39 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080521233952.GA27138@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I thought about this myself, my second idea was to add a mask for 
> > feature bits to be propagated. Unless there is a need for 
> the driver 
> > to determine them at runtime, thats slightly simpler. The 
> driver would 
> > do:
> > 
> > dev->vlan_features = NETIF_F_CSUM_ALL | ...
> > 
> > What do you think about this?
> 
> Yes that sounds great!

The issue is how does the driver know how to pull those flags off the
VLAN device when the parent has TSO or CSUM offload disabled?  The only
way I could come up with it was in my original patch in the drivers to
loop through the entire VLAN group array, and clear the flag on existing
devices.

Cheers,
-PJ Waskiewicz
