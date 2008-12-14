From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH 7/8] ethtool: Add GGRO and SGRO ops
Date: Sun, 14 Dec 2008 11:36:14 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.0812141124040.13556@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20081212053116.GA2927@gondor.apana.org.au>
 <E1LB0d2-0000rq-Dr@gondolin.me.apana.org.au> <1229112677.3051.9.camel@achroite>
 <20081212214835.GD11046@gondor.apana.org.au> <1229121327.3051.69.camel@achroite>
 <20081212224954.GA11636@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34336 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751284AbYLNTgY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Dec 2008 14:36:24 -0500
In-Reply-To: <20081212224954.GA11636@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Dec 2008, Herbert Xu wrote:

> On Fri, Dec 12, 2008 at 10:35:27PM +0000, Ben Hutchings wrote:
> >
> > If I'm not mistaken, the whole point of set_flags() is to end the
> > continued expansion of struct ethtool_ops by another 2 functions for
> > every new offload feature.  The comments make it fairly clear that Jeff
> > anticipated that it might be necessary to include such checks for some
> > flags.
> 
> GRO is purely a stack feature so it doesn't need anything in
> ethtool_ops at all.

I'm confused then.  You're adding two ethtool entry points with 
ETHTOOL_GGRO and ETHTOOL_SGRO, adding the callpoints in dev_ethtool with 
set_gro and get_gro, but how do you manipulate this without adding to the 
userspace application?  Adding this functionality to the set/get_flags 
will keep the userspace app from needing a patch to support the new 
callbacks.

Cheers,
-PJ Waskiewicz
