From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] r8169: more driver shutdown WoL regression.
Date: Thu, 10 Nov 2011 14:02:24 +0000
Message-ID: <1320933744.18929.82.camel@deadeye>
References: <20111108223502.GA20437@electric-eye.fr.zoreil.com>
	 <E6A5E7482020466E82FD141C8CD92D9A@realtek.com.tw>
	 <20111109222556.GA8226@electric-eye.fr.zoreil.com>
	 <DCB55CA56A5546B4B7350912D30EC679@realtek.com.tw>
	 <20111110104117.GA23906@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hayeswang <hayeswang@realtek.com>, <netdev@vger.kernel.org>,
	'Stefan Becker' <chemobejk@gmail.com>,
	'David Miller' <davem@davemloft.net>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:14922 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498Ab1KJOCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 09:02:34 -0500
In-Reply-To: <20111110104117.GA23906@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-11-10 at 11:41 +0100, Francois Romieu wrote:
> hayeswang <hayeswang@realtek.com> :
> [...]
> > I find that the magic packet which I send is the broadcast packet, and the one
> > which you send is the unicast packet. That is, you could wake up the system by
> > using broadcast magic packet for the previous chips without the patch. However,
> > if you prefer to unicast magic packet, this patch is necessary. Besides, no
> > matter broadcast or unicast magic packet, the patch is necessary for 8105,
> > 8168e, and later chips.
> 
> Ok, it makes some sense now.
> 
> I am inclined to enable a broad understanding of ethtool WAKE_MAGIC
> feature as AMD's magic packet white paper does not limit it to
> broadcast packets and explicitely quotes unicast and multicast.
> Ben (and others), any opinion ?
[...]

Sorry, I've never looked into WoL in detail so I'm not sure quite what
the intended semantics of WAKE_MAGIC are.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
