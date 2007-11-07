From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: add support for supporting 10000baseT
Date: Wed, 7 Nov 2007 18:25:53 +0000
Message-ID: <20071107182552.GC3320@solarflare.com>
References: <20071107162420.5102.26358.stgit@localhost.localdomain> <20071107165749.GB3320@solarflare.com> <4731FEC0.4020803@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pythagoras.zen.co.uk ([212.23.3.140]:41242 "EHLO
	pythagoras.zen.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbXKGSZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 13:25:58 -0500
Content-Disposition: inline
In-Reply-To: <4731FEC0.4020803@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Ben Hutchings wrote:
> > Auke Kok wrote:
> >> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> >>
> >> there is missing support in ethtool for reporting 10000baseT
> >> as SUPPORTED_10000baseT_Full.  The code seems to be half
> >> implemented because the "advertising" field has the implementation.
> > 
> > I reported this lack on Sourceforge a while back:
> > <http://sourceforge.net/tracker/index.php?func=detail&aid=1798807&group_id=3242&atid=103242>
> > Is anyone reading bugs reported there?
> 
> not really. However with plenty of new 10gig hardware going through
> here we're currently looking at ethtool support and seeing if it
> misses anything.

I think that's the only remaining issue we have with ethtool itself.
There's a wider issue of clause 45 MDIO for 10G Ethernet though.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
