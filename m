From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/3] 6lowpan: add helper to get 6lowpan namespace
Date: Tue, 22 Apr 2014 20:45:15 +0200
Message-ID: <1398192315.4211.25.camel@jlt4.sipsolutions.net>
References: <1397784176-15809-1-git-send-email-mcgrof@do-not-panic.com>
	 <1397784176-15809-2-git-send-email-mcgrof@do-not-panic.com>
	 <1398159886.4211.1.camel@jlt4.sipsolutions.net>
	 <20140422095300.GA9241@omega> <20140422175818.GN27882@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Aring <alex.aring@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	backports@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140422175818.GN27882@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-04-22 at 19:58 +0200, Luis R. Rodriguez wrote:

> > > > +#if IS_ENABLED(CONFIG_IEEE802154_6LOWPAN)
> > > > [...]
> > > > +#else
> > > > +static inline struct netns_ieee802154_lowpan *
> > > > +net_ieee802154_lowpan(struct net *net)
> > > > +{
> > > > +	return NULL;
> > > > +}
> > > > +#endif
> > > 
> > > Why would that be needed? If nobody compiles 802.15.4 then it seems
> > > nothing should reference it?
> > > 
> > Indeed I think this is unnecessary, also.
> 
> I wanted to be sure, and I was not. Right now 6lowpan does not depend
> on CONFIG_NET_NS, is this intentional? I think its fine without it
> but I was not sure.

I fail to see how !CONFIG_LOWPAN is related CONFIG_NET_NS?

johannes
