From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 6/6] alx: fix ethtool support code
Date: Fri, 21 Jun 2013 22:46:09 +0200
Message-ID: <1371847569.8936.4.camel@jlt4.sipsolutions.net>
References: <1371766494-18979-1-git-send-email-johannes@sipsolutions.net>
	 <1371766494-18979-7-git-send-email-johannes@sipsolutions.net>
	 <1371818385.8771.21.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:53245 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945963Ab3FUUqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 16:46:12 -0400
In-Reply-To: <1371818385.8771.21.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > +	u32 supported = SUPPORTED_10baseT_Half |
> > +			SUPPORTED_10baseT_Full |
> > +			SUPPORTED_100baseT_Half |
> > +			SUPPORTED_100baseT_Full;
> > +
> > +	if (alx_hw_giga(hw))
> > +		supported |= SUPPORTED_1000baseT_Full;

> >  	if (ecmd->autoneg == AUTONEG_ENABLE) {
> > -		if (ecmd->advertising & ADVERTISED_1000baseT_Half)
> > +		if (ecmd->advertising & ~alx_get_supported_speeds(hw))
> [...]
> 
> This means that Pause/Asym_Pause advertising can't be directly
> controlled.  

True.

> It's a pain to implement that properly, though, so I
> suppose this can be deferred.

I have no idea how I would do it with this chip. I have no support from
the manufacturer other than their driver, and to be honest I don't have
a huge interest in adding these features, I have no need for them anyway
since my machine is connected to a gbit/full duplex switch :-)

My main concern was getting a driver into mainline, maybe/hopefully the
Qualcomm folks are interested in adding more features to it.

johannes
