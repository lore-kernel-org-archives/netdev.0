From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 13/14] wireless: Use eth_<foo>_addr instead of
 memset
Date: Tue, 03 Mar 2015 00:37:38 -0800
Message-ID: <1425371858.17273.3.camel@perches.com>
References: <cover.1425354527.git.joe@perches.com>
	 <0c710456e4875ff00c1a9fcff9378ed15110dcd3.1425354528.git.joe@perches.com>
	 <1425370617.2450.3.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425370617.2450.3.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-03-03 at 09:16 +0100, Johannes Berg wrote:
> On Mon, 2015-03-02 at 19:54 -0800, Joe Perches wrote:
> > Use the built-in function instead of memset.
> 
> Please don't use <foo> in the title, especially not if the patch only
> introduces usage of eth_zero_addr(). It's easier to look for in the
> commit log without it.
> 
> Other than that, I guess I'll apply this, but I really wish there was a
> way to distinguish more easily which of these require alignment and
> which don't.

My guess is the eth_zero_addr and eth_broadcast functions
are always taking aligned(2) arguments, just like all the
is_<foo>_ether_addr functions.

> eth_zero_addr() doesn,t but is_zero_ether_addr() does. So does
> ether_addr_copy(). Frankly, it's getting a bit confusing, so I can't
> really fault anyone for using memset()/memcpy().

I suspect more than anything else all these are historic.
