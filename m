From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/3] 6lowpan: add helper to get 6lowpan namespace
Date: Tue, 22 Apr 2014 20:49:10 +0200
Message-ID: <20140422184908.GA16477@omega>
References: <1397784176-15809-1-git-send-email-mcgrof@do-not-panic.com>
 <1397784176-15809-2-git-send-email-mcgrof@do-not-panic.com>
 <1398159886.4211.1.camel@jlt4.sipsolutions.net>
 <20140422095300.GA9241@omega>
 <20140422175818.GN27882@wotan.suse.de>
 <1398192315.4211.25.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Luis R. Rodriguez" <mcgrof-IBi9RG/b67k@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>,
	alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	backports-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <backports-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1398192315.4211.25.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: backports-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 22, 2014 at 08:45:15PM +0200, Johannes Berg wrote:
> On Tue, 2014-04-22 at 19:58 +0200, Luis R. Rodriguez wrote:
> 
> > > > > +#if IS_ENABLED(CONFIG_IEEE802154_6LOWPAN)
> > > > > [...]
> > > > > +#else
> > > > > +static inline struct netns_ieee802154_lowpan *
> > > > > +net_ieee802154_lowpan(struct net *net)
> > > > > +{
> > > > > +	return NULL;
> > > > > +}
> > > > > +#endif
> > > > 
> > > > Why would that be needed? If nobody compiles 802.15.4 then it seems
> > > > nothing should reference it?
> > > > 
> > > Indeed I think this is unnecessary, also.
> > 
> > I wanted to be sure, and I was not. Right now 6lowpan does not depend
> > on CONFIG_NET_NS, is this intentional? I think its fine without it
> > but I was not sure.
> 
> I fail to see how !CONFIG_LOWPAN is related CONFIG_NET_NS?
> 

mhh, IEEE802154_6LOWPAN depends on IPV6 and I think IPV6 is related to
CONFIG_NET_NS.

- Alex
