From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next 13/14] wireless: Use eth_<foo>_addr instead of
 memset
Date: Tue, 03 Mar 2015 09:44:55 +0100
Message-ID: <1425372295.2450.9.camel@sipsolutions.net>
References: <cover.1425354527.git.joe@perches.com>
	 <0c710456e4875ff00c1a9fcff9378ed15110dcd3.1425354528.git.joe@perches.com>
	 <1425370617.2450.3.camel@sipsolutions.net>
	 <1425371858.17273.3.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425371858.17273.3.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > Other than that, I guess I'll apply this, but I really wish there was a
> > way to distinguish more easily which of these require alignment and
> > which don't.
> 
> My guess is the eth_zero_addr and eth_broadcast functions
> are always taking aligned(2) arguments, just like all the
> is_<foo>_ether_addr functions.

Err, are you serious??? That *clearly* isn't true, and if it was then
this patch wouldn't be safe at all.

> > eth_zero_addr() doesn,t but is_zero_ether_addr() does. So does
> > ether_addr_copy(). Frankly, it's getting a bit confusing, so I can't
> > really fault anyone for using memset()/memcpy().
> 
> I suspect more than anything else all these are historic.

I'd expect a mix here, certainly. Not all of them are really old though.

johannes
