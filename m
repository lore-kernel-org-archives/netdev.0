From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [VLAN]: Use bitmask of feature flags instead of seperate feature bits
Date: Fri, 23 May 2008 10:38:43 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329052350BA@orsmsx414.amr.corp.intel.com>
References: <48366C0F.4020905@trash.net><20080523070945.GB6615@gondor.apana.org.au> <20080523.003051.153798887.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <kaber@trash.net>, <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>, <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4729 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750871AbYEWRip convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 13:38:45 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080523.003051.153798887.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > On Fri, May 23, 2008 at 09:02:39AM +0200, Patrick McHardy wrote:
> > > 
> > >     [VLAN]: Use bitmask of feature flags instead of 
> seperate feature 
> > > bits
> > >     
> > >     Herbert Xu points out that the use of seperate 
> feature bits for features
> > >     to be propagated to VLAN devices is going to get 
> messy real soon.
> > >     Replace the VLAN feature bits by a bitmask of feature 
> flags to be
> > >     propagated and restore the old GSO_SHIFT/MASK values.
> > >     
> > >     Signed-off-by: Patrick McHardy <kaber@trash.net>
> > 
> > Looks great Patrick, thanks!
> > 
> > Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Applied and pushed out to net-2.6, thanks everyone!

Just to close the loop, also tested on ixgbe without issue.

Cheers,
-PJ Waskiewicz
