From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] make d80211 use nl80211
Date: Thu, 24 Aug 2006 19:36:59 +0200
Message-ID: <20060824173659.GO3470@postel.suug.ch>
References: <1156254813.3825.2.camel@ux156> <1156435657.10283.10.camel@ux156> <200608241909.35065.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:41142 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1030420AbWHXRgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2006 13:36:38 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200608241909.35065.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Michael Buesch <mb@bu3sch.de> 2006-08-24 19:09
> On Thursday 24 August 2006 18:07, Johannes Berg wrote:
> > +	pkt = alloc_skb(framelen, GFP_KERNEL);
> 
> if (!pkt)
> 	return -ENOMEM;
> 
> > +	pktdata = skb_put(pkt, framelen);
> > +	memcpy(pktdata, frame, framelen);
> 
> having two variables with almost the same name seems
> confusing to me. What about removing void *pktdata; and
> doing the following instead of the two lines above?
> 
> memcpy(skb_put(pkt, framelen), frame, framelen);
> 
> That is also how it's done in lots of other networking code.

You might want to use 'skb' instead of 'pkt', everyone
has got used to it.
