From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: pull request: wireless-2.6 2010-06-30
Date: Wed, 30 Jun 2010 21:15:04 +0200
Message-ID: <1277925304.7823.16.camel@jlt3.sipsolutions.net>
References: <20100630185319.GA2618@tuxdriver.com>
	 <20100630.120551.170116973.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100630.120551.170116973.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-06-30 at 12:05 -0700, David Miller wrote:

> > +	/*
> > +	 * Receiving all multicast frames is always enabled by the
> > +	 * default flags setup in iwl_connection_init_rx_config()
> > +	 * since we currently do not support programming multicast
> > +	 * filters into the device.
> > +	 */
> >  	*total_flags &= FIF_OTHER_BSS | FIF_ALLMULTI | FIF_PROMISC_IN_BSS |
> >  			FIF_BCN_PRBRESP_PROMISC | FIF_CONTROL;
> 
> Note that this is an amazingly serious limitation.
> 
> This basically makes iwl chips unsuitable for use on networks where
> real multicast use is common.

Lots of wireless devices have this limitation unfortunately. I think we
-might- be able to have proper filters for iwl, but haven't found out
quite how yet unfortunately, if it's actually implemented properly on
the device and there's not just some fake API.

johannes
