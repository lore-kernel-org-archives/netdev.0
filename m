From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 13/14] wireless: Use eth_<foo>_addr instead of
 memset
Date: Tue, 03 Mar 2015 02:29:33 -0800
Message-ID: <1425378573.17273.9.camel@perches.com>
References: <cover.1425354527.git.joe@perches.com>
	 <0c710456e4875ff00c1a9fcff9378ed15110dcd3.1425354528.git.joe@perches.com>
	 <1425370617.2450.3.camel@sipsolutions.net>
	 <1425371858.17273.3.camel@perches.com>
	 <1425372295.2450.9.camel@sipsolutions.net>
	 <1425372748.17273.6.camel@perches.com>
	 <1425373219.2450.13.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425373219.2450.13.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-03-03 at 10:00 +0100, Johannes Berg wrote:
> On Tue, 2015-03-03 at 00:52 -0800, Joe Perches wrote:
> 
> > > > My guess is the eth_zero_addr and eth_broadcast functions
> > > > are always taking aligned(2) arguments, just like all the
> > > > is_<foo>_ether_addr functions.
> > > 
> > > Err, are you serious???
> > 
> > Yes.
> > 
> > > That *clearly* isn't true, and if it was then
> > > this patch wouldn't be safe at all.
> > 
> > And why is that?
> > 
> > Until patch 1 of this series, eth_zero_addr and
> > eth_broadcast_addr was just an inline for a memset.
> > 
> > Even after patch 1, it's effectively still memset.
> 
> Exactly. It therefore *doesn't* require an aligned(2) argument, unlike
> what you stated above, hence my question if you're serious (and perhaps
> looking at some other code that I don't have).

Nope, you simply misunderstood what I did write.

What I said was that the arguments were likely
already aligned(2), not that the alignment was
a requirement.
